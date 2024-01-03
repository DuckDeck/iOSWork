//
//  UIDevice+Ex.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

import Foundation
extension UIDevice {
    static var topAreaHeight: CGFloat {
        var height : CGFloat = 0
        if #available(iOS 13.0, *) {
            height = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }else{
            height = UIApplication.shared.statusBarFrame.size.height
        }
        if height <= 0{
            if isNotch{
                height = 20
            } else {
                height = 48
            }
        }
        return height
    }

    static var bottomAreaHeight: CGFloat {
        if isNotch{
            if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height{
                return 34
            } else {
                return 21
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return 20
        } else {
            return 0
        }
    }
}
