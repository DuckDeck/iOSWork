//
//  PHPLibraryTool.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
import Photos
import UIKit
enum PHPAsset{
    case img(UIImage)
    case imgUrl(URL)
    case videoUrl(URL)
    
    var rawString:String{
        switch self {
        case .img(_):
            return "UIImage图片"
        case .imgUrl(let uRL):
            return "网络图片\(uRL)"
        case .videoUrl(let uRL):
            return "网络视频\(uRL)"
        }
    }
}

class PHPLibraryTool{
    static func save(asset:PHPAsset,collection:PHAssetCollection?,_ completed:@escaping ((_ finish:Bool,_ err:Swift.Error?)->Void)){
        do{
//            kbLog.info("开始保存媒体信息，\(asset.rawString)")
            try PHPhotoLibrary.shared().performChangesAndWait {
                var placeHolder : PHObjectPlaceholder?
                switch asset {
                case .img(let img):
                    placeHolder = PHAssetChangeRequest.creationRequestForAsset(from: img).placeholderForCreatedAsset
                case .imgUrl(let url):
                    placeHolder = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)?.placeholderForCreatedAsset
                case .videoUrl(let url):
                    placeHolder = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:url)?.placeholderForCreatedAsset
                }
                if collection != nil{
                    PHPhotoLibrary.shared().performChanges {
                        let request = PHAssetCollectionChangeRequest(for: collection!)
                        request?.addAssets([placeHolder] as NSFastEnumeration)
                    } completionHandler: { ok, error in
                        if ok{
//                            kbLog.info("视频保存到相册成功")
                        } else if error != nil {
//                            kbLog.info("视频保存到相册失败，原因是\(error!)")
                        }
                        DispatchQueue.main.async {
                            completed(ok,error)
                        }
                    }
                } else if placeHolder != nil {
                    
                    completed(true,nil)
                }
            }
        } catch{
            completed(false,error)
        }
    }
}
