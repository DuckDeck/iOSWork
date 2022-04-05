//
//  KeyboardViewController.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2021/10/22.
//

import UIKit
import Kingfisher
import SnapKit



class KeyboardViewController: UIInputViewController{


    var constraint : NSLayoutConstraint!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.constraint = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 240)
        self.constraint.priority = .defaultHigh
        view.addConstraint(self.constraint)
        
        self.view.backgroundColor = UIColor.init(hexString: "#F9F9F9")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardVC = self
        addKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardView()
    }
    
    func addKeyboard(){
        globalKeyboard = KeyboardView()
        view.addSubview(globalKeyboard!)
        globalKeyboard?.snp.makeConstraints({ make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(20)
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
