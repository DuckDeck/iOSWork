//
//  TransferGoodsViewController.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/10.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON
import WebKit

class TransferGoodsViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    var catchGoods: CatchGoods!
    var platform = TransferGoodsPlatform.TaoBao
    @objc var platformName: NSString = "" {
        didSet {
            switch platformName {
            case "taobao":
                platform = .TaoBao
            case "tmall":
                platform = .TMall
            case "1688":
                platform = .Mall1688
            case "doudian":
                platform = .Douyin
            case "kuaishou":
                platform = .KuaiShou
            default:
                platform = .TaoBao
            }
        }
    }

    var delayTask: HWDebounceTrailing?
    var webView: WKWebView!
    var shopId = ""
    var webViewType = 1 // 表示不拦截，0表示拦截
    var urlStack = [String]()
    var action = ""
    var vIndicator = TransferIndicatorView(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight))
    var maskView = UIView(frame: CGRect(x: 0, y: UIDevice.topAreaHeight + 44, width: ScreenWidth, height: ScreenHeight - UIDevice.topAreaHeight - 44))
    var refreshCount = 0
    var observer: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        
     
//        navigationBar.wg_setRightButton(with: UIImage(named: "service_icon")!)
//        navigationBar.onClickRightButton = { [weak self] in
//            self?.customService()
//        }
        if platform == .TaoBao || platform == .TMall {
            webViewType = 0
        }
        webView = createWebView(useHandle: webViewType == 0)
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.left.right.bottom.equalTo(0)
        }
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.height.equalTo(2.5)
        }
        var shopInfo = TransferShopInfo()
        shopInfo.platform = platform
        if !shopId.isEmpty {
            shopInfo.shopId = shopId
        }
        
        switch platform {
        case .TaoBao:
            catchGoods = TaobaoCatchHandler(shopInfo: shopInfo, webView: webView)
            view.addSubview(vTaobaoHint)
            vTaobaoHint.snp.makeConstraints { make in
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.top.equalTo(UIDevice.topAreaHeight + 56)
                make.height.equalTo(48)
            }
        case .Mall1688:
            catchGoods = Mall1688CatchHandler(shopInfo: shopInfo, webView: webView)
        case .TMall:
            catchGoods = TMallCatchHandler(shopInfo: shopInfo, webView: webView)
        case .KuaiShou:
            catchGoods = KuaiShouCatchHandler(shopInfo: shopInfo, webView: webView)
        case .Douyin:
            catchGoods = DouYinCatchHandler(shopInfo: shopInfo, webView: webView)
        case .PDD:
            catchGoods = PDDCatchHandler(shopInfo: shopInfo, webView: webView)
        }
        catchGoods.indicateView = vIndicator
        load(url: catchGoods.shopInfo.platform.homtUrl)
        maskView.isHidden = true
        maskView.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(maskView)
        view.addSubview(vIndicator)
    }
    
    func back(animate: Bool = true) {
        if webView != nil {
            webView.stopLoading()
            if let handler = webView.configuration.urlSchemeHandler(forURLScheme: "https") as? WKHttpHandler {
                handler.removeAllActivitiesSchemeTasks()
            }
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "logging")
            webView.removeFromSuperview()
            vIndicator.removeFromSuperview()
            catchGoods.catchStatus = .cancel
            catchGoods.timer?.invalidate()
            catchGoods.timer = nil
            catchGoods.delayTask?.invalidate()
            catchGoods.delayTask = nil
            catchGoods = nil
            delayTask?.invalidate()
            delayTask = nil
            webView = nil
            UIApplication.shared.isIdleTimerDisabled = false
        }
        navigationController?.popViewController(animated: animate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observer = nil
    }
    
    func load(url: String) {
        if catchGoods.shopInfo.platform == .Mall1688, !catchGoods.shopInfo.shopId.isEmpty {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
            webView.load(URLRequest(url: URL(string: "https://\(catchGoods.shopInfo.shopId).1688.com/page/offerlist.htm")!))
        } else {
            if let u = URL(string: url) {
                webView.load(URLRequest(url: u))
            }
        }
    }
    
    func logOut() {
        #if WGTEST
        return
        #endif
        var name = ""
        switch catchGoods.shopInfo.platform {
        case .TaoBao, .TMall:
            name = "taobao"
        case .Douyin:
            name = "jinritemai"
        case .KuaiShou:
            name = "kwaixiaodian"
        default:
            break
        }
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for i in 0 ..< cookies.count {
                if cookies[i].domain.contains(name) {
                    HTTPCookieStorage.shared.deleteCookie(cookies[i])
                }
            }
        }
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records.filter { $0.displayName.contains(name) }, completionHandler: {})
        }
    }
    
    @objc func customService() {
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
    
    internal func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)")
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let info = navigationAction.targetFrame,!info.isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.alwaysBounceHorizontal = false
        progressView.setProgress(0, animated: false)
        webView.evaluateJavaScript("document.title") { title, _ in
            if let t = title as? String, t == "502" {
                webView.reload()
            }
        }
        switch platform {
        case .TaoBao:
            if webView.url!.absoluteString.contains("QnworkbenchHome") {
                vTaobaoHint.removeFromSuperview()
                load(url: "https://myseller.taobao.com/home.htm/SellManage/on_sale?current=1&pageSize=20&tableSort.upShelfDate_m=desc")
                showIndicatorView()
            } else if webView.url?.absoluteString.contains("SellManage/on_sale") ?? false {
                catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 6, actionName: "获取淘宝商品ID")
            } else if webViewType == 1, webView.url!.absoluteString.contains("m.taobao.com/awp/core/detail") || webView.url!.absoluteString.contains("item.taobao.com") {
                checkCaptcha { haveCaptcha, _ in
                    if haveCaptcha {
                        self.hideIndicatorView()
                        self.catchGoods.timer?.invalidate()
                        self.catchGoods.timer = nil
                    } else {
                        self.catchGoods.fetchType = "title"
                        self.webView.evaluateJavaScript("console.log(g_config)")
                    }
                }
            }
                
        case .Mall1688:
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            print(self.webView.url!.absoluteString)
        case .TMall:
            if webView.url!.absoluteString.contains("QnworkbenchHome") {
                vTaobaoHint.removeFromSuperview()
                load(url: "https://myseller.taobao.com/home.htm/SellManage/on_sale?current=1&pageSize=20&tableSort.upShelfDate_m=desc")
                showIndicatorView()
            } else if webView.url?.absoluteString.contains("SellManage/on_sale") ?? false {
                catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 4, actionName: "获取天猫商品ID")
            }
        case .KuaiShou:
            delayTask = HWDebounceTrailing(interval: 3, taskBlock: { [weak self] in
                guard let `self` = self else { return }
                if self.webView == nil {
                    return
                }
                if self.webView.url!.absoluteString.contains("list"), self.webView.url!.absoluteString.contains("zone/goods") { // 登录快手成功
                    self.maskView.isHidden = false
                    self.catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 4, actionName: "快手店铺")
                } else if self.webView.url!.absoluteString.contains("detail"), self.webView.url!.absoluteString.contains("zone/goods") {
                    self.catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 2, actionName: "快手商品详情")
                }
            })
            delayTask?.call()
        case .Douyin:
            urlStack.append(webView.url!.absoluteString)
            delayTask = HWDebounceTrailing(interval: 4, taskBlock: { [weak self] in
                guard let `self` = self else { return }
                if self.webView == nil {
                    return
                }
                if self.urlStack.last?.contains("grs/qualification/shopinfo") ?? false {
                    self.catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 3, actionName: "抖音店铺信息")
                    self.urlStack.removeAll()
                    self.maskView.isHidden = false
                } else if self.urlStack.last?.contains("fxg.jinritemai.com/ffa/g/list") ?? false {
                    if self.catchGoods.shopInfo.shopId.isEmpty {
                        self.load(url: "https://fxg.jinritemai.com/ffa/grs/qualification/shopinfo")
                        self.urlStack.removeAll()
                    } else {
                        self.catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 4, actionName: "抖音店铺商品列表")
                    }
                }
            })
            delayTask?.call()
        case .PDD:
            if webView.url!.absoluteString.contains("pinduoduo.com/goods/goods_list") { // 登录快手成功
                webView.evaluateJavaScript("console.debug(__NEXT_DATA__.props.headerProps.serverData.userInfo.mall)")
                catchGoods.fetchType = "店铺信息"
                catchGoods.evaluate(JS: "document.body.innerHTML", delayTime: 4, actionName: "PDD商品列表")
            }
        }
    }
  
    func checkCaptcha(com: @escaping ((_ haveCaptcha: Bool, _ html: String?) -> Void)) {
        _ = delay(time: 3) {
            if self.webView == nil {
                return
            }
            if self.catchGoods.shopInfo.platform == .TaoBao {
                let title = self.webView.title ?? ""
                if title == "验证码拦截" {
                    com(true, nil)
                } else {
                    com(false, nil)
                }
            }
        }
    }
    
    func scrollToBottom() {
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 500), animated: false)
    }
    
    func showIndicatorView() {
        if vIndicator.frame.origin.y == 0 { // 已经显示
            return
        }
        webView.scrollView.isScrollEnabled = true
        maskView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.vIndicator.frame = self.view.bounds
        } completion: { _ in
            self.vIndicator.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    // 0表示有拦截功能，1表示正常不拦截
    func switchWebView(type: Int) {
        if webViewType == type {
            return
        }
        webViewType = type
        observer = nil
        webView.removeFromSuperview()
        if let handler = webView.configuration.urlSchemeHandler(forURLScheme: "https") as? WKHttpHandler {
            handler.removeAllActivitiesSchemeTasks()
        }
        webView = createWebView(useHandle: webViewType == 0)
        view.insertSubview(webView, belowSubview: maskView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.left.right.bottom.equalTo(0)
        }
        catchGoods.webView = webView
    }
    
    func hideIndicatorView() {
        maskView.isHidden = true
        webView.scrollView.isScrollEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.vIndicator.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
        }
    }
    
    @objc func closeTaoTaoHint() {
        vTaobaoHint.removeFromSuperview()
    }
    
    // 在发送请求之前，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func changeProgress(value: Double) {
        if webView == nil {
            return
        }
        progressView.alpha = 1
        progressView.setProgress(Float(value), animated: true)
        if value >= 1 {
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut) {
                self.progressView.alpha = 0
            } completion: { _ in
                self.progressView.setProgress(0, animated: false)
            }
        }
    }
    
    lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        v.trackTintColor = UIColor("efeff4").withAlphaComponent(0)
        v.progressTintColor = UIColor.green
        v.progressViewStyle = .bar
        return v
    }()
    
    func createWebView(useHandle: Bool) -> WKWebView {
        let v = WKWebView(frame: .zero, configuration: useHandle ? congig1 : congig2)
        v.uiDelegate = self
        v.navigationDelegate = self
        v.isMultipleTouchEnabled = true
        v.autoresizesSubviews = true
        v.scrollView.alwaysBounceVertical = true
        v.allowsBackForwardNavigationGestures = false
        if platform == .TMall || platform == .TaoBao || platform == .Mall1688 {
            v.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.2 Safari/605.1.15"
        } else if platform == .KuaiShou {
            v.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.54"
        }
        observer = v.observe(\.estimatedProgress, options: [.old, .new], changeHandler: { [weak self] _, change in
            if let value = change.newValue {
                self?.changeProgress(value: value)
            }
        })
        return v
    }
    
    lazy var congig1: WKWebViewConfiguration = {
        let v = WKWebViewConfiguration()
        let handler = WKHttpHandler()
        v.setURLSchemeHandler(handler, forURLScheme: "http")
        v.setURLSchemeHandler(handler, forURLScheme: "https")
        return v
    }()
    
    lazy var congig2: WKWebViewConfiguration = {
        let v = WKWebViewConfiguration()
        let u = WKUserContentController()
        let overrideConsole = """
            function log(args) {
              window.webkit.messageHandlers.logging.postMessage(
                `${Object.values(args)
                  .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
                   // Limit msg to 3000 chars ,貌似没有这个限制
                  .join(", ")}`
              )
            }

            let originalLog = console.log
            console.log = function() { log(arguments); originalLog.apply(null, arguments) }

            window.addEventListener("error", function(e) {
               log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
            })
        """
        u.add(LoggingMessageHandler(), name: "logging")
        u.addUserScript(WKUserScript(source: overrideConsole, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        v.userContentController = u
        return v
    }()
    
    lazy var vTaobaoHint: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor("FFF5EB")
        v.layer.cornerRadius = 12
        let img = UIImageView(image: UIImage(named: "snack_info_orange"))
        v.addSubview(img)
        img.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalTo(v)
            make.width.height.equalTo(24)
        }
        let lbl = UILabel()
        lbl.textColor = .yellow
        lbl.text = "建议使用扫码登录，提高登录成功率"
        lbl.font = UIFont.pingfangRegular(size: 12)
        v.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(img.snp.right).offset(8)
            make.centerY.equalTo(v)
        }
        
        let btnClose = UIButton()
        btnClose.setImage(UIImage(named: "icon_taobao_login_close"), for: .normal)
        btnClose.addTarget(self, action: #selector(closeTaoTaoHint), for: .touchUpInside)
        v.addSubview(btnClose)
        btnClose.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.width.height.equalTo(16)
            make.centerY.equalTo(v)
        }
        return v
    }()
}

class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logging", let str = message.body as? String {
            let vc = Tool.topVC() as? TransferGoodsViewController
            vc?.catchGoods.receiveLog(str: str)
        }
    }
}
