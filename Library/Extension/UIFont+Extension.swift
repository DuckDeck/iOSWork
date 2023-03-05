//
//  UIFont+Extension.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit

extension UIFont{
    static func pingfangRegular(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Regular", size: size)!
    }
    
    static func pingfangMedium(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Medium", size: size)!
    }
    
    
    static func pingfangBold(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Semibold", size: size)!
    }
    
    static func pingfangLight(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Light", size: size)!
    }
    
    static func paleRegular(size:CGFloat)->UIFont{
        return UIFont(name: "WegoKeyboard-Palios", size: size)!
    }
    
    static func paleMedium(size:CGFloat)->UIFont{           //更粗点
        return UIFont(name: "WegoKeyboard-PaleMedium", size: size)!
    }
}
