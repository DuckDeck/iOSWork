//
//  UIImage+Extension.swift
//  Library
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
extension UIImage{
    static func captureScreen()->UIImage{
        //        var view = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true); //snapshotViewAfterScreenUpdates这个方法有问题，实际上是返回正在显示的View的了，但是就是转化不了图片
        //        return captureView(view)
        //获取APP的RootViewController
        var vc = UIApplication.shared.keyWindow?.rootViewController
        //依次获取RootViewController 的上层ViewController
        while vc?.presentationController == nil {
            vc = vc?.presentedViewController
        }
        //如果最上层ViewContoller是导航ViewController，就得到它的topViewController
        while (vc is UINavigationController && (vc as! UINavigationController).topViewController != nil)
        {
            vc = (vc as! UINavigationController).topViewController
        }
        if let view = vc?.view
        {
            //如果可以获取到View，就调用将View显示为图片的方法
            return captureView(view: view)
        }
        return UIImage()
    }
    
}
