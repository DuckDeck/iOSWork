//
//  WebviewMemoryViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/3/5.
//

import UIKit
import WebKit

class WebviewMemoryViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "webview内存"
        view.backgroundColor = UIColor.white
        view.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(50)
        }
        panelView.addArrangedSubview(btnAddWebView)
        panelView.addArrangedSubview(btnRemoveWebView)
        panelView.addArrangedSubview(UIView())
        // Do any additional setup after loading the view.
    }
    

    @objc func addWebView(){
        let vc = webVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func removeWebView(){
        
    }
    
    lazy var btnAddWebView: UIButton = {
        let v = UIButton()
        v.setTitle("添加Webview", for: .normal)
        v.setTitleColor(UIColor.random, for: .normal)
        v.addTarget(self, action: #selector(addWebView), for: .touchUpInside)
        return v.borderWidth(width: 1).borderColor(color: UIColor.random)
    }()
    
    lazy var btnRemoveWebView: UIButton = {
        let v = UIButton()
        v.setTitle("删除Webview", for: .normal)
        v.setTitleColor(UIColor.random, for: .normal)
        v.addTarget(self, action: #selector(removeWebView), for: .touchUpInside)
        return v.borderWidth(width: 1).borderColor(color: UIColor.random)
    }()
    
    lazy var panelView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        return v
    }()
    
   
}


class webVC:UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(95)
            make.left.right.equalTo(0)
            make.height.equalTo(4)
        }
        
        view.addSubview(webView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new,.old], context: nil)
        webView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
            make.bottom.equalTo(-50)
        }
        
        view.addSubview(btnClose)
        btnClose.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(webView.snp.bottom)
        }
        
        let req = URLRequest(url: URL(string: "https://www.sohu.com/")!,cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        webView.load(req)
    }
    

    
    @objc func close(){
        webView.removeFromSuperview()
        clearCache()
        dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)

        }
    }
    
    fileprivate func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }

   
    
    lazy var btnClose : UIButton = {
        let v = UIButton().title(title: "关闭").color(color: UIColor.random)
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        return v
    }()
    
    lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        v.tintColor = UIColor.random
        return v
    }()
    
    lazy var webView : MMWwb = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let v = MMWwb.init(frame: CGRect.zero, configuration: config)
        v.isMultipleTouchEnabled = true
        v.navigationDelegate = self
        v.uiDelegate = self
        v.autoresizesSubviews = true
        v.scrollView.alwaysBounceVertical = true
        v.scrollView.contentInsetAdjustmentBehavior = .never
        v.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        v.scrollView.scrollIndicatorInsets = v.scrollView.contentInset
        return v
    }()
    
    deinit {
        print("webVC 已经被deinit")
    }
}

extension webVC:WKUIDelegate,WKNavigationDelegate{
    
}

class MMWwb:WKWebView{
    deinit {
        print("=========WKWebView deinit =========")
    }
}
