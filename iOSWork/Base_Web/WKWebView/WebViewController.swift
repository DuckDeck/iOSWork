//
//  WebViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/22.
//

import Foundation
import WebKit
import SwiftyJSON
class WebViewController:BaseViewController{
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

        let url = URL(string: "https://mo.fish/?class_id=%E5%85%A8%E9%83%A8&hot_id=106")!
        let request = URLRequest(url: url)
        
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

extension WebViewController:WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let js = JSON(message.body)
        let str = js["data"].stringValue
        let d = Data(base64Encoded: str)!
        
    }
    
    
}
