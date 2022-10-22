//
//  UIView+Extension.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
extension UIView{
    func currentVC() -> UIViewController? {
        var vc:UIViewController! = nil
        var window = UIApplication.shared.keyWindow!
        if window.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for win in windows{
                if win.windowLevel == UIWindow.Level.normal{
                    window = win
                    break
                }
            }
        }
        let frontView = window.subviews.first!
        let responder = frontView.next
        if responder != nil && responder! is UIViewController{
            vc = responder! as? UIViewController
        }
        else{
            vc = window.rootViewController
        }
        return vc
    }
}
