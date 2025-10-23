//
//  PHAssert+Extension.swift
//  Library
//
//  Created by Stan Hu on 2022/1/12.
//

import Foundation
import Photos
extension PHAsset{
    func getUrl(completed:@escaping ((_ url:URL?)->Void)){
        if self.mediaType == .image{
            let option = PHContentEditingInputRequestOptions()
            option.isNetworkAccessAllowed = true
            option.canHandleAdjustmentData = {adjust -> Bool in
                return true
            }
            self.requestContentEditingInput(with: option) { input, info in
                completed(input?.fullSizeImageURL)
            }
        } else if mediaType == .video{
            let option = PHVideoRequestOptions()
            option.isNetworkAccessAllowed = true
            option.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: option) { asset, mix, info in
                if let urlAssert = asset as? AVURLAsset{
                    completed(urlAssert.url)
                } else {
                    completed(nil)
                }
            }
        }
        completed(nil)
    }
}
