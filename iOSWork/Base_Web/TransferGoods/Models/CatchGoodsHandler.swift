//
//  CatchGoodsHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/27.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftyJSON
import WebKit
import GrandKit

class CatchGoods: NSObject {
    enum CatchStage {
        case Begin, // 开始
             ShopInfo(String, String, TransferGoodsPlatform), // 店铺信息
             GoodsNum(Int), // 获取商品个数
             Ready(Int, Bool), // 准备就绪
             Transfering(Int), // 正在搬家,显示第几个
             Success, // 搬家成功,通常是全部功能，没有失败的商品
             Fail(Int, Int), // 搬家失败
             FailNoVip(Int, Int), // 搬家失败(原因：没有会员)
             FailOverCapacity(Int, Int), // 搬家失败(原因：容量超出)
             Cancel(Int, Int), // 用户取消
             noGoodsToTransfer // 没有商品需要保存
        
        var desc: String {
            switch self {
            case .Begin:
                return "准备开始搬家"
            case let .ShopInfo(a, _, p):
                return "搬家的店铺信息:\(a),平台是\(p.rawValue)"
            case .GoodsNum(let a):
                return "获取到商品数量\(a)个"
            case .Ready(let a, _):
                return "获取到商品总数\(a)个"
            case .Transfering(let a):
                return "正在搬家，搬到第\(a)个"
            case .Success:
                return "搬家成功"
            case .Fail(_, let b):
                return "搬家失败，失败了\(b)个"
            case .FailNoVip(_, let b):
                return "搬家失败，失败了\(b)个"
            case .FailOverCapacity(_, let b):
                return "搬家失败，失败了\(b)个"
            case .Cancel(_, let b):
                return "搬家取消，还有\(b)个没有搬"
            case .noGoodsToTransfer:
                return "全是最新商品。不需要搬家"
            }
        }
        
        var isTransfer: Bool {
            switch self {
            case .Transfering:
                return true
            default:
                return false
            }
        }
    }

    enum CatchingStatus {
        case process, cancel, pause, error, resume
    }
    
    var previousLastGoodsTime = 0 // 上次保存商品最后商品的时间
    var previousLastGoodsId = "" // 上次保存商品最后的id
    var catchStatus: CatchingStatus = .process {
        didSet {
            timer?.invalidate()
            timer = nil
            switch catchStatus {
            case .process:
                loadSingleGoods()
            case .cancel:
                uploadQuene.cancelAllOperations()
                let finishedGoods = shopInfo.arrGoods.filter { c in
                    c.isCatched
                }
                catchStage = .Cancel(finishedGoods.count, shopInfo.arrGoods.count - finishedGoods.count)
            case .error:
                uploadQuene.cancelAllOperations()
                for i in goodsIndex..<shopInfo.arrGoods.count {
                    if shopInfo.arrGoods[i].catchFail == nil {
                        shopInfo.arrGoods[i].catchFail = .chanFail
                    }
                }
                showCatchError()
            case .pause:
                uploadQuene.cancelAllOperations()
            case .resume:
                let count = shopInfo.arrGoods.filter { c in
                    c.isCatched
                }.count
                goodsIndex = count - 1 // 从上次保存的商品再次开始.需要要先减去1
                catchStatus = .process
                loadSingleGoods()
            }
        }
    }
    
    var indicateView: TransferIndicatorView!
    var goodsIndex = -1
    var webView: WKWebView
    var delayTask: HWDebounceTrailing?
    var fetchType = ""
    var shopInfo: TransferShopInfo
    var timer: GrandTimer? // 有时当时页面网页出现异常卡住了，比如淘宝登录后商品列表没刷出商品
    var stageCount = 0
    var stageCountUpperLimit = 25 // 当前阶段停留的上限制，超时刷新，因为还要加上滑动验证，时间加长点
    var goodsCountUpperLimit = 3000 // 可以搬家商品个数的上限
    var isRefreshed = false // 没有加载出来的页面最多只加载一次
    var uploadQuene: SKOperationQueue!
    var fail: CatchedGoods.FailError?
    var catchStage = CatchStage.Begin {
        didSet {
            DispatchQueue.main.async {
                self.indicateView.stage = self.catchStage
            }
        }
    }

    var isUploadingGoods: Bool { // 是否有商品在上传
        shopInfo.arrGoods.contains { $0.isUploading }
    }

    init(shopInfo: TransferShopInfo, webView: WKWebView) {
        self.shopInfo = shopInfo
        self.webView = webView
        uploadQuene = SKOperationQueue(qualityOfService: .default, maxConcurrentOperationCount: 1, underlyingQueue: nil, name: nil, startSuspended: false)
        uploadQuene.maxConcurrentOperationCount = 1
    }
    
    func getShopInfo(str: String) {
        UIApplication.shared.isIdleTimerDisabled = true
        getPreviousSavedGoods()
        timer = GrandTimer.after(.fromSeconds(1), block: { [weak self] in
            self?.tick()
        })
        timer?.fire()
    }

    func loadAllGoods(str: String) {
        timer?.invalidate()
        timer = nil
        stageCount = 0
        if let vc = Tool.topVC() as? TransferGoodsViewController {
            if vc.vIndicator.frame.origin.y > 0 {
                vc.showIndicatorView()
            }
        }
    }
   
    @objc func tick() {
        stageCount += 1
        print("搬家--正在计时\(stageCount)")
        if stageCount > stageCountUpperLimit {
            if isRefreshed {
                if goodsIndex >= 0 {
                    webView.evaluateJavaScript("document.body.innerHTML") { [weak self] result, _ in
                        guard let self = self else { return }
                        // 判断滑动
                        if let html = result as? String, html.contains("滑块") || (self.webView.title ?? "").contains("验证码") || html.contains("验证") {
                            if let vc = Tool.topVC() as? TransferGoodsViewController {
                                vc.hideIndicatorView()
                            }
                        } else {
                            self.catchStatus = .error
                            #if WGTEST
                            if let vc = Tool.topVC() as? TransferGoodsViewController {
                                vc.hideIndicatorView()
                            }
                            #endif
                            showErrorAlert()
                        }
                    }
                } else {
                    showErrorAlert()
                }
                
                timer?.invalidate()
                timer = nil
            } else {
                if goodsIndex >= 0 {
                    webView.reload()
                    stageCount = 0
                    isRefreshed = true
                } else {
                    timer?.invalidate()
                    stageCount = 0
                    isRefreshed = true
                   
                }
            }
        }
    }
    
    func showErrorAlert() {
    }
    
    func loadSingleGoods(str: String? = nil) {
        if goodsIndex >= 0 && catchStatus == .process && !shopInfo.arrGoods[goodsIndex].isCatched {
            let quene = GoodsSaveQueue(goods: shopInfo.arrGoods[goodsIndex], index: goodsIndex, delete: self)
            quene.name = shopInfo.arrGoods[goodsIndex].goodsId
            print("搬家---------添加商品搬家队列")
            uploadQuene.addOperation(quene)
        }
        
        stageCount = 0
        isRefreshed = false
        if timer == nil {
            timer = GrandTimer.after(.fromSeconds(1), block: { [weak self] in
                self?.tick()
            })
            timer?.fire()
        }
    }
        
    func evaluate(JS: String, delayTime: Int, actionName: String) {}
    
    func catchSingleGoods(str: String) {
    }
    
    func catchSingleGoodsDetail(str: String) {}
    
    func receiveLog(str: String) {}
    
    var singleGoodsUrl: String {
        return ""
    }
    
    func save(format: [CatchGoodsFormat]?, color: [CatchGoodsFormat]?, completed: @escaping ((_ formats: [CatchGoodsFormat], _ colors: [CatchGoodsFormat], _ err: String?) -> Void)) {
       
    }
        
    func retry() {
        shopInfo.arrGoods = shopInfo.arrGoods.filter { c in
            c.catchFail != nil
        }
        for i in 0..<shopInfo.arrGoods.count { // 清空fail状态
            shopInfo.arrGoods[i].clear()
        }
        uploadQuene.clearTask()
        shopInfo.totalCount = shopInfo.arrGoods.count
        indicateView.totalNum = shopInfo.arrGoods.count
        goodsIndex = -1
        fetchType = ""
        catchStatus = .process
    }
    
    func showCatchError() {
        timer?.invalidate()
        timer = nil
        let failGoods = shopInfo.arrGoods.filter { c in
            c.catchFail != nil
        }
        if failGoods.count > 0 {
            // 没有vip必然会是失败的
            if let t = fail {
                if !t.isVip {
                    catchStage = .FailNoVip(shopInfo.arrGoods.count - failGoods.count, failGoods.count)
                   
                } else if t.isOverCapacityFail {
                    catchStage = .FailOverCapacity(shopInfo.arrGoods.count - failGoods.count, failGoods.count)
                } else {
                    catchStage = .Fail(shopInfo.arrGoods.count - failGoods.count, failGoods.count)
                }
            } else {
                catchStage = .Fail(shopInfo.arrGoods.count - failGoods.count, failGoods.count)
            }
        } else {
            catchStage = .Success
        }
    }
    
    func getPreviousSavedGoods() {
       
    }
}

extension CatchGoods: SaveGoodsDelegate {
    func fail(err: CatchedGoods.FailError) {
        fail = err
        catchStatus = .error
    }

    func finishSave(index: Int) {
        catchStage = .Transfering(index + 1)
        if index == shopInfo.arrGoods.count - 1 {
            timer?.invalidate()
            timer = nil
            catchStage = .Success
        }
        uploadQuene.removeTask(id: shopInfo.arrGoods[index].goodsId)
    }
    
    func getShopInfo() -> TransferShopInfo.ShopInfo {
        return shopInfo.shopInfo
    }
    
    func stop() {}
}
