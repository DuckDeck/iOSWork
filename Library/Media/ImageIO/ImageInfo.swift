//
//  ImageInfo.swift
//  Library
//
//  Created by Stan Hu on 2022/1/8.
//

import Foundation
import ImageIO
import GrandKit

struct ImageExif:Codable{
    var ExifVersion = ""
    var Flash = 0
    var LensModel = ""
    var OffsetTimeDigitized = ""
    var SubsecTimeOriginal = 0
    var LensSpecification : [Int]?
    var ExposureMode = 0
    var CompositeImage = 0
    var LensMake = ""
    var FNumber = 0.0
    var OffsetTimeOriginal = ""
    var PixelYDimension = 0
    var ApertureValue = 0.0
    var ExposureBiasValue = 0
    var MeteringMode = 0
    var ISOSpeedRatings : [Int]?
    var ShutterSpeedValue = 0.0
    var SceneCaptureType = 0
    var FocalLength = 0.0
    var DateTimeOriginal : Date?
    var SceneType = 0
    var FlashPixVersion : [Int]?
    var ColorSpace = 0
    var SubjectArea : [Int]?
    var PixelXDimension = 0
    var FocalLenIn35mmFilm = 0
    var SubsecTimeDigitized = 0
    var OffsetTime = ""
    var SensingMethod = 0
    var BrightnessValue = 0.0
    var DateTimeDigitized : Date?
    var ComponentsConfiguration : [Int]?
    var WhiteBalance = 0
    var ExposureTime = 0.0
    var ExposureProgram = 0
    
}

struct ImageJFIF : Codable{
    var DensityUnit = 0 //单位密度
    var JFIFVersion = ""
    var XDensity = 0
    var YDensity = 0
}

struct ImageInfo{
    var Width = 0
    var Height = 0
    var exifInfo:ImageExif?
    var jfifInfo:ImageJFIF?
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
        if url.hasPrefix("http") || url.hasPrefix("file"){
            if let netUrl = URL(string: url){
                let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
                imgSource = CGImageSourceCreateWithURL(netUrl as CFURL,imageSourceOptions)
                let time2 = DateTime.now
                let span = time2 - time1
                print("加载\(url)的图片获取imgSource用时\(span!.milliseconds)毫秒")
            }
            
        } else {
            let fileUrl = URL(fileURLWithPath:  url)
            let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
            imgSource = CGImageSourceCreateWithURL(fileUrl as CFURL,imageSourceOptions)
        }
        if imgSource != nil{
            if let property = CGImageSourceCopyPropertiesAtIndex(imgSource!, 0, nil) as? [String:AnyObject]{
                imageInfo = ImageInfo()
                imageInfo?.Width = property[ImageInfo.InfoName.PixelWidth] as! Int
                imageInfo?.Height = property[ImageInfo.InfoName.PixelHeight] as! Int
                
                if property.keys.contains("{JFIF}"){
                    let info = property["{JFIF}"] as! [String:AnyObject]
                    let data = try! JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
                    imageInfo?.jfifInfo = ImageJFIF.parse(d: data)
                }
                
                if property.keys.contains("{Exif}"){
                    let exifInfo = property["{Exif}"] as! [String:AnyObject]
                    let exifData = try! JSONSerialization.data(withJSONObject: exifInfo, options: .prettyPrinted)
                    imageInfo?.exifInfo = ImageExif.parse(d: exifData)
                }
                print(property)
            }
           
            
            if loadImg != nil{
                let imgThumb = CGImageSourceCreateThumbnailAtIndex(imgSource!, 0, [kCGImageSourceCreateThumbnailWithTransform:true,kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceThumbnailMaxPixelSize:imageInfo!.Width > imageInfo!.Height ? imageInfo!.Width : imageInfo!.Height] as CFDictionary)
                let img = UIImage(cgImage: imgThumb!)
                let time2 = DateTime.now
                let span = time2 - time1
                print("加载\(url)的图片获取UIImage用时\(span!.milliseconds)毫秒")
                loadImg?(img)
            }


            
        }
    }    
}

