//
//  UITextField+Extension.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import UIKit
extension UITextField{
    func addOffsetView(value:Float){
        let vOffset = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(value), height: self.frame.size.height))
        self.leftViewMode = .always
        self.leftView = vOffset
    }
    
    func addOffsetLabel(width:Float,txt:NSMutableAttributedString) {
        let vOffset = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: self.frame.size.height))
        vOffset.attributedText = txt
        self.leftViewMode = .always
        self.leftView = vOffset
    }
    
    func text(text:String) -> Self {
        self.text = text
        return self
    }
    
    func attrText(text:NSAttributedString) -> Self {
        self.attributedText = text
        return self
    }
    
    func setFont(font:CGFloat) -> Self {
        self.font = UIFont.systemFont(ofSize: font)
        return self
    }
    
    func setUIFont(font:UIFont) -> Self {
        self.font = font
        return self
    }
    
    
    func color(color:UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    func txtAlignment(ali:NSTextAlignment) -> Self {
        self.textAlignment = ali
        return self
    }
    
    func plaHolder(txt:String) -> Self {
        self.placeholder = txt
        return self
    }
    
    func attrPlaHolder(txt:NSAttributedString) -> Self {
        self.attributedText = txt
        return self
    }
    
   }
