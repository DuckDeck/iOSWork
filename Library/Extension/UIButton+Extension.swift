//
//  UIButton+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/8/1.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
private var touchAreaEdgeInsets: UIEdgeInsets = .zero
typealias buttonAction = (UIButton) -> ()
private var clickDelayTime = "clickDelayTime"
private var defaultDelayTime: TimeInterval = 0.0 // 默认两次点击无间隔
private var lastClickTime: TimeInterval = 0.0 // 记录上次点击时刻

extension UIButton {
    public var touchInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &touchAreaEdgeInsets) as? NSValue {
                var edgeInsets: UIEdgeInsets = .zero
                value.getValue(&edgeInsets)
                return edgeInsets
            } else {
                return .zero
            }
        }
        set {
            var newValueCopy = newValue
            let objcType = NSValue(uiEdgeInsets: .zero).objCType
            let value = NSValue(bytes: &newValueCopy, objCType: objcType)
            objc_setAssociatedObject(self, &touchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.touchInsets == .zero || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }
        let relativeFramt = self.bounds
        
        let hitFrame = relativeFramt.inset(by: self.touchInsets)
        return hitFrame.contains(point)
    }
    
    private enum butKeys {
        static var action = "click"
    }
   
    @objc dynamic var click: buttonAction? {
        set {
            objc_setAssociatedObject(self, &butKeys.action, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            if let action = objc_getAssociatedObject(self, &butKeys.action) as? buttonAction {
                return action
            }
            return nil
        }
    }
   
    func addClickEvent(click: @escaping buttonAction) {
        self.click = click
        self.addTarget(self, action: #selector(self.touchUpInSideFun), for: UIButton.Event.touchUpInside)
    }
   
    @objc func touchUpInSideFun(but: UIButton) {
        if let click = self.click {
            click(but)
        }
    }
    
    public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
    }
    
    func title(title: String) -> Self {
        self.setTitle(title, for: .normal)
        return self
    }
    
    func setTarget(_ target: Any?, action: Selector) -> Self {
        self.addTarget(target, action: action, for: .touchUpInside)
        return self
    }
    
    func color(color: UIColor) -> Self {
        self.setTitleColor(color, for: .normal)
        return self
    }
    
    func setFont(font: CGFloat) -> Self {
        self.titleLabel?.font = UIFont.systemFont(ofSize: font)
        return self
    }
    
    func setUIFont(font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }
    
    func img(img: UIImage) -> Self {
        self.setImage(img, for: .normal)
        return self
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
    
    var delayTime: TimeInterval {
        set {
            objc_setAssociatedObject(self, &clickDelayTime, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let clickDelayTime = objc_getAssociatedObject(self, &clickDelayTime) as? TimeInterval {
                return clickDelayTime
            }
            return defaultDelayTime
        }
    }
       
    override open func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        // 未设置delayTime值或者设置为0s间隔
        if self.delayTime == 0 {
            super.sendAction(action, to: target, for: event)
        } else {
            // 这里当前点击时刻用timeIntervalSince1970作为参考值，也可以取其他
            // 两次点击时间间隔大于设定值，响应
            if Date().timeIntervalSince1970 - lastClickTime > self.delayTime {
                super.sendAction(action, to: target, for: event)
                // 更新本次点击时刻
                lastClickTime = Date().timeIntervalSince1970
            }
        }
    }
}
