//
//  KeyboardViewController.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2021/10/22.
//

import UIKit
import Kingfisher
import SnapKit
import CocoaAsyncSocket


class KeyboardViewController: UIInputViewController{

    var containerView:UIView?
    var clientSockek:GCDAsyncSocket?
    var pastboardManage: PastboardManage? // 剪切板内容管理器
    var constraint : NSLayoutConstraint!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostBundleID = self.parent!.value(forKey: "_hostBundleID") as? String ?? ""
        if hostBundleID == "ShadowEdge.iOSWork"{
            clientSockek = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            startListen()
        }
        self.constraint = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 272)
        self.constraint.priority = .defaultHigh
        view.addConstraint(self.constraint)
        overrideUserInterfaceStyle = UserDefaults.standard.overridedUserInterfaceStyle
        self.view.backgroundColor = UIColor.init(hexString: "#F9F9F9")
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardVC = self
        addKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pastboardManage = PastboardManage { str, words in
            print(str)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardView()
        pastboardManage?.timer?.invalidate()
        pastboardManage = nil
        clientSockek?.disconnect()
        clientSockek = nil
    }
    
    func startListen(){
        do{
            try clientSockek?.connect(toHost: "localHost", onPort: 12345)
        } catch{
            print(error)
        }
    }
    
    
    
    func addKeyboard(){
        
        globalHeader = HeaderView()
        view.addSubview(globalHeader!)
        globalHeader?.snp.makeConstraints({ make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(50)
        })
        
        globalKeyboard = KeyboardView()
        view.addSubview(globalKeyboard!)
        globalKeyboard?.snp.makeConstraints({ make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(222)
        })
    }
    
    func removeKeyboardView(){
        globalKeyboard?.removeFromSuperview()
        globalKeyboard = nil
    }
}


extension KeyboardViewController{
    @objc var currentText: String? {
         get {
             self.inputView?.becomeFirstResponder()
             let before = self.textDocumentProxy.documentContextBeforeInput ?? ""
             let after = self.textDocumentProxy.documentContextAfterInput ?? ""
             return before + after
         }
     }
     
     @objc func insert(text: String?) {
         guard let _text = text else {
             return
         }
         self.textDocumentProxy.insertText(_text)
    }
    
    func remove(text: String)  {
        if var cur = currentText{
            if  let range = cur.range(of: text){
                cur.removeSubrange(range)
                textDocumentProxy.clearText()
                textDocumentProxy.insertText(cur)
            }
        }
    }
    
    func reset(texts:String) {
        textDocumentProxy.clearText()
        textDocumentProxy.insertText(texts)
    }
    
    @objc func deleteText() {
         self.textDocumentProxy.deleteBackward()
     }
                      
             
   
}

extension KeyboardViewController:GCDAsyncSocketDelegate{
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let str = String(data: data, encoding: .utf8){
            print(str)
        }
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect")
    }
    
}
