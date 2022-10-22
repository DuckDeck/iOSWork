//
//  PHPhotoLibrary+Extension.swift
//  Library
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
import Photos
extension PHPhotoLibrary{
    static func auth(_ completed:@escaping ((_ finish:Bool,_ err:Swift.Error?)->Void)){
        let oldStatus = PHPhotoLibrary.authorizationStatus()
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized{
                completed(true,nil)
            } else if status == .denied && oldStatus == .notDetermined{
                print("拒绝访问相册了，去设置吧")
                completed(false,NSError(domain: "拒绝访问相册了，去设置吧", code: -100))
            } else {
                print("因系统原因无法访问相册")
                completed(false,NSError(domain: "因系统原因无法访问相册", code: -100))
            }
        }
    }
}
