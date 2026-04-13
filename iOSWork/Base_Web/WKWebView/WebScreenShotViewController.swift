//
//  WebScreenShotViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2026/3/9.
//

import Foundation

import WebKit

class WebScreenShotViewController:UIViewController {
    
    var observer:NSKeyValueObservation?

    var useHandle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let btnLoad = UIButton().title(title: "加载").color(color: .red).bgColor(color: .lightGray)
        view.addSubview(btnLoad)
        btnLoad.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        let btnShot = UIButton().title(title: "截屏").color(color: .red).bgColor(color: .lightGray)
        view.addSubview(btnShot)
        btnShot.addTarget(self, action: #selector(screenShot), for: .touchUpInside)
        btnShot.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        title = "webView截屏"
        view.backgroundColor = .white
        view.addSubview(webView)
        webView.frame = CGRect(x: 0, y: UIDevice.topAreaHeight + 74, width: ScreenWidth, height: ScreenHeight - UIDevice.topAreaHeight - 74)
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(UIDevice.topAreaHeight + 44)
            make.height.equalTo(2.5)
        }
        
      //  webView.wAccessoryView = webView.doneAccessoryView
       // https://www.wsxcme.com/static/index.html?link_type=pc_login#/pc_login
     //   https://www.52pojie.cn/portal.php
        webView.load(URLRequest(url: URL(string: "https://t3vbpqf4.wegoab.com/static/index.html#/album/note/share/A202105081102297420001468/N202603241015290492001028")!))
        
    }
    
    @objc func screenShot() {
       method3()
    }
    
    func method1() { // 原生的截图方式，没显示出来的视图会显示为黑色
        webView.captureScreen { image in
            image?.saveToAlbum()
            Toast.showToast(msg: "保存成功")
        }
    }
    
    func method2() { // 原生的视图变成view方式，没显示出来的视图会显示为黑色
        let height = webView.scrollView.contentSize.height
        let r = webView.frame
        webView.frame = CGRect(x: r.origin.x, y: r.origin.y, width: ScreenWidth, height: height)
        delay(time: 0.5) {
            let img = self.webView.asImage(scale: 2)
            img.saveToAlbum()
            Toast.showToast(msg: "保存成功")
        }
   
    }
    
    func method3(){  // 使用滑动的方式截图，问题是如果页面有固定元素会导致视图错误
        Toast.showLoading()
        TYSnapshotScroll.screenSnapshot(webView) { img in
            img?.saveToAlbum()
            Toast.showToast(msg: "保存成功")
        }
    }
    
    func method4(){ //使用pdf截屏目前无法解决底部空白的问题，而且部分元素颜色会丢失，不能用
        Toast.showLoading()
        let height = webView.scrollView.contentSize.height
        print(height)
        webView.takeScreenshotOfFullContent { img in
            
            img?.saveToAlbum()
            Toast.showToast(msg: "保存成功")
        }
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
        let v = WWKWebView(frame: .zero, configuration: congig1 )
        v.uiDelegate = self
        v.navigationDelegate = self
        v.isMultipleTouchEnabled = true
        v.autoresizesSubviews = true
        v.scrollView.alwaysBounceVertical = true
        v.allowsBackForwardNavigationGestures = false
        if #available(iOS 16.4, *) {
            v.isInspectable = true
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
        return v
    }()
    
   
}
extension WebScreenShotViewController:WKUIDelegate, WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Toast.showToast(msg: "加载完成")
    }
}

extension WKWebView {
    func captureScreen(completed:@escaping((_ image:UIImage?)->Void)) {
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        takeSnapshot(with: config) { img, err in
                completed(img)
        }
    }
}
