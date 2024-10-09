//
//  Tool.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import IQKeyboardManagerSwift
import Photos
import UIKit
class Tool {
    static func ChineseToPinyin(chinese: String)->String {
        let py = NSMutableString(string: chinese)
        CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
        return py as String
    }

    static func thumbnailImageForVideo(url: URL, time: Double = 0)->UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        let t = CMTime(seconds: time, preferredTimescale: 60)
        do {
            let thumbnailImageRef = try assetImageGenerator.copyCGImage(at: t, actualTime: nil)
            return UIImage(cgImage: thumbnailImageRef)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    static func topVC(vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController)->UIViewController? {
        if let nav = vc as? UINavigationController {
            return topVC(vc: nav.visibleViewController)
        } else if let tab = vc as? UITabBarController, let select = tab.selectedViewController {
            return topVC(vc: select)
        } else if let presented = vc?.presentedViewController {
            return topVC(vc: presented)
        } else {
            return vc
        }
    }
}
