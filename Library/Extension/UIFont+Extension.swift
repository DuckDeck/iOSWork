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
}
