//
//  UINavigationController+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
private var NSObject_previousViewController = 0
extension UINavigationController{
    @objc var previousViewController:AnyClass?{
        get{
            return objc_getAssociatedObject(self, &NSObject_previousViewController) as? AnyClass
        }
        set{
            objc_setAssociatedObject(self, &NSObject_previousViewController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func myPopViewControllerAnimated(animated: Bool) -> UIViewController? {
        if let prev =   self.myPopViewControllerAnimated(animated: animated){
            previousViewController = type(of: prev)
        }
        return nil
    }
    
    
    func setNavgationBarClear()  {
        navigationBar.isTranslucent = true
        let rect = CGRect(x: 0, y: 0, w: ScreenWidth, h: UIDevice.topAreaHeight)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        navigationBar.setBackgroundImage(img!, for: .default)
        navigationBar.clipsToBounds = true
    }

}
