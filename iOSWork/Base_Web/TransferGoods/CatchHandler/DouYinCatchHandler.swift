//
//  DouYinCatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/24.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit

class DouYinCatchHandler:CatchGoods{
    var info = ""
    var detail = ""
    override func getShopInfo(str: String) {
        do {
            let doc = try SwiftSoup.parse(str)
            let infoRows = try doc.select("div.ant-row")
            for item in infoRows{
                let cols = item.children()
                if try cols[0].text().contains("店铺ID"){
                    shopInfo.shopId = try cols[1].text()
                }
                if let img = try cols[1].select("div>div>div").first()?.attr("style").replacingOccurrences(of: "background-image: url(", with: "").replacingOccurrences(of: "&quot;", with: "").replacingOccurrences(of: ");", with: "").replacingOccurrences(of: "\"", with: ""){
                    shopInfo.shopIcon = img
                }
                if try cols[0].text().contains("店铺名称"){
                    shopInfo.shopName = try cols[1].text()
                }
            }
            let vc = Tool.topVC() as? TransferGoodsViewController
            vc?.showIndicatorView()
            catchStage =  .ShopInfo(shopInfo.shopName, shopInfo.shopIcon, .Douyin)
            super.getShopInfo(str: str)
            webView.load(URLRequest(url: URL(string: "https://fxg.jinritemai.com/ffa/g/list")!))
            
        } catch {
            
        }
       
    }
    
    //快手商品貌似默认都是 时间从现在往前面已经排好的，这样可以直接判断
    override func loadAllGoods(str: String) {
        super.loadAllGoods(str: str)
        do {
            var isOver = false
            let doc = try SwiftSoup.parse(str)
            let numReg = RegexTool("\\d+")
            if let txt = try doc.select("li.ecom-g-pagination-total-text").first()?.text(), let num = numReg.fetch(input: txt)?.first {
                shopInfo.totalCount = Int(num) ?? 0
                print("共有商品\(shopInfo.totalCount)个")
            }
            if let index = try doc.select("li.ecom-g-pagination-item-active").first()?.attr("title"), let i = Int(index) {
                shopInfo.pageIndex = i
            }
            if let table = try doc.select("table").first(){
                let trs = try table.select("tbody > tr")
                for row in trs{
                    let td = try row.select("td")
                    let goods = CatchedGoods()
                    for col in td.enumerated(){
                        if col.offset == 1{ //商品名和id
                            let divs = try col.element.select("div > div > div > div")
                            for tmp in divs{
                                if try tmp.className().hasPrefix("style_productId"){
                                    let txt = try tmp.text().replacingOccurrences(of: "ID:", with: "")
                                    goods.goodsId = txt
                                    break
                                }
                            }
                        }
                        if col.offset == 5{
                           let timeStr = try col.element.select("div > div").map({ e in
                                return try e.text()
                            }).joined(separator: " ")
                            let time = DateTime.parse(timeStr)
                            goods.time = (time?.timestamp ?? 0) * 1000
                        }
                    }
                    if goods.goodsId.isEmpty{
                        continue
                    }
                    if goods.time < previousLastGoodsTime{
                        isOver = true
                        break
                    } else if goods.time == previousLastGoodsTime && previousLastGoodsTime > 0 {
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
            if shopInfo.arrGoods.count < shopInfo.totalCount && !isOver{
                evaluate(JS: "document.getElementsByClassName('ecom-g-pagination-next')[0].click()", delayTime: 1, actionName: "下一页") //这个制作貌似没有返回，或者是返回出错
                if timer == nil{
                    timer = GrandTimer.after(.fromSeconds(1), block: { [weak self] in
                        self?.tick()
                    })
                    timer?.fire()
                }
                catchStage = .GoodsNum(shopInfo.arrGoods.count)
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
                        if err == nil && actionName == "下一页"{
                            self.evaluate(JS: "document.body.innerHTML", delayTime: 3, actionName: "抖音店铺商品列表")
                        } else {
                            Toast.showToast(msg: err?.localizedDescription ?? "evaluateJS出现错误")
                        }
                        return
                    }
                    if let d = res as? String,!d.isEmpty {
                        if actionName == "抖音店铺信息"{
                            self.getShopInfo(str: d)
                        } else if actionName == "抖音店铺商品列表"{
                            self.loadAllGoods(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
    
    override func loadSingleGoods(str: String? = nil) {
        super.loadSingleGoods(str: str)
        if goodsIndex == shopInfo.arrGoods.count - 1 || catchStatus != .process {
            timer?.invalidate()
            timer = nil
            return
        }
        goodsIndex += 1
        fetchType = ""
        let vc = Tool.topVC() as? TransferGoodsViewController
        if vc == nil{
            catchStatus = .error
            return
        }
        vc?.switchWebView(type: 0)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
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
        return "https://haohuo.jinritemai.com/ecommerce/trade/detail/index.html?id=\(shopInfo.arrGoods[goodsIndex].goodsId)"
    }
    
    func readGoodsInfo(){
        let jsDetail = JSON(detail.data(using: .utf8) as Any)
        let detailImgs = jsDetail["detail_info"]["detail_imgs"].arrayValue
        shopInfo.arrGoods[goodsIndex].detailImg = [String]()
        for item in detailImgs{
            let url = item["url_list"].arrayValue.first?.stringValue ?? ""
            shopInfo.arrGoods[goodsIndex].detailImg?.append(url)
        }
        if let formats = jsDetail["detail_info"]["product_format"].arrayValue.first{
            let fs = formats["format"].arrayValue
            for item in fs{
                if let f = item["message"].arrayValue.first, item["name"].stringValue == "货号"{
                    let num = f["desc"].stringValue
                    shopInfo.arrGoods[goodsIndex].goodsNum = num
                }
                if let f = item["message"].arrayValue.first{
                    let desc = f["desc"].stringValue
                    shopInfo.arrGoods[goodsIndex].detailTitle += "【\(item["name"].stringValue)】\(desc)"
                }
            }
        }
        
        let jsGoods = JSON(info.data(using: .utf8) as Any)
        let imgComponent = JSON(jsGoods["promotion_v2"].stringValue.data(using: .utf8))
        let title = imgComponent["name_component"]["name"].stringValue
        shopInfo.arrGoods[goodsIndex].title = title
        let jsImgs = imgComponent["image_component"]["images"].arrayValue
        for item in jsImgs{
            let url = item["url_list"].arrayValue.first?.stringValue ?? ""
            shopInfo.arrGoods[goodsIndex].imgs.append(url)
        }
        let videoUrl = imgComponent["image_component"]["video"]["main_url"].stringValue
        shopInfo.arrGoods[goodsIndex].video = videoUrl
        
        let priceJs = imgComponent["price_component_v2"].dictionaryValue
        var maxPrice = priceJs["max_price"]?.doubleValue ?? 0
        if maxPrice == 0{
            maxPrice = priceJs["min_price"]?.doubleValue ?? 0
        }
        maxPrice = maxPrice / 100
        shopInfo.arrGoods[goodsIndex].price = "\(maxPrice)"
        
        
        let jsSku = imgComponent["spec_component"]["total_spec_list"].dictionaryValue
        if jsSku.count >= 3 || jsSku.count <= 0{
            _ = delay(time: 1) {
                self.loadSingleGoods()
            }
            return
        }
        if jsSku.count == 1{
            for item in jsSku{
                if item.key == "默认" && item.value.arrayValue.count == 1{
                    _ = delay(time: 1) {
                        self.loadSingleGoods()
                    }
                    return
                }
            }
        }
       
        var fs = [CatchGoodsFormat]()
        var cs = [CatchGoodsFormat]()
        for item in jsSku{
            if item.key == "颜色"{
                for a in item.value.arrayValue{
                    var c = CatchGoodsFormat()
                    c.name = a["name"].stringValue
                    c.img = a["img_list"].arrayValue.first?["url_list"].arrayValue.first?.stringValue ?? ""
                    c.img = c.img.replacingOccurrences(of: "132:132", with: "1000:1000")
                    c.originId = a["spec_detail_id"].stringValue
                    if fs.count < 32{
                        cs.append(c)
                    }
                }
            } else if let f = item.value.array,f.count > 0{
                for b in f{
                    var c = CatchGoodsFormat()
                    c.name = b["name"].stringValue
                    if fs.count < 32{
                        fs.append(c)
                    }
                }
            }
        }
        
        //貌似抖单没有sku价格体系
        if fs.count > 0 || cs.count > 0{
            save(format: fs, color: cs) { formats, colors,err in
                if err != nil{
                    self.shopInfo.arrGoods[self.goodsIndex].catchFail = .saveFormatColorFail(err!)
                    self.catchStatus = .error
                    return
                }
                
                var skus = [CatchGoodsFormat]() //抖店没有价格
                if formats.count > 0 && colors.count > 0{
                    for a in colors{
                        for b in formats{
                            var sku = CatchGoodsFormat()
                            sku.id = "\(a.id);\(b.id)"
                            sku.name = "\(a.name) \(b.name)"
                            sku.img = a.img
                            sku.price = "\(maxPrice)"
                            skus.append(sku)
                        }
                    }
                } else if (formats.count == 0 && colors.count > 0) {
                    skus = colors
                    for i in 0..<skus.count{
                        skus[i].price = "\(maxPrice)"
                    }
                } else if  (formats.count > 0 && colors.count == 0){
                    skus = formats
                    for i in 0..<skus.count{
                        skus[i].price = "\(maxPrice)"
                    }
                }
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku = CatchGoodsSku()
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.colors = colors
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.formats = formats
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.skus = skus
                self.loadSingleGoods()
                
            }
        }
    }
    
    override func catchSingleGoods(str: String) {
        super.catchSingleGoods(str: str)
        if str.contains("promotion_v2"){
            info = str
            delayTask = HWDebounceTrailing(interval: TimeInterval(2), on: .global(), taskBlock: {
                self.readGoodsInfo()
            })
            delayTask?.call()
        } else if str.contains("detail_info") {
            detail = str
            delayTask = HWDebounceTrailing(interval: TimeInterval(2), on: .global(), taskBlock: {
                self.readGoodsInfo()
            })
            delayTask?.call()
        }
    }
    
    
}
