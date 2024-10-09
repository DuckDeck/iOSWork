//
//  TaobaoCatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/20.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit

class TaobaoCatchHandler: CatchGoods {
    let ids = ["683318180620",
               "689162714421",
               "789237304340",
               "789145594714",
               "789100451934",
               "789100575885",
               "789100591874",
               "605758584909",
               "613822393410",
               "614016217548"]
    
    var info = ""
    var detail = ""
    
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
                     evaluate(JS: "document.body.innerHTML", delayTime: 5, actionName: "获取淘宝商品ID")
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
                         for c in  try b.select("span.product-desc-span") where try c.text().hasPrefix("ID:") {
                             let id = try c.text().replacingOccurrences(of: "ID:", with: "")
                             if id.count < 10 || Int(id) == nil {
                                 continue
                             }
                             g.goodsId = id
                             break
                         }
                     }
                     if try b.attr("label") == "创建时间" {
                         let timeStr = try b.select("div.product-desc-span").first()?.text() ?? ""
                         let time = DateTime.parse(timeStr, format: "yyyy-MM-dd HH:mm")
                         g.time = (time?.timestamp ?? 0) * 1000
                     }
                 }
                 if g.goodsId.isEmpty {
                     continue
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
                    
                     self.evaluate(JS: "document.body.innerHTML", delayTime: 5, actionName: "获取淘宝商品ID")
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
     
    /*
    override func loadAllGoods(str: String) {
        super.loadAllGoods(str: str)
        shopInfo.totalCount = ids.count
        shopInfo.arrGoods = ids.map { i in
            let t = CatchedGoods()
            t.goodsId = i
            return t
        }
        catchStage = .Ready(shopInfo.arrGoods.count, false)
    }
    */
    
    override func loadSingleGoods(str: String?) {
        super.loadSingleGoods(str: str)
        if goodsIndex == shopInfo.arrGoods.count - 1 || catchStatus != .process {
            timer?.invalidate()
            timer = nil
            return
        }
        goodsIndex += 1
        fetchType = ""
        guard let url = URL(string: singleGoodsUrl) else {
            catchStatus = .error
            return
        }
        webView.load(URLRequest(url: url))
        shopInfo.arrGoods[goodsIndex].sourceUrl = singleGoodsUrl
        shopInfo.arrGoods[goodsIndex].sourceType = 2
        if goodsIndex == 0 {
            catchStage = .Transfering(0)
        }
    }
    
    override var singleGoodsUrl: String {
        return "https://item.taobao.com/item.htm?id=\(shopInfo.arrGoods[goodsIndex].goodsId)"
    }
    
    override func evaluate(JS: String, delayTime: Int, actionName: String) {
        delayTask = HWDebounceTrailing(interval: TimeInterval(delayTime), on: .global(), taskBlock: {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(JS) { [weak self] res, err in
                    guard let `self` = self, self.catchStatus == .process else { return }
                    if err != nil || res == nil {
                        Toast.showToast(msg: err!.localizedDescription)
                        return
                    }
                    if let d = res as? String, !d.isEmpty {
                        if actionName == "获取淘宝商品ID" {
                            self.loadAllGoods(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
   
    override func receiveLog(str: String) {
        if fetchType == "title" { // 获取商品标题和图片
            if indicateView.frame.origin.y > 0 {
                let vc = Tool.topVC() as? TransferGoodsViewController
                vc?.showIndicatorView()
            }
            let js = JSON(str.data(using: .utf8)!)
            let title = js["idata"]["item"]["title"].stringValue
           
            let imgs = js["idata"]["item"]["auctionImages"].arrayValue.map { $0.stringValue.addHttps() }
            shopInfo.arrGoods[goodsIndex].title = title
            shopInfo.arrGoods[goodsIndex].imgs = imgs
            webView.evaluateJavaScript("console.log(Hub.config.config.video)")
            fetchType = "video"
        } else if fetchType == "video" { // 获取商品的视频
            let js = JSON(str.data(using: .utf8)!)
            let videoThumb = js["picUrl"].stringValue.addHttps()
            if !videoThumb.isEmpty {
                let videoId = js["videoId"].stringValue
                let videoOwnerId = js["videoOwnerId"]
                let videoUrl = "http://cloud.video.taobao.com/play/u/\(videoOwnerId)/p/1/e/6/t/1/\(videoId).mp4"
                shopInfo.arrGoods[goodsIndex].video = videoUrl
                if shopInfo.arrGoods[goodsIndex].imgs.count > 0 {
                    shopInfo.arrGoods[goodsIndex].videoCover = shopInfo.arrGoods[goodsIndex].imgs.first ?? ""
                } else {
                    shopInfo.arrGoods[goodsIndex].videoCover = videoThumb
                }
            }
            webView.evaluateJavaScript("console.log(desc)")
            fetchType = "skuImage"
        } else if fetchType == "skuImage" {
            do {
                let doc = try SwiftSoup.parse(str)
                let imgs = try doc.select("img[src]")
                shopInfo.arrGoods[goodsIndex].detailImg = [String]()
                for item in imgs {
                    let imgSrc = try item.attr("src")
                    shopInfo.arrGoods[goodsIndex].detailImg?.append(imgSrc)
                }
            } catch {
                
            }
           
            webView.evaluateJavaScript("document.body.innerHTML") { res, _ in
                do {
                    let doc = try SwiftSoup.parse(res as? String ?? "")
                    if let arrAttrs = try doc.select("ul.attributes-list").first()?.children() {
                        for item in arrAttrs {
                            let texts = try item.text().split(separator: ":")
                            if texts[0] == "货号" {
                                self.shopInfo.arrGoods[self.goodsIndex].goodsNum = String(texts[1].trimmingCharacters(in: .whitespaces))
                            } else {
                                self.shopInfo.arrGoods[self.goodsIndex].detailTitle += "【\(texts[0])】\(texts[1].trimmingCharacters(in: .whitespaces))"
                            }
                        }
                    }
                
                    // 获取商品SKU
                    if let skuElements = try doc.select("div#J_isku").first() {
                        var formats = [CatchGoodsFormat]()
                        var colors = [CatchGoodsFormat]()
                        let skuListHTML = try skuElements.select("dl.tb-prop")
                        if skuListHTML.count <= 0 || skuListHTML.count > 2 {
                            let price = try doc.select("em.tb-rmb-num").first()?.text() ?? ""
                            self.shopInfo.arrGoods[self.goodsIndex].price = price
                            self.loadSingleGoods(str: nil)
                        } else {
                            let pattern = ".*background:url\\((.*\\))"
                            let regex = RegexTool.init(pattern)
                            for a in skuListHTML {
                                let skuName = try a.select("ul").first()?.attr("data-property") ?? ""
                                let skuLi = try a.select("li")
                                for b in skuLi {
                                    let imgStyle = try b.select("a").attr("style")
                                    var imgUrl = ""
                                    if !imgStyle.isEmpty {
                                        let matchs = regex.fetch(input: imgStyle)
                                        if matchs?.count ?? 0 > 0 {
                                            imgUrl = matchs?.first!.replacingOccurrences(of: "background:url(", with: "") ?? ""
                                            imgUrl.removeLast()
                                            imgUrl = imgUrl.replacingOccurrences(of: "30x30", with: "500x500")
                                        }
                                    }
                                    let propId = try b.attr("data-value")
                                    let propText = try b.select("span").text()
                                    if skuName.contains("颜色") {
                                        let s = CatchGoodsFormat(name: propText, img: imgUrl.isEmpty ? imgUrl : imgUrl.addHttps(), originId: propId, type: 1)
                                        colors.append(s)
                                    } else {
                                        let s = CatchGoodsFormat(name: propText, originId: propId, type: 0)
                                        formats.append(s)
                                    }
                                }
                            }
                            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku = CatchGoodsSku()
                            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.colors = colors
                            self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.formats = formats
                            self.webView.evaluateJavaScript("console.log(Hub.config.config.sku.valItemInfo.skuMap)")
                            self.fetchType = "sku"
                        }
                    }
                } catch {
                    self.shopInfo.arrGoods[self.goodsIndex].catchFail = .htmlParseFail(error: error)
                    _ = delay(time: 3) {
                        self.catchStatus = .error
                    }
                }
            }
        } else if fetchType == "sku", str.contains("skuId") { // 获取sku
            save(format: shopInfo.arrGoods[goodsIndex].catchGoodsSku?.formats, color: shopInfo.arrGoods[goodsIndex].catchGoodsSku?.colors) { formats, colors, err in
                if err != nil {
                    self.shopInfo.arrGoods[self.goodsIndex].catchFail = .saveFormatColorFail(err!)
                    self.catchStatus = .error
                    return
                }
                var skus = [CatchGoodsFormat]()
                let priceJs = JSON(str.data(using: .utf8)!).dictionaryValue
                for item in priceJs {
                    let color = colors.first { c in
                        item.key.contains(c.originId)
                    }
                    if color == nil { // 貌似有些没有图片的也估返回，需要过虑
                        continue
                    }
                    let format = formats.first { c in
                        item.key.contains(c.originId)
                    }
                    let price = item.value["price"].stringValue
                    var sku = CatchGoodsFormat()
                    if color != nil, format != nil {
                        sku.id = "\(color!.id);\(format!.id)"
                        sku.name = "\(color!.name) \(format!.name)"
                        sku.cname = color!.name
                        sku.img = color!.img
                        sku.price = price
                        skus.append(sku)
                    } else if format == nil, color != nil {
                        sku = color!
                        sku.cname = color!.name
                        sku.price = price
                        skus.append(sku)
                    }
                }
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.colors = colors
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.formats = formats
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku?.skus = skus
                self.loadSingleGoods(str: nil)
            }
        }
    }
    
    override func catchSingleGoods(str: String) {
        super.catchSingleGoods(str: str)
        if str.contains("pcdetail.data.get") && str.contains("item") {
            info = str
            detail = ""
        } else if str.contains("getDwdetailDesc") && detail.isEmpty {
            guard let first = str.firstIndex(of: "(") else { return }
            var jsStr = str[first..<str.endIndex]
            jsStr.removeLast()
            jsStr.removeFirst()
            detail = String(jsStr)
            self.readGoodsInfo()
        }
    }
    
    func readGoodsInfo() {
        guard let js = JSON(info.data(using: .utf8) as Any)["data"].dictionary, js.count > 0 else {
            return
        }
        guard let shopItem = js["item"]?.dictionaryValue else {
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
        
        if let detailImgsJS = JSON(detail.data(using: .utf8) as Any)["data"].dictionary, detailImgsJS.count > 0 {
            if let detailImgs = detailImgsJS["components"]?["componentData"].dictionaryValue, detailImgs.count > 0 {
                var tmpImg = [String]()
                for item in detailImgs.sorted(by: { $0.key.count != $1.key.count ? $0.key.count < $1.key.count : $0.key < $1.key }) {
                    let imgSrc = item.value["model"]["picUrl"].stringValue
                    if !imgSrc.isEmpty {
                        if shopInfo.arrGoods[goodsIndex].detailImg == nil {
                            shopInfo.arrGoods[goodsIndex].detailImg = [String]()
                        }
                        if item.key.contains("Price") {
                            tmpImg.append(imgSrc.addHttps())
                        } else {
                            shopInfo.arrGoods[goodsIndex].detailImg?.append(imgSrc.addHttps())
                        }
                    }
                }
                if shopInfo.arrGoods[goodsIndex].detailImg != nil {
                    shopInfo.arrGoods[goodsIndex].detailImg?.append(contentsOf: tmpImg)
                }
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
        if let extraInfo = js["componentsVO"]?["kernelParamsVO"]["params"].arrayValue {
            for a in extraInfo {
                if a["subText"].stringValue == "货号" {
                    let goodsNum = a["mainText"].arrayValue.first?.stringValue ?? ""
                    if !goodsNum.isEmpty {
                        shopInfo.arrGoods[goodsIndex].goodsNum = goodsNum
                    }
                    
                } else {
                    let title = a["subText"].stringValue
                    let value = a["mainText"].arrayValue.first?.stringValue ?? ""
                    if !title.isEmpty, !value.isEmpty {
                        shopInfo.arrGoods[goodsIndex].detailTitle += "【\(title)】\(value)"
                    }
                }
            }
        }
        
        var tmallSkuColor = [CatchGoodsFormat]()
        var tmallSkuFormat: [CatchGoodsFormat]?
        
        guard let skuBase = js["skuBase"]?["props"].arrayValue else {
            // 没人sku记单个价格
            if let price = js["price"]?["price"]["priceText"].stringValue,!price.isEmpty {
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
        guard let skuIds = js["skuBase"]?["skus"].arrayValue else {
            return
        }
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
        
        guard let skuPrices = js["skuCore"]?["sku2info"].dictionaryValue else {  return }
        for a in skuPrices {
            let longId = a.key
            for b in tmpDict where b.value == longId{
                let price = a.value["price"]["priceText"].stringValue
                let stock = Int(a.value["quantity"].stringValue)
                for i in 0..<skuMap.count { // 将价格信息转移到skumap上
                    if skuMap[i].isPlanar {
                        if b.key.contains(skuMap[i].originColorId ?? ""), b.key.contains(skuMap[i].originFormatId ?? "") {
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
