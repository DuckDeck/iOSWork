//
//  UIImage+BBIconFont.swift
//  BBIconFont
//
//  Created by Stan Hu on 2023/3/1.
//

import UIKit
@objc public extension UIImage {
    static func if_image(_ iconName: String, size: Float) -> UIImage? {
        if_image(iconName, size: size, color: nil)
    }

    static func if_image(_ iconName: String, size: Float, color: UIColor?,bgColor:UIColor? = nil) -> UIImage? {
        let scale = UIScreen.main.scale
        let realSize = CGFloat(size) * scale
        let font = UIFont.if_iconFont(realSize)
        return autoreleasepool {  () -> UIImage? in
            UIGraphicsBeginImageContext(CGSize(width: realSize, height: realSize))
            var attributes = [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.font] = font
            if let color = color {
                attributes[NSAttributedString.Key.foregroundColor] = color
            }
            if let bg = bgColor{
                attributes[NSAttributedString.Key.strikethroughColor] = bg
            }
            iconName.draw(at: CGPoint.zero, withAttributes: attributes)
            guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
            let image = UIImage(cgImage: cgImage, scale: scale, orientation: UIImage.Orientation.up)
            return image
        }
    }
    
    static func if_image(_ iconName: String, size: Float, color: UIColor?,dark:UIColor?) -> UIImage? {
        let scale = UIScreen.main.scale
        let realSize = CGFloat(size) * scale
        let font = UIFont.if_iconFont(realSize)
       return  autoreleasepool { () -> UIImage? in
            UIGraphicsBeginImageContext(CGSize(width: realSize, height: realSize))
            var attributes = [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.font] = font

            iconName.draw(at: CGPoint.zero, withAttributes: attributes)
            guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
            return UIImage(cgImage: cgImage, scale: scale, orientation: UIImage.Orientation.up)

        }
      
    }
}

