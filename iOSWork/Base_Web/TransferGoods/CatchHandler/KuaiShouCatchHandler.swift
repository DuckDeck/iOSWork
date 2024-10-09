//
//  KuaiShouCatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/25.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit

class KuaiShouCatchHandler: CatchGoods {
    override func getShopInfo(str: String) {
        if !shopInfo.shopId.isEmpty{
            return
        }
        do {
            let doc = try SwiftSoup.parse(str)
            if let shopId = try doc.select("div.seller-main-space-item").last()?.select("div > div").last()?.text(){
                shopInfo.shopId = shopId.replacingOccurrences(of: "ID:", with: "")
            }
            let vc = Tool.topVC() as? TransferGoodsViewController
            vc?.showIndicatorView()
            catchStage =  .ShopInfo("", "", .KuaiShou)
        } catch {
            return
        }
        
        super.getPreviousSavedGoods()
    }
    
    //快手商品貌似默认都是 时间从现在往前面已经排好的，这样可以直接判断
    override func loadAllGoods(str: String) {
        super.loadAllGoods(str: str)
        do {
            timer?.invalidate()
            timer = nil
            var isOver = false
            let doc = try SwiftSoup.parse(str)
            let numReg = RegexTool("\\d+")
            if let txt = try doc.select("li.goods-list-v1-pagination-total-text").first()?.text(), let num = numReg.fetch(input: txt)?.first {
                shopInfo.totalCount = Int(num) ?? 0
                shopInfo.totalCount = shopInfo.totalCount > 3000 ? 3000 : shopInfo.totalCount
            }
            if let index = try doc.select("li.goods-list-v1-pagination-item-active").first()?.select("a").first()?.text(), let i = Int(index) {
                shopInfo.pageIndex = i
            }
            if let table = try doc.select("table").last() {
                let trs = try table.select("tbody > tr")
                for row in trs {
                    if row.hasAttr("aria-hidden"){
                        continue
                    }
                    let td = try row.select("td")
                    let goods = CatchedGoods()
                    for col in td.enumerated() {
                        if col.offset == 1 { // 商品名和id
                            goods.goodsId = try col.element.select("div._9YvSnSDXj3dFdhE55pk").first()?.text().substring(from: 3).trimmingCharacters(in: .whitespaces) ?? ""
                        }
                        if col.offset == 7 {
                            let timeStr = try col.element.text()
                            let time = DateTime.parse(timeStr, format: "yyyy-MM-dd HH:mm:ss")
                            goods.time = (time?.timestamp ?? 0) * 1000
                        }
                    }
                    if goods.goodsId.isEmpty{
                        continue
                    }
                    if goods.time < previousLastGoodsTime{
                        isOver = true
                        break
                    } else if goods.time == previousLastGoodsTime {
                        if  goods.goodsId != previousLastGoodsId{
                            shopInfo.arrGoods.append(goods)
                        } else {
                            isOver = true
                            break
                        }
                    } else {
                        shopInfo.arrGoods.append(goods)
                    }
                    if shopInfo.arrGoods.count > goodsCountUpperLimit{
                        isOver = true
                        break
                    }
                }
            }
            if shopInfo.arrGoods.count < shopInfo.totalCount && !isOver {
                evaluate(JS: "document.getElementsByClassName('goods-list-v1-pagination-item-link')[1].click()", delayTime: 1, actionName: "下一页") // 这个制作貌似没有返回，或者是返回出错
                catchStage = .GoodsNum(shopInfo.arrGoods.count)
                if timer == nil{
                    timer = GrandTimer.after(.fromSeconds(1), block: { [weak self] in
                        self?.tick()
                    })
                    timer?.fire()
                }
            } else {
                if shopInfo.arrGoods.count > 0{
                    if shopInfo.arrGoods.count > goodsCountUpperLimit{
                        shopInfo.arrGoods.removeLast()
                        catchStage = .Ready(shopInfo.arrGoods.count,true)
                    } else {
                        catchStage = .Ready(shopInfo.arrGoods.count,false)
                    }
                    shopInfo.arrGoods.sort { a, b in
                        return a.time < b.time
                    } //商品时间排序
                } else {
                    catchStage = .noGoodsToTransfer
                }
                
            }
        } catch {
            catchStage = .Fail(shopInfo.arrGoods.count, shopInfo.arrGoods.count)
            return
        }
    }
    
    override func evaluate(JS: String, delayTime: Int, actionName: String) {
        delayTask = HWDebounceTrailing(interval: TimeInterval(delayTime), on: .global(), taskBlock: {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(JS) { [weak self] res, err in
                    guard let self = self else {return}
                    if self.catchStatus != .process{
                        return
                    }
                    if err != nil || res == nil {
                        if err == nil, actionName == "下一页" {
                            self.evaluate(JS: "document.body.innerHTML", delayTime: 3, actionName: "快手商品列表")
                        } else {
                            Toast.showToast(msg: err?.localizedDescription ?? "evaluateJS出现错误")
                        }
                        return
                    }
                    if let d = res as? String,!d.isEmpty {
                        if actionName == "快手店铺" {
                            self.getShopInfo(str: d)
                        } else if actionName == "快手商品列表" {
                            self.loadAllGoods(str: d)
                        } else if actionName == "快手商品详情" {
                            self.catchSingleGoods(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
    
    //保存商品应该倒序
    override func loadSingleGoods(str: String? = nil) {
        super.loadSingleGoods(str: str)
        if goodsIndex == shopInfo.arrGoods.count - 1 || catchStatus != .process {
            timer?.invalidate()
            timer = nil
            return
        }
        goodsIndex += 1
        fetchType = ""
        guard let url =  URL(string: singleGoodsUrl) else {
            catchStatus = .error
            return
        }
        webView.load(URLRequest(url: url))
        shopInfo.arrGoods[goodsIndex].sourceUrl = singleGoodsUrl
        shopInfo.arrGoods[goodsIndex].sourceType = 10
        if goodsIndex == 0{
            catchStage = .Transfering(0)
        }
    }
    
    override var singleGoodsUrl: String{
        return "https://s.kwaixiaodian.com/zone/goods/config/release/detail?itemId=\(shopInfo.arrGoods[goodsIndex].goodsId)"
    }

    override func catchSingleGoods(str: String) {
        super.catchSingleGoods(str: str)
        do {
            let doc = try SwiftSoup.parse(str)
            if let goodsInfoDiv = try doc.select("div#BaseInfo").first()?.select("div.goods-row"),goodsInfoDiv.count > 0{
                for item in goodsInfoDiv {
                    let cols = try item.select("div.goods-col")
                    if try cols[0].text().hasPrefix("商品标题") {
                        let title = try cols[1].text()
                        shopInfo.arrGoods[goodsIndex].title = title
                    }
                    if try cols[0].text().hasPrefix("商品属性") {
                        let proCols = try cols[1].select("div > div > div > div")
                        for a in proCols where a.children().count >= 2 {
                            let title = try a.children()[0].text()
                            let value = try a.children()[1].text()
                            if title.hasPrefix("货号") && !value.isEmpty{
                                shopInfo.arrGoods[goodsIndex].goodsNum = value
                            } else if !title.isEmpty && !value.isEmpty {
                                shopInfo.arrGoods[goodsIndex].detailTitle += "【\(title)】\(value)"
                            }
                    
                        }
                    }
                }
                
            }
           
            if let mainImgDiv = try doc.select("div#GoodsImg").first()?.select("div.goods-row"),mainImgDiv.count > 0{
                for item in mainImgDiv {
                    let cols = try item.select("div.goods-col")
                    if try cols[0].text().hasPrefix("商品主图") {
                        let imgs = try cols[1].select("img")
                        for a in imgs {
                            shopInfo.arrGoods[goodsIndex].imgs.append(try a.attr("src"))
                        }
                    }
                    if try cols[0].text().hasPrefix("商品详情图") {
                        let imgs = try cols[1].select("img")
                        shopInfo.arrGoods[goodsIndex].detailImg = [String]()
                        for a in imgs {
                            shopInfo.arrGoods[goodsIndex].detailImg?.append(try a.attr("src"))
                        }
                    }
                }
            }
         
            if let skuRows = try doc.select("tbody.goods-table-tbody").first()?.children(), skuRows.count > 0 {
                var cs = Set<CatchGoodsFormat>()
                var fs = Set<CatchGoodsFormat>()
                var skus = [CatchGoodsFormat]()
                for item in skuRows {
                    var color = CatchGoodsFormat()
                    var format: CatchGoodsFormat?
                    var sku = CatchGoodsFormat()
                    for col in item.children().enumerated() {
                        if col.offset == 0 {
                            let name = try col.element.text().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
                            let com = name.split(separator: ",")
                            if com.count == 2 {
                                color.name = String(com[0])
                                format = CatchGoodsFormat()
                                format?.name = String(com[1])
                                sku.name = name.replacingOccurrences(of: ",", with: " ")
                                sku.cname = color.name
                            } else if com.count == 1 {
                                color.name = name
                                sku.name = name
                            } else {
                               break
                            }
                        }
                        if col.offset == 1 {
                            let stock = try col.element.text()
                            sku.stock = Int(stock) ?? 0
                        }
                        if col.offset == 3 {
                            var price = try col.element.text()
                            if price.hasPrefix("¥"){
                                price.removeFirst()
                            }
                            sku.price = price
                        }
                        if col.offset == 6 {
                            let img = try col.element.select("img").first()?.attr("src")
                            sku.img = img ?? ""
                        }
                    }
                    if !sku.name.isEmpty{
                        skus.append(sku)
                        cs.insert(color)
                        if format != nil {
                            fs.insert(format!)
                        }
                    }
                }
                
                if skus.count <= 0{
                    _ = delay(time: 2, task: {
                        self.loadSingleGoods()
                    })
                    return
                }
                
                save(format: Array(fs), color: Array(cs)) { formats, colors,err in
                    if err != nil{
                        self.shopInfo.arrGoods[self.goodsIndex].catchFail = .saveFormatColorFail(err!)
                        self.catchStatus = .error
                        return
                    }
                    
                    if colors.count > 0, formats.count > 0 {
                        for i in 0..<skus.count {
                            if let c = colors.first(where: { t in
                                skus[i].name.split(separator: " ").first?.lowercased() == t.name.lowercased()
                            }),let f = formats.first(where: { t in
                                skus[i].name.split(separator: " ").last?.lowercased() == t.name.lowercased()
                            }) {
                                skus[i].id = "\(c.id);\(f.id)"
                            }
                        }
                    } else if colors.count > 0, formats.count == 0 {
                        for i in 0..<skus.count {
                            if let c = colors.first(where: { t in
                                skus[i].name.lowercased().contains(t.name.lowercased())
                            }){
                                skus[i].id = c.id
                            }
                        }
                    } else if colors.count == 0, formats.count > 0 {
                        for i in 0..<skus.count {
                            if let c = formats.first(where: { t in
                                skus[i].name.lowercased().contains(t.name.lowercased())
                            }){
                                skus[i].id = c.id
                            }
                           
                        }
                    }
                    self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku = CatchGoodsSku()
                    self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.colors = colors
                    self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.formats = formats
                    self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.skus = skus
                    self.loadSingleGoods()
                }
            } else {
                loadSingleGoods()
            }
            
        } catch {
            self.shopInfo.arrGoods[self.goodsIndex].catchFail = .htmlParseFail(error: error)
            _ = delay(time: 3) {
                self.catchStatus = .error
            }
            return
        }
    }
}
