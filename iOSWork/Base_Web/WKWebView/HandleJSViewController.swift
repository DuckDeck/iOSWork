//
//  HandleJSViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/1.
//

import UIKit
import WebKit
import PhotosUI
//这里用js打开相册和摄像头
class HandleJSViewController: BaseViewController {
    var web:WKWebView!
    var imagePickerController:PHPickerViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnRunjs = UIBarButtonItem(title: "RunJs", style: .plain, target: self, action: #selector(runJS))
        navigationItem.rightBarButtonItem = btnRunjs
        let config = WKWebViewConfiguration()
        let hander = ScriptMessageHandler()
        let controller = WKUserContentController()
        controller.add(self, name: "error")
        config.userContentController = controller
        hander.delegate = self
        let param = [1,2,3,4,5]
        let script = WKUserScript(source: "function callJs(){passAnArray(\(param));}", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.add(hander, name: "mobile")
        config.userContentController.addUserScript(script)
        let htmlUrl = Bundle.main.url(forResource: "demo", withExtension: "html")
        let str = try! String.init(contentsOf: htmlUrl!)
        web = WKWebView(frame: CGRect(), configuration: config)
        web.uiDelegate = self
        web.navigationDelegate = self
        web.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        web.loadHTMLString(str, baseURL: nil)
        // Do any additional setup after loading the view.
    }

    @objc func runJS() {
        let js = "callJs()"
        web.evaluate(script: js) { (res, err) in
            if let res = res {
                print(res)
            }
        }
    }
    
    deinit {
        web.configuration.userContentController.removeScriptMessageHandler(forName: "mobile")
    }
}

extension HandleJSViewController:WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      
        if message.name == "mobile"{
            let dict = message.body as! [String:Any]
            let title = dict["title"] as? String
            let message = dict["message"] as? String
            //这些信息要商量好
           
            if let t = title , t == "openPrompt"{
                web.evaluate(script: "confirm('Hello from evaluateJavascript()')") { (res, err) in
                    UIAlertController.title(title:  "不支持", message: "WKWebView不支持调用confirm和prompt").action(title: "OK", handle: nil).show()
                }
            }
            else if let t = title , t == "openAlbum"{
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                imagePickerController = PHPickerViewController(configuration: config)
                imagePickerController.delegate = self
                
                present(imagePickerController, animated: true, completion: nil)
            }
            else{
                UIAlertController.title(title: title ?? "", message: message ?? "").action(title: "OK", handle: nil).show()
            }

        }
        
        else if message.name == "error"{
            let error = (message.body as? [String: Any])?["message"] as? String ?? "unknown"
//            assertionFailure("JavaScript error: \(error)")
            Toast.showToast(msg: error.localizedLowercase)

        }
        
        
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        UIAlertController.title(title: message, message: nil).action(title: "OK", handle: nil).show()
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit navigation")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish navigation")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("navigation: WKNavigation")
    }
}

class ScriptMessageHandler: NSObject {
    weak var delegate:WKScriptMessageHandler?
}

extension ScriptMessageHandler:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let target = delegate{
            target.userContentController(userContentController, didReceive: message)
        }
    }
}


extension WKWebView {
    func evaluate(script: String, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        var finished = false
        
        evaluateJavaScript(script) { (result, error) in
            if error == nil {
                if result != nil {
                    completion(result, nil)
                }
            } else {
                completion(nil, error)
            }
            finished = true
        }
        
        while !finished {
            RunLoop.current.run(mode: .default, before: Date.distantFuture)
        }
    }
}

