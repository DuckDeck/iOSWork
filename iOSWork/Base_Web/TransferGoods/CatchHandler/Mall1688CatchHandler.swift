//
//  Mall1688CatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/20.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit

class Mall1688CatchHandler: CatchGoods {
    // 1688目前不可用
    override func getShopInfo(str: String) {
        do {
            let doc = try SwiftSoup.parse(str)
            let userInfoBox = try doc.select("div.user-box").first()
            let img = try userInfoBox?.select("img").first()?.attr("src") ?? ""
            let title = try userInfoBox?.select("span.user-name").first()?.children().first()?.text() ?? ""
            shopInfo.shopIcon = img.addHttps()
            shopInfo.shopName = title
            catchStage = .ShopInfo("1688店", "", .Mall1688)
        } catch {
            
        }
    }
    
    override func loadAllGoods(str: String) {
        let jsGoods = JSON(str.data(using: .utf8)!)["data"]["data"].dictionaryValue
        if shopInfo.totalCount == 0 {
            shopInfo.totalCount = jsGoods["totalCount"]?.intValue ?? 0
        }
        var isOver = false
        if let jsIds = jsGoods["offerModuleList"]?.arrayValue {
            for item in jsIds {
                let g = CatchedGoods()
                g.goodsId = item["id"].stringValue
                
                let timeStr = item["gmtCreate"].stringValue
                let time = DateTime.parse(timeStr)
                g.time = (time?.timestamp ?? 0) * 1000
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
        }
        
        if shopInfo.arrGoods.count < shopInfo.totalCount && !isOver {
            let js = "scrollTo(0,10000000)"
            _ = delay(time: 2) {
                self.webView.evaluateJavaScript(js)
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
                } // 商品时间排序
            } else {
                catchStage = .noGoodsToTransfer
            }
        }
    }
    
    override func loadSingleGoods(str: String?) {
        super.loadSingleGoods(str: str)
        if goodsIndex == shopInfo.arrGoods.count - 1 {
            timer?.invalidate()
            timer = nil
            return
        }
        goodsIndex += 1
        let vc = Tool.topVC() as? TransferGoodsViewController
        vc?.switchWebView(type: 1)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
        webView.load(URLRequest(url: URL(string: singleGoodsUrl)!))
        shopInfo.arrGoods[goodsIndex].sourceUrl = singleGoodsUrl
        shopInfo.arrGoods[goodsIndex].sourceType = 1
        if goodsIndex == 0 {
            catchStage = .Transfering(0)
        }
    }
    
    override var singleGoodsUrl: String { "https://detail.1688.com/offer/\(shopInfo.arrGoods[goodsIndex].goodsId).html" }
    
    override func evaluate(JS: String, delayTime: Int, actionName: String) {
        delayTask = HWDebounceTrailing(interval: TimeInterval(delayTime), on: .global(), taskBlock: {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(JS) { res, err in
                    if err != nil || res == nil {
                        Toast.showToast(msg: err!.localizedDescription)
                        return
                    }
                    if let d = res as? String, !d.isEmpty {
                        if actionName == "1688店铺标题" {
                            self.getShopInfo(str: d)
                            self.evaluate(JS: "document.getElementsByClassName('company-name')[0].href", delayTime: 1, actionName: "1688店铺URL")
                        } else if actionName == "1688店铺URL" {
                            self.webView.load(URLRequest(url: URL(string: d)!))
                            // 这里会卡住，没有商品会打不开
                        } else if actionName == "1688商品内容" {
                            self.catchSingleGoods(str: d)
                        } else if actionName == "1688商品详情图片" {
                            self.catchGoodsDetailImage(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
    
    override func catchSingleGoods(str: String) {
        do {
            let doc = try SwiftSoup.parse(str)
            // 获取标题
            let titlePart1 = try doc.select("span.title-first-text").text()
            let titlePart2 = try doc.select("span.title-second-text").text()
            shopInfo.arrGoods[goodsIndex].title = titlePart1 + titlePart2
            // 获取视频URL和图片
            let imgs = try doc.select("img.full-img")
            if imgs.count > 0 {
                for item in imgs {
                    let src = try item.attr("src")
                    if !src.isEmpty {
                        if shopInfo.arrGoods[goodsIndex].imgs.count <= 9 {
                            shopInfo.arrGoods[goodsIndex].imgs.append(src.addHttps())
                        } else {
                            if shopInfo.arrGoods[goodsIndex].detailImg == nil {
                                shopInfo.arrGoods[goodsIndex].detailImg = [String]()
                            }
                            shopInfo.arrGoods[goodsIndex].detailImg?.append(src.addHttps())
                        }
                    }
                }
            }
            if let videoBtn = try doc.select("img.video-play-btn").first(), let nextImg = try videoBtn.nextElementSibling() {
                shopInfo.arrGoods[goodsIndex].videoCover = try nextImg.attr("src").addHttps()
            }
            // 获取详情图片，在iframe里面
            evaluate(JS: "document.getElementsByClassName(\"desc-myIframe\")[0].contentDocument.documentElement.outerHTML", delayTime: 1, actionName: "1688商品详情图片")
            
            let video = try doc.select("video")
            for item in video.enumerated() {
                let src = try item.element.attr("src")
                let poster = try item.element.attr("poster")
                if item.offset == 0 {
                    if shopInfo.arrGoods[goodsIndex].videoCover.isEmpty {
                        shopInfo.arrGoods[goodsIndex].videoCover = poster
                    }
                    if src.hasPrefix("http") {
                        shopInfo.arrGoods[goodsIndex].video = src
                    }
                } else {
                    if src.hasPrefix("http") {
                        if shopInfo.arrGoods[goodsIndex].detailVideo == nil {
                            shopInfo.arrGoods[goodsIndex].detailVideo = [String: String]()
                        }
                        shopInfo.arrGoods[goodsIndex].detailVideo?[src] = poster
                    }
                }
            }
            
        }
        catch {
            
        }
    }
    
    func catchGoodsDetailImage(str: String) {
        super.catchSingleGoods(str: str)
        do {
            shopInfo.arrGoods.append(CatchedGoods())
            let doc = try SwiftSoup.parse(str)
            // 获取标题
            let imgs = try doc.select("div > p > span > img")
            for item in imgs {
                let src = try item.attr("src")
                if shopInfo.arrGoods[goodsIndex].detailImg == nil {
                    shopInfo.arrGoods[goodsIndex].detailImg = [String]()
                }
                if !src.isEmpty {
                    shopInfo.arrGoods[goodsIndex].detailImg?.append(src)
                }
            }
            
        } catch {
            
        }
        
        webView.evaluateJavaScript("console.debug(__INIT_DATA.globalData.skuModel)")
        fetchType = "sku"
    }
    
    override func receiveLog(str: String) {
        if fetchType == "sku" { // 获取商品标题和图片
            let js = JSON(str.data(using: .utf8)!)
            if let arrSkus = js["skuInfoMap"].dictionary {
                var goodSku = CatchGoodsSku()
                goodSku.formats = [CatchGoodsFormat]()
                goodSku.skus = [CatchGoodsFormat]()
                for item in arrSkus {
                    var skuMap = CatchGoodsFormat()
                    skuMap.stock = item.value["canBookCount"].intValue
                    skuMap.price = item.value["price"].stringValue
                    
                    var formatName = item.value["secondProp"].string
                    if formatName == nil {
                        formatName = item.value["specAttrs"].string
                    }
                    var name = formatName!
                    let colorName = item.value["firstProp"].string
                    var format = CatchGoodsFormat()
                    format.name = formatName!
                    goodSku.formats?.append(format)
                    if colorName != nil {
                        if goodSku.colors == nil {
                            goodSku.colors = [CatchGoodsFormat]()
                        }
                        var color = CatchGoodsFormat()
                        color.name = colorName!
                        goodSku.colors?.append(color)
                        name = "\(colorName!) \(name)"
                    }
                    skuMap.name = name
                    goodSku.skus?.append(skuMap)
                }
                shopInfo.arrGoods[goodsIndex].catchGoodsSku = goodSku
                webView.evaluateJavaScript("console.debug(__INIT_DATA.data)")
                fetchType = "skuImage"
            }
            
        } else if fetchType == "skuImage" {
            let js = JSON(str.data(using: .utf8)!).dictionaryValue
            var jsImages: [JSON]?
            var jsGoodsNum: [JSON]?
            for item in js {
                if item.value["componentType"].stringValue == "@ali/cmod-od-wap-main-pic" {
                    jsImages = item.value["data"]["skuImages"].arrayValue
                }
                if item.value["componentType"].stringValue == "@ali/cmod-od-wap-offer-attribute" {
                    jsGoodsNum = item.value["data"]["propsList"].arrayValue
                }
            }
            
            if let pros = jsGoodsNum, pros.count > 0 {
                for item in pros {
                    if item["name"].stringValue == "货号" {
                        let value = item["value"].stringValue
                        shopInfo.arrGoods[goodsIndex].goodsNum = value
                    } else if !item["name"].stringValue.isEmpty && !item["value"].stringValue.isEmpty {
                        shopInfo.arrGoods[goodsIndex].detailTitle = "【\(item["name"].stringValue.isEmpty)】\(item["value"].stringValue.isEmpty)"
                    }
                }
            }
            
            if let imgs = jsImages, imgs.count > 0, shopInfo.arrGoods[goodsIndex].catchGoodsSku?.skus?.count ?? 0 > 0 {
                for i in 0..<shopInfo.arrGoods[goodsIndex].catchGoodsSku!.skus!.count {
                    for b in imgs {
                        if shopInfo.arrGoods[goodsIndex].catchGoodsSku!.skus![i].name.contains(b["name"].stringValue) {
                            shopInfo.arrGoods[goodsIndex].catchGoodsSku!.skus![i].img = b["imgUrl"].stringValue
                        }
                    }
                }
            }
            
            save(format: shopInfo.arrGoods[goodsIndex].catchGoodsSku?.formats, color: shopInfo.arrGoods[goodsIndex].catchGoodsSku?.colors) { formats, colors, err in
                if err != nil {
                    self.shopInfo.arrGoods[self.goodsIndex].catchFail = .saveFormatColorFail(err!)
                    self.catchStatus = .error
                    return
                }
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.formats = formats
                self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.colors = colors
                for i in 0..<self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus!.count {
                    let ida = formats.first { c in
                        self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus![i].name.contains(c.name)
                    }
                    let idb = colors.first { c in
                        self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus![i].name.contains(c.name)
                    }
                    
                    var id = ida!.id
                    if idb != nil {
                        id = "\(idb!.id);\(id)"
                    }
                    self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus![i].id = id
                    let price = self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus![i].price
                    if !price.isEmpty {
                        self.shopInfo.arrGoods[self.goodsIndex].catchGoodsSku!.skus![i].price = price
                    }
                }
              
                self.loadSingleGoods(str: nil)
            }
        }
    }
}
