//
//  PDDCatchHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/24.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import GrandKit

class PDDCatchHandler: CatchGoods {
    // PDD目前不可用
    override func getShopInfo(str: String) {
        let js = JSON(str.data(using: .utf8))
        let name = js["mall_name"].stringValue
        let img = js["logo"].stringValue
        shopInfo.shopName = name
        shopInfo.shopIcon = img
    }
    
    override func evaluate(JS: String, delayTime: Int, actionName: String) {
        delayTask = HWDebounceTrailing(interval: TimeInterval(delayTime), on: .global(), taskBlock: {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(JS) { res, err in
                    if err != nil || res == nil {
                        if err == nil, actionName == "下一页" {
                            self.evaluate(JS: "document.body.innerHTML", delayTime: 3, actionName: "PDD商品列表")
                        } else {
                            Toast.showToast(msg: err?.localizedDescription ?? "evaluateJS出现错误")
                        }
                        return
                    }
                    if let d = res as? String, !d.isEmpty {
                        if actionName == "PDD商品列表" {
                            self.loadAllGoods(str: d)
                        }
                    }
                }
            }
        })
        delayTask?.call()
    }
    
    override func loadAllGoods(str: String) {
        do {
            let doc = try SwiftSoup.parse(str)
            let numReg = RegexTool("\\d+")
            guard let pageLi = try doc.select("ul[data-testid=beast-core-pagination]").first()?.children() else { return }
            for item in pageLi {
                if try item.className().contains("PGT_totalText") {
                    let txt = try item.text()
                    let num = numReg.fetch(input: txt)?.first ?? ""
                    shopInfo.totalCount = Int(num) ?? 0
                }
                if try item.className().contains("PGT_pagerItemActive") {
                    let txt = try item.text()
                    shopInfo.totalCount = Int(txt) ?? 0
                }
            }
           
            if let table = try doc.select("table").last() {
                let trs = try table.select("tbody > tr")
                for row in trs {
                    let td = try row.select("td")
                    var goods = CatchedGoods()
                    for col in td.enumerated() {
                        if col.offset == 1 { // 商品名和id
                            let id = try col.element.select("span.goods-id ").first()?.select("span").first()?.text() ?? ""
                            goods.goodsId = id
                        }
                        if col.offset == 8 {
                            let timeStr = try col.element.text().prefix(16)
                            let time = DateTime.parse(String(timeStr))
                            goods.time = time?.timestamp ?? 0
                        }
                    }
                    shopInfo.arrGoods.append(goods)
                }
            }
            if shopInfo.arrGoods.count < shopInfo.totalCount {
                evaluate(JS: "document.getElementsByTagName('li').forEach(function(element){if (element.dataset['testid']==='beast-core-pagination-next')element.click()})", delayTime: 1, actionName: "下一页") // 这个制作貌似没有返回，或者是返回出错
            } else {
                loadSingleGoods()
            }
        } catch {
            return
        }
    }

    override func loadSingleGoods(str: String? = nil) {
        if goodsIndex == shopInfo.arrGoods.count - 1 {
            Toast.showToast(msg: "商品已经全部取完")
            return
        }
        goodsIndex += 1
        fetchType = ""
        webView.load(URLRequest(url: URL(string: "https://m.pinduoduo.net/goods.html?goods_id=\(shopInfo.arrGoods[goodsIndex].goodsId)")!))
    }
    
    override func receiveLog(str: String) {
        if fetchType == "店铺信息" {
            getShopInfo(str: str)
        }
    }
}
