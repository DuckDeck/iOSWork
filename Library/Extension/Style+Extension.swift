//
//  Style+Extension.swift
//  Library
//
//  Created by Stan Hu on 2022/7/10.
//

import Foundation
import UIKit
extension UserDefaults{
    var overridedUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: integer(forKey: #function)) ?? .unspecified
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
}
public extension UIApplication {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        // iPad支持多窗口，不支持iPad的话可以删除这段判断
        if #available(iOS 13.0, *), supportsMultipleScenes {
            for connectedScene in connectedScenes {
                if let scene = connectedScene as? UIWindowScene {
                    scene.windows.override(userInterfaceStyle)
                }
            }
        }
        else {
            windows.override(userInterfaceStyle)
        }
    }
}
public extension UIWindow {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        if #available(iOS 13.0, tvOS 13.0, *) {
            overrideUserInterfaceStyle = userInterfaceStyle
        }
    }
}
public extension Array where Element: UIWindow {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        for window in self {
            window.override(userInterfaceStyle)
        }
    }
}
  
