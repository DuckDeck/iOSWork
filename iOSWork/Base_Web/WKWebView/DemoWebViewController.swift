//
//  DemoWebViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/8/23.
//

import Foundation
import WebKit
class DemoWebViewController:UIViewController{
    var webView:WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    
        webView.load(URLRequest(url: URL(string: "https://fxg.jinritemai.com/login/common")!))
    }
}
