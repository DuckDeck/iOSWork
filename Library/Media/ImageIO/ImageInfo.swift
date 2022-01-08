//
//  ImageInfo.swift
//  Library
//
//  Created by Stan Hu on 2022/1/8.
//

import Foundation
import ImageIO
import GrandKit

struct ImageExif{
   
}

struct ImageInfo{
    var Width = 0
    var Height = 0
    
    struct InfoName{
        static let PixelWidth = "PixelWidth"
        static let PixelHeight = "PixelHeight"
    }
}

struct ImageSource{
    var imgSource:CGImageSource?
    var imageInfo:ImageInfo?
    
    
    init(url:String,loadImg:((_ img:UIImage)->Void)?){
        let time1 = DateTime.now
        if url.hasPrefix("http"){
            if let netUrl = URL(string: url){
               
                let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary

                imgSource = CGImageSourceCreateWithURL(netUrl as CFURL,imageSourceOptions)
                let time2 = DateTime.now
                let span = time2 - time1
                print("加载\(url)的图片获取imgSource用时\(span!.milliseconds)毫秒")
            }
            
        } else {
             let fileUrl = URL(fileURLWithPath: url)
            let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary

            imgSource = CGImageSourceCreateWithURL(fileUrl as CFURL,imageSourceOptions)
        }
        if imgSource != nil{
            if let property = CGImageSourceCopyPropertiesAtIndex(imgSource!, 0, nil) as? [String:AnyObject]{
                imageInfo = ImageInfo()
                imageInfo?.Width = property[ImageInfo.InfoName.PixelWidth] as! Int
                imageInfo?.Height = property[ImageInfo.InfoName.PixelHeight] as! Int
                print(property)
            }
           
//            CFDictionaryRef options = (__bridge CFDictionaryRef) @{
//                                                                 (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
//                                                                 (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
//                                                                 (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
//                                                                 (id) kCGImageSourceCreateThumbnailWithTransform:@YES,
//                                                                 (id) kCGImageSourceThumbnailMaxPixelSize : @(newSize)
//                                                                 };
            
            if loadImg != nil{
                let imgThumb = CGImageSourceCreateThumbnailAtIndex(imgSource!, 0, [kCGImageSourceCreateThumbnailWithTransform:true,kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceThumbnailMaxPixelSize:imageInfo!.Width > imageInfo!.Height ? imageInfo!.Width : imageInfo!.Height] as CFDictionary)
                let img = UIImage(cgImage: imgThumb!)
                let time2 = DateTime.now
                let span = time2 - time1
                print("加载\(url)的图片获取UIImage用时\(span!.milliseconds)毫秒")
                loadImg?(img)
            }
//            CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
//            UIImage *scaled = [UIImage imageWithCGImage:scaledImageRef];
//            CFRelease(src);
//            CGImageRelease(scaledImageRef);

            
        }
    }    
}

