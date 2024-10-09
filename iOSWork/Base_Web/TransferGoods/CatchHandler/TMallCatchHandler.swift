//
//  TMallCatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/21.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit


class TMallCatchHandler: CatchGoods {
    var tmallIds = [
        "614910141143",
        "677852450324",
        "556588408785",
        "607157283654",
        "543918455462",
        "667695771988",
        "609289326215",
        "624116907008",
        "609514483571",
        "680294686479",
        "677852450324",
        "646659187916",
        "696357879004",
        "693286785786",
        "622654766554",
        "657767907645",
        "724723868611",
        "659605816192",
        "599745066024",
        "713217749612",
        "592146045916",
        "655981607023",
        "726745886011",
        "688563413616",
        "689000639954",
        "667916079075",
        "710291966879",
        "717596909015",
        "677604755232",
        "640090910755",
    ]
    
//        var tmallIds = [
//                        "710291966879",
//                        "556588408785",
//        ]

    // 天猫目前不可用
    override func getShopInfo(str: String) {
        let index = str.index(str: "(")
        var tmp = str.substring(from: index + 1)
        tmp.removeLast()
        let jsonStr = JSON(tmp.data(using: .utf8)!)
        shopInfo.shopId = jsonStr["data"]["result"]["shopId"].stringValue
        shopInfo.shopName = jsonStr["data"]["result"]["shopName"].stringValue
        shopInfo.shopIcon = jsonStr["data"]["result"]["fullAvatar"].stringValue
        catchStage = .ShopInfo(shopInfo.shopName, shopInfo.shopIcon, shopInfo.platform)
        super.getShopInfo(str: str)
    }
    
    override func loadAllGoods(str: String) {
        super.loadAllGoods(str: str)
        let numReg = RegexTool("\\d+")
        do {
            timer?.invalidate()
            timer = nil
            var isOver = false
            let doc = try SwiftSoup.parse(str)
            if shopInfo.totalCount == 0 {
                if let txt = try doc.select("div.next-pagination-total").first()?.text(), let num = numReg.fetch(input: txt)?.first {
                    shopInfo.totalCount = Int(num) ?? 0
                }
            }
       
            if let index = try doc.select("button.next-current").first()?.text(), let i = Int(index) {
                if shopInfo.pageIndex == i {
                    evaluate(JS: "document.body.innerHTML", delayTime: 5, actionName: "获取天猫商品ID")
                    return
                } else {
                    shopInfo.pageIndex = i
                }
            }
            let goodsRow = try doc.select("tr.row-with-config-list")
            for a in goodsRow {
                let tds = a.children()
                let g = CatchedGoods()
                for b in tds {
                    if try b.attr("label") == "商品名称" {
                        let id = try b.select("span.product-desc-span").last()?.text().replacingOccurrences(of: "ID:", with: "") ?? ""
                        g.goodsId = id
                    }
                    if try b.attr("label") == "创建时间" {
                        let timeStr = try b.select("div.product-desc-span").first()?.text() ?? ""
                        let time = DateTime.parse(timeStr, format: "yyyy-MM-dd HH:mm")
                        g.time = (time?.timestamp ?? 0) * 1000
                    }
                }
                if g.time < previousLastGoodsTime {
                    isOver = true
                    break
                } else if g.time == previousLastGoodsTime {
                    if g.goodsId != previousLastGoodsId {
                        shopInfo.arrGoods.append(g)
                    } else {
                        isOver = true
                        break
                    }
                } else {
                    shopInfo.arrGoods.append(g)
                }
                if shopInfo.arrGoods.count > goodsCountUpperLimit {
                    isOver = true
                    break
                }
            }
            if shopInfo.arrGoods.count < shopInfo.totalCount, !isOver {
                webView.evaluateJavaScript("document.getElementsByClassName('l-config-list-table')[0].getElementsByClassName('next-next')[0].click()") { _, err in
                    if err != nil {
                    }
                    self.evaluate(JS: "document.body.innerHTML", delayTime: 5, actionName: "获取天猫商品ID")
                }
                if timer == nil {
                    timer = GrandTimer.after(.fromSeconds(1), block: { [weak self] in
                        self?.tick()
                    })
                    timer?.fire()
                }
                catchStage = .GoodsNum(shopInfo.arrGoods.count)
            } else {
                if shopInfo.arrGoods.count > 0 {
//                    for i in 0..<shopInfo.arrGoods.count{
//                        shopInfo.arrGoods[i].goodsId = tmallIds[i]
//                    }
                    if shopInfo.arrGoods.count > goodsCountUpperLimit {
                        shopInfo.arrGoods.removeLast()
                        catchStage = .Ready(shopInfo.arrGoods.count, true)
                    } else {
                        catchStage = .Ready(shopInfo.arrGoods.count, false)
                    }
                    shopInfo.arrGoods.sort { a, b in
                        a.time < b.time
                    }
                } else {
                    catchStage = .noGoodsToTransfer
                }
            }
        } catch {
            catchStage = .Fail(shopInfo.arrGoods.count, shopInfo.arrGoods.count)
            return
        }
    }
    
    override func loadSingleGoods(str: String?) {
        super.loadSingleGoods(str: str)
        if goodsIndex == shopInfo.arrGoods.count - 1 || catchStatus != .process {
            timer?.invalidate()
            timer = nil
            return
        }
        goodsIndex += 1
        fetchType = ""
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
        webView.load(URLRequest(url: URL(string: singleGoodsUrl)!))
        shopInfo.arrGoods[goodsIndex].sourceUrl = singleGoodsUrl
        shopInfo.arrGoods[goodsIndex].sourceType = 2
        if goodsIndex == 0 {
            catchStage = .Transfering(0)
        }
    }
    
    override var singleGoodsUrl: String {
        return "https://detail.tmall.com/item.htm?abbucket=0&id=\(shopInfo.arrGoods[goodsIndex].goodsId)"
    }
    
    override func evaluate(JS: String, delayTime: Int, actionName: String) {
        delayTask = HWDebounceTrailing(interval: TimeInterval(delayTime), on: .global(), taskBlock: {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(JS) { [weak self] res, err in
                    guard let self = self else { return }
                    if self.catchStatus != .process {
                        return
                    }
                    if err != nil || res == nil {
                        Toast.showToast(msg: err!.localizedDescription)
                        return
                    }
                    if let d = res as? String,!d.isEmpty {
                        if actionName == "获取天猫商品ID" {
                            self.loadAllGoods(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
    
    override func catchSingleGoods(str: String) {
        super.catchSingleGoods(str: str)
        
        guard let first = str.firstIndex(of: "(") else { return }
        var jsStr = str[first..<str.endIndex]
        jsStr.removeLast()
        jsStr.removeFirst()
        guard let js = JSON(jsStr.data(using: .utf8) as Any)["data"].dictionary, js.count > 0 else {
            return
        }
        guard let propStr = js["apiStack"]?.arrayValue.first?.dictionaryValue["value"]?.stringValue else { return }
        
        let propJs = JSON(parseJSON: propStr)["global"]["data"].dictionaryValue
        
        guard let shopItem = propJs["item"]?.dictionaryValue else {
            return
        }
        let title = shopItem["title"]?.stringValue ?? ""
        shopInfo.arrGoods[goodsIndex].title = title
        let imgJS = (shopItem["images"]?.arrayValue ?? [])
        for item in imgJS.prefix(9) {
            shopInfo.arrGoods[goodsIndex].imgs.append(item.stringValue.addHttps())
        }
        if imgJS.count > 9 {
            shopInfo.arrGoods[goodsIndex].detailImg = [String]()
            for item in imgJS.suffix(imgJS.count - 9) {
                shopInfo.arrGoods[goodsIndex].detailImg?.append(item.stringValue.addHttps())
            }
        }
        // 获取视频
        if let videoItems = shopItem["videos"]?.arrayValue {
            for item in videoItems.enumerated() {
                let url = item.element["url"].stringValue
                let poster = item.element["videoThumbnailURL"].stringValue
                if item.offset == 0 {
                    shopInfo.arrGoods[goodsIndex].video = url
                    shopInfo.arrGoods[goodsIndex].videoCover = poster
                } else {
                    if shopInfo.arrGoods[goodsIndex].detailVideo == nil {
                        shopInfo.arrGoods[goodsIndex].detailVideo = [String: String]()
                    }
                    shopInfo.arrGoods[goodsIndex].detailVideo?[url] = poster
                }
            }
        }
        
        // 获取货号
        if let extraInfo = propJs["componentsVO"]?["kernelParamsVO"]["params"].arrayValue {
            for a in extraInfo {
                if a["subText"].stringValue == "货号" {
                    let goodsNum = a["mainText"].arrayValue.first?.stringValue ?? ""
                    if !goodsNum.isEmpty {
                        shopInfo.arrGoods[goodsIndex].goodsNum = goodsNum
                    }
                } else {
                    let title = a["subText"].stringValue
                    let value = a["mainText"].arrayValue.first?.stringValue ?? ""
                    if !title.isEmpty && !value.isEmpty {
                        shopInfo.arrGoods[goodsIndex].detailTitle += "【\(title)】\(value)"
                    }
                }
            }
        }
        
        var tmallSkuColor = [CatchGoodsFormat]()
        var tmallSkuFormat: [CatchGoodsFormat]?
        
        guard let skuBase = propJs["skuBase"]?["props"].arrayValue else {
            // 没人sku记单个价格
            if let price = propJs["price"]?["price"]["priceText"].stringValue, !price.isEmpty {
                shopInfo.arrGoods[goodsIndex].price = price
            }
            
            _ = delay(time: 3) {
                self.loadSingleGoods(str: nil)
            }
            return
        }
        // 没有sku或者多组sku不记录
        if skuBase.count <= 0 || skuBase.count > 2 {
            _ = delay(time: 3) {
                self.loadSingleGoods(str: nil)
            }
            return
        }
        var arrJsColor = [JSON]()
        var arrJsFormat: [JSON]?
        if skuBase.count == 1 {
            arrJsColor = skuBase[0]["values"].arrayValue
        } else {
            var colorIndex = -1
            for item in skuBase.enumerated() {
                if item.element["name"].stringValue.contains("颜色") {
                    colorIndex = item.offset
                }
            }
            if colorIndex >= 0 {
                arrJsColor = skuBase[colorIndex]["values"].arrayValue
                arrJsFormat = skuBase[1 - colorIndex]["values"].arrayValue
            } else {
                arrJsColor = skuBase[0]["values"].arrayValue
                arrJsFormat = skuBase[1]["values"].arrayValue
            }
        }
        
        for c in arrJsColor {
            let name = c["name"].stringValue
            var s = CatchGoodsFormat()
            s.name = name.replaceSpaceSymble
            s.img = c["image"].stringValue
            s.originId = c["vid"].stringValue
            s.type = 1
            tmallSkuColor.append(s)
        }
        if let format = arrJsFormat {
            tmallSkuFormat = [CatchGoodsFormat]()
            for item in format {
                let name = item["name"].stringValue
                var s = CatchGoodsFormat()
                s.name = name.replaceSpaceSymble
                s.originId = item["vid"].stringValue
                s.type = 0
                tmallSkuFormat?.append(s)
            }
        }
        
        // 获取skumap
        var skuMap = [CatchGoodsFormat]()
        for a in tmallSkuColor {
            var c = a
            if let tmp = tmallSkuFormat {
                for b in tmp {
                    c.originId = "\(c.originId);\(b.originId)"
                    c.name = "\(c.name) \(b.name)"
                    c.cname = a.name
                    skuMap.append(c)
                }
            } else {
                skuMap.append(c)
            }
        }
        
        // 获取价格和库存，比较特殊
        // 天猫把两个skuId合成了一个新的id，保存在字典里,然后用这个新的短id来记录该sku的价格的库存等信息
        // "propPath": "1627207:512620281;20509:28317",
        // "skuId": "5200606906122"
        var tmpDict = [String: String]()
        guard let skuIds = propJs["skuBase"]?["skus"].arrayValue else {  return }
        for item in skuIds {
            tmpDict[item["propPath"].stringValue] = item["skuId"].stringValue
        }
        // 使用新的短id使用key，记录sku信息
        /* "5200606906121": {
             "price": {
             "priceMoney": "38800",
             "priceText": "388"
             },
             "quantity": "200",
         }, */
        
        guard let skuPrices = propJs["skuCore"]?["sku2info"].dictionaryValue else {  return }
        for a in skuPrices {
            let longId = a.key
            for b in tmpDict {
                if b.value == longId {
                    let price = a.value["price"]["priceText"].stringValue
                    let stock = Int(a.value["quantity"].stringValue)
                    for i in 0..<skuMap.count { // 将价格信息转移到skumap上
                        if skuMap[i].isPlanar {
                            if b.key.contains(skuMap[i].originColorId ?? "") && b.key.contains(skuMap[i].originFormatId ?? "") {
                                skuMap[i].price = price
                                skuMap[i].stock = stock
                            }
                        } else {
                            if b.key.contains(skuMap[i].originColorId ?? "") {
                                skuMap[i].price = price
                                skuMap[i].stock = stock
                            }
                        }
                    }
                }
            }
        }

        save(format: tmallSkuFormat, color: tmallSkuColor) { formats, colors, err in
            if err != nil {
                self.shopInfo.arrGoods[self.goodsIndex].catchFail = .saveFormatColorFail(err!)
                self.catchStatus = .error
                return
            }
            var idMap = [String: String]() // 建立一个原始id到新id的映射
            for a in colors {
                var tmp = a.originId
                if formats.count > 0 {
                    for b in formats {
                        tmp = "\(tmp);\(b.originId)"
                        idMap[tmp] = "\(a.id);\(b.id)"
                    }
                } else {
                    idMap[tmp] = "\(a.id)"
                }
            }
            for i in 0..<skuMap.count {
                skuMap[i].id = idMap[skuMap[i].originId] ?? ""
            }
            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku = CatchGoodsSku()
            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.skus = skuMap
            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.formats = formats
            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.colors = colors
            self.loadSingleGoods(str: nil)
        }
    }
}
