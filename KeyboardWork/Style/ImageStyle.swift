//
//  ImageStyle.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit

public extension UIImage  {
    //有些图片是共用的，没有light和dark结尾
    static func themeImg(_ name:String,origin:Bool = false)->UIImage{
        if origin{
            if let img = UIImage.yh_imageNamed(name){
                return img
            }
        }
        if #available(iOS 12.0, *) {
            if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified{ //这时是系统颜色，应该由traitCollection.userInterfaceStyle决定
                if keyboardVC?.traitCollection.userInterfaceStyle == .light{
                    return UIImage.yh_imageNamed("\(name)_light")
                } else {
                    return UIImage.yh_imageNamed("\(name)_dark")
                }
            } else {
                if UserDefaults.standard.overridedUserInterfaceStyle == .light{
                    return UIImage.yh_imageNamed("\(name)_light")
                } else {
                    return UIImage.yh_imageNamed("\(name)_dark")
                }
            }
        }
        return UIImage.yh_imageNamed("\(name)_light")
    }
    //适用于图片和原色一至
    static func tintImage(_ name:String,color:UIColor?)->UIImage{
        if #available(iOS 13.0, *) {
            if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified{
                if keyboardVC?.traitCollection.userInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name)
                } else if color != nil {
                    return UIImage.yh_imageNamed(name).withTintColor(color!, renderingMode: .alwaysOriginal)
                }
            } else {
                if UserDefaults.standard.overridedUserInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name)
                } else if color != nil {
                    return UIImage.yh_imageNamed(name).withTintColor(color!, renderingMode: .alwaysOriginal)
                }
            }
        }
        return UIImage.yh_imageNamed(name)
    }
    //适用于图片和原色不一至
    static func tintImage(_ name:String,color:UIColor,darkColor:UIColor)->UIImage{
        if #available(iOS 13.0, *) {
            if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified{
                if keyboardVC?.traitCollection.userInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name).withTintColor(color, renderingMode: .alwaysOriginal)
                } else {
                    return UIImage.yh_imageNamed(name).withTintColor(darkColor, renderingMode: .alwaysOriginal)
                }
            } else {
                if UserDefaults.standard.overridedUserInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name).withTintColor(color, renderingMode: .alwaysOriginal)
                } else {
                    return UIImage.yh_imageNamed(name).withTintColor(darkColor, renderingMode: .alwaysOriginal)
                }
            }
        }
        return UIImage.yh_imageNamed(name)
    }
    
    //设置highlight色 ，一般是加上一定的透明度
    static func highlightImage(_ name:String,darkColor:UIColor,alpha:CGFloat)->UIImage{
        if #available(iOS 13.0, *) {
            if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified{
                if keyboardVC?.traitCollection.userInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name).imageWith(alpha: alpha)!
                } else {
                    return UIImage.yh_imageNamed(name).withTintColor(darkColor, renderingMode: .alwaysOriginal).imageWith(alpha: alpha)!
                }
            } else {
                if UserDefaults.standard.overridedUserInterfaceStyle == .light{
                    return UIImage.yh_imageNamed(name).imageWith(alpha: alpha)!
                } else {
                    return UIImage.yh_imageNamed(name).withTintColor(darkColor, renderingMode: .alwaysOriginal).imageWith(alpha: alpha)!
                }
            }
        }
        return UIImage.yh_imageNamed(name)
    }
    
    
    func imageWith(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
  

