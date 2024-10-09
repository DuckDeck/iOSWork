//
//  WebDemoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

import UIKit
import WebKit
class WebDemoViewController: UIViewController {

    enum TransferGoodsPlatform :Int{ //
        case TaoBao = 0, Mall1688, TMall, KuaiShou, Douyin, PDD
        var homtUrl: String {
            switch self {
            case .TaoBao:
                return "https://myseller.taobao.com"
            case .Mall1688:
                return "https://work.1688.com/home/seller.htm"
            case .TMall:
                return "https://myseller.taobao.com/"
            case .KuaiShou:
                return "https://s.kwaixiaodian.com/zone/goods/list"
            case .Douyin:
                return "https://fxg.jinritemai.com/ffa/g/list"
            case .PDD:
                return "https://mms.pinduoduo.com/goods/goods_list"
            }
        }

        var platFormId: Int {
            switch self {
            case .TaoBao:
                return 2
            case .Mall1688:
                return 3
            case .TMall:
                return 1
            case .KuaiShou:
                return 5
            case .Douyin:
                return 4
            case .PDD:
                return 6
            }
        }
    }
    
    var platform = TransferGoodsPlatform.TaoBao
    var observer:NSKeyValueObservation?

    var useHandle = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "webView相关测试"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(done))
        view.backgroundColor = .white
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
        
      //  webView.wAccessoryView = webView.doneAccessoryView
        
        webView.load(URLRequest(url: URL(string: "https://detail.m.tmall.com/item.htm?abbucket=0&id=592146045916")!))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observer = nil
    }
    
    @objc func done(){
      //  webView.resignFirstResponder()
    }

    func changeProgress(value:Double){
  
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
    
    lazy var webView: WWKWebView = {
        let v = WWKWebView(frame: .zero, configuration: useHandle ? congig1 : congig2)
        v.uiDelegate = self
        v.navigationDelegate = self
        v.isMultipleTouchEnabled = true
        v.autoresizesSubviews = true
        v.scrollView.alwaysBounceVertical = true
        v.allowsBackForwardNavigationGestures = false
        if platform == .TMall || platform == .TaoBao || platform == .Mall1688{
            v.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.2 Safari/605.1.15"
        } else if platform == .KuaiShou{
            v.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.54"
        }
        observer = v.observe(\.estimatedProgress, options: [.old,.new], changeHandler: { [weak self] web, change in
            if let value = change.newValue{
                self?.changeProgress(value: value)
            }
        })
        return v

    }()
    
    lazy var congig1: WKWebViewConfiguration = {
        let v = WKWebViewConfiguration()
        v.setURLSchemeHandler(WKHttpHandler(), forURLScheme: "http")
        v.setURLSchemeHandler(WKHttpHandler(), forURLScheme: "https")
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
        u.add(LogMessageHandler(), name: "logging")
        u.addUserScript(WKUserScript(source: overrideConsole, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        v.userContentController = u
        return v
    }()
}

class LogMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logging", let str = message.body as? String {
          print(str)
        }
    }
}

extension WebDemoViewController:WKUIDelegate, WKNavigationDelegate{
    
}
