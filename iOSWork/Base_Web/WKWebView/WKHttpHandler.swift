//
//  WKHttpHandler.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

import SwiftyJSON
import UIKit
import WebKit

@objc class WKHttpHandler: NSObject, WKURLSchemeHandler {
    var taskMap = NSCache<NSString, NSString>()
    // webview 结束重用的时候会设置为true
    lazy var syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        self.taskMap.setObject("", forKey: urlSchemeTask.description as NSString)
        self.syncQueue.addOperation {
            self.directRequestWith(task: urlSchemeTask, filename: urlSchemeTask.request.url!.absoluteString)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("\(urlSchemeTask.description)已经stop")
        self.taskMap.removeObject(forKey: urlSchemeTask.description as NSString)
    }
}

extension WKHttpHandler {
    func taskTrysend(task: WKURLSchemeTask, response: URLResponse, data: Data) {
        if self.taskMap.object(forKey: task.description as NSString) == nil {
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
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: request) { data, response, error in
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
            
            // 拦截1688商品列表。
            if let d = data, let u = httpResp.url, u.absoluteString.contains("mtop.alibaba.alisite.cbu.server.moduleasyncservice"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {}
            }
            
            // 天猫商品信息获取
            if let d = data, let u = httpResp.url, u.absoluteString.contains("mtop.taobao.detail.data"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    
                }
            }
          
            // 获取抖店商品信息
            if let d = data, let u = httpResp.url, u.absoluteString.contains("aweme/v2/shop/promotion/pack"), let str = String(data: d, encoding: .utf8),!str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {}
            }
            
            self.taskTrysend(task: task, response: response!, data: data!)
            callback?(data, response, true)
        }
        dataTask.resume()
    }
}
