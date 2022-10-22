//
//  UILabel+Extension.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
extension UILabel{
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
  
    func lineNum(num:Int) -> Self {
        self.numberOfLines = num
        return self
    }
    
    func TwoSideAligment() {
        guard let txt = self.text else {
            return
        }
        let textSize = (txt as NSString).boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.truncatesLastVisibleLine,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font:self.font], context: nil)
        let margin = (self.frame.size.width - textSize.size.width) / CGFloat(txt.count - 1)
        let attrStr = NSMutableAttributedString(string: txt)
        attrStr.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: margin, range: NSMakeRange(0, txt.count - 1))
//        attrStr.addAttributes([kCTKernAttributeName:margin], range: NSMakeRange(0, txt.count - 1))
        self.attributedText = attrStr
    }
    
    
    func longPressCopyContentToPastboard(){
        self.addLongPressGesture {[weak self] (ges) in
            self?.becomeFirstResponder()
            self?.backgroundColor = UIColor(gray: 0.3, alpha: 0.3)
            let item = UIMenuItem(title: "复制", action: #selector(self!.copyContent))
            UIMenuController.shared.setTargetRect(self!.bounds, in: self!)
            UIMenuController.shared.menuItems = [item]
            UIMenuController.shared.arrowDirection = .up
            UIMenuController.shared.setMenuVisible(true, animated: true)
            NotificationCenter.default.addObserver(self!, selector: #selector(self!.hide), name: UIMenuController.didHideMenuNotification, object: nil)
        }
    }
    
    open override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func hide()  {
        self.backgroundColor = UIColor.clear
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func copyContent()  {
        var txt = self.text ?? ""
        if !txt.isEmpty{
            let pastboard = UIPasteboard.general
            if txt.contains(","){
                txt = txt.replacingOccurrences(of: ",", with: "")
            }
            pastboard.string = txt
        }
    }
}
