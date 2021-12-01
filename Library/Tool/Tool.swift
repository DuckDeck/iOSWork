//
//  Tool.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Photos
import PromiseKit
class Tool{

    static func ChineseToPinyin(chinese:String)->String{
        let py = NSMutableString(string: chinese)
        CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
        return py as String
    }
    
    static func thumbnailImageForVideo(url:URL,time:Double,loaded:@escaping((_ img:UIImage?)->Void)){
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.apertureMode =  AVAssetImageGenerator.ApertureMode.encodedPixels
            let t = CMTime(seconds: time, preferredTimescale: 60)
            do{
                let thumbnailImageRef = try assetImageGenerator.copyCGImage(at: t, actualTime: nil)
                DispatchQueue.main.async {
                    loaded(UIImage(cgImage: thumbnailImageRef))
                }
            }
            catch{
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    loaded(nil)
                }
            }

        }
    }
    
}
