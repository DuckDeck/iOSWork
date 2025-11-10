//
//  OpenWebViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/26.
//

import Foundation
import WebKit
import SwiftyJSON
class OpenWebViewController:BaseViewController{
    var webView:WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        
        
        let pre = WKPreferences()
        pre.minimumFontSize = 13
        pre.javaScriptEnabled = true
        config.preferences = pre
        let wkuser = WKUserContentController()
        config.userContentController = wkuser
        wkuser.add(self, name: "showMobile")

        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        webView?.uiDelegate = self;
        webView?.navigationDelegate = self;

        let path = Bundle.main.path(forResource: "upload", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
//        let request = URLRequest(url: URL("https://www.szwego.com/qq_conn/102791471/openApp")!)

        _ =  webView?.load(request)

        
        let btn = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(reloadHTML))
        navigationItem.rightBarButtonItem = btn
    }
    
    @objc func reloadHTML(){
        let path = Bundle.main.path(forResource: "upload", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        _ =  webView?.load(request)

    }
}

extension OpenWebViewController:WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let js = JSON(message.body)
        let str = js["data"].stringValue
        let d = Data(base64Encoded: str)!
        
    }
    
    
}
