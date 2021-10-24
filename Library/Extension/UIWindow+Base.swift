//
//  UIWindow+Base.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
extension UIWindow{
    
      open  func currentViewController() -> UIViewController? {
            var currentViewController = topMostController()
            while currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil  {
                currentViewController = (currentViewController as! UINavigationController).topViewController!
            }
            return currentViewController
        }
}
