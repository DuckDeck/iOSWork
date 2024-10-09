//
//  WKHttpHandler.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/11.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftyJSON
import WebKit

@objc class WKHttpHandler: NSObject, WKURLSchemeHandler {
    var taskMap = NSCache<NSString, NSString>()
    // webview 结束重用的时候会设置为true
    lazy var syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var operationQueue: OperationQueue?
    
    lazy var session: URLSession = {
        self.operationQueue = OperationQueue()
        self.operationQueue?.maxConcurrentOperationCount = 1
        let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: self.operationQueue)
        return urlSession
    }()
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        taskMap.setObject("", forKey: urlSchemeTask.description as NSString)
        syncQueue.addOperation {
            self.directRequestWith(task: urlSchemeTask, filename: urlSchemeTask.request.url!.absoluteString)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("\(urlSchemeTask.description)已经stop")
        taskMap.removeObject(forKey: urlSchemeTask.description as NSString)
    }
    
    @objc func removeAllActivitiesSchemeTasks() {
        self.session.invalidateAndCancel()
        self.taskMap.removeAllObjects()
        self.syncQueue.cancelAllOperations()
        self.operationQueue?.cancelAllOperations()
        self.operationQueue = nil
    }
    
    deinit {
        print("WKHttpHandler 回收")
    }
}

extension WKHttpHandler: URLSessionTaskDelegate {
    func taskTrysend(task: WKURLSchemeTask, response: URLResponse, data: Data) {
        if taskMap.object(forKey: task.description as NSString) == nil {
            return
        }
        ObjcTry.tryOcException {
            task.didReceive(response)
            task.didReceive(data)
            task.didFinish()
        } catch: { err in
            print(err.description)
        }
    }

    func directRequestWith(task: WKURLSchemeTask, filename: String, callback: ((Data?, URLResponse?, Bool) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: filename)!)
        request.allHTTPHeaderFields = task.request.allHTTPHeaderFields
        request.httpBody = task.request.httpBody
        request.httpMethod = task.request.httpMethod
        request.httpShouldHandleCookies = true
        let dataTask = self.session.dataTask(with: request) { data, response, error in
            if self.taskMap.object(forKey: task.description as NSString) == nil {
                return
            }
            guard let httpResp = response as? HTTPURLResponse else { return }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResp.allHeaderFields as! [String: String], for: httpResp.url!)
            if cookies.count > 0 {
                DispatchQueue.main.async {
                    for cook in cookies {
                        WKWebsiteDataStore.default().httpCookieStore.setCookie(cook, completionHandler: nil)
                    }
                }
            }

            guard error == nil else {
                task.didFailWithError(error!)
                return
            }

            // 淘宝店铺信息
            if let d = data, let u = httpResp.url, u.absoluteString.contains("mtop.taobao.jdy.resource.shop.info"), let str = String(data: d, encoding: .utf8),!str.isEmpty {
                DispatchQueue.main.async {
                    if let vc = Tool.topVC() as? TransferGoodsViewController {
                        vc.catchGoods.getShopInfo(str: str)
                    }
                }
            }

            // 拦截1688商品列表。
            if let d = data, let u = httpResp.url, u.absoluteString.contains("mtop.alibaba.alisite.cbu.server.moduleasyncservice"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    if let vc = Tool.topVC() as? TransferGoodsViewController {
                        if vc.action == "load1688list" {
                            if str.contains("SUCCESS") {
                                if vc.vIndicator.frame.origin.y > 0 {
                                    vc.showIndicatorView()
                                }
                                vc.catchGoods.loadAllGoods(str: str)
                            } else {
                                vc.hideIndicatorView()
                            }
                        }
                    }
                }
            }
            // 天猫商品信息获取
            if let d = data, let u = httpResp.url, u.absoluteString.contains("mtop.taobao.detail.data"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    if let vc = Tool.topVC() as? TransferGoodsViewController {
                        if str.contains("SUCCESS") {
                            if vc.vIndicator.frame.origin.y > 0 {
                                vc.showIndicatorView()
                            }
                            vc.catchGoods.catchSingleGoods(str: str)
                        } else {
                            vc.hideIndicatorView()
                        }
                    }
                }
            }

            if let d = data, let u = httpResp.url, (u.absoluteString.contains("mtop.taobao.pcdetail.data") || u.absoluteString.contains("mtop.taobao.detail.getdesc")), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    if let vc = Tool.topVC() as? TransferGoodsViewController {
                        if str.contains("SUCCESS") {
                            if vc.vIndicator.frame.origin.y > 0 {
                                vc.showIndicatorView()
                            }
                            vc.catchGoods.catchSingleGoods(str: str)
                            if u.absoluteString.contains("mtop.taobao.pcdetail.data"){
                                vc.scrollToBottom()
                            }
                        } else {
                            vc.hideIndicatorView()
                        }
                    }
                }
            }

            // 获取抖店商品信息
            if let d = data, let u = httpResp.url, u.absoluteString.contains("aweme/v2/shop/promotion/pack"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    if let vc = Tool.topVC() as? TransferGoodsViewController {
                        if !str.contains("detail_info"), !str.contains("promotion_v2") {
                            vc.hideIndicatorView()
                        } else {
                            if vc.vIndicator.frame.origin.y > 0 {
                                vc.showIndicatorView()
                            }
                            vc.catchGoods.catchSingleGoods(str: str)
                        }
                    }
                }
            }

            self.taskTrysend(task: task, response: response!, data: data!)
            callback?(data, response, true)
        }
        dataTask.resume()
    }
}
