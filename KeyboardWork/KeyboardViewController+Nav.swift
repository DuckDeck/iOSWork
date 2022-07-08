//
//  KeyboardViewController+Nav.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/5/7.
//

import Foundation
extension  KeyboardViewController{
    
    func push(v:UIView){
        if containerView == nil{
            containerView = UIView()
            view.addSubview(containerView!)
            containerView?.snp.makeConstraints({ make in
                make.edges.equalTo(0)
            })
        }
        containerView?.addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        removeKeyboardView()
        
    }
    
    func pop(){
        if let last = containerView?.subviews.last{
            last.removeFromSuperview()
        }
        if containerView?.subviews.count == 0{
            popToKeyboard()
        }
    }
    
    func popToKeyboard(){
        if containerView != nil{
            containerView?.subviews.forEach{$0.removeFromSuperview()}
            containerView?.removeFromSuperview()
            containerView = nil
        }
        addKeyboard()
    }
    
    
    func addSwitchKeyboardView(){
        let v = SwitchKeyboardView()
        push(v: v)
    }
    
    func addSettingView(){
        let v = KeyboardSettingView()
        push(v: v)
    }
    
    func addPasteboardView(){
        let v = PasteboardView()
        push(v: v)
    }
}


