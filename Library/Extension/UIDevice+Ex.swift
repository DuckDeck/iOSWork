//
//  UIDevice+Ex.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

import Foundation
extension UIDevice {
    static var topAreaHeight: CGFloat {
        let h = UIApplication.shared.statusBarFrame.size.height
        if h >= 54 {
            return h + 5
        }
        return h
    }

    static var bottomAreaHeight: CGFloat {
        if isNotch {
            if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
                return 34
            } else {
                return 21
            }
        } else {
            return 0
        }
    }
}
