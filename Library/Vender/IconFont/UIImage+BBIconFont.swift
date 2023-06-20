//
//  UIImage+BBIconFont.swift
//  BBIconFont
//
//  Created by Stan Hu on 2023/3/1.
//

import UIKit
@objc public extension UIImage{
    @objc static func if_image(_ iconName: NSString, size: Float = 14.0) -> UIImage? {
        if_image(iconName, size: size, color: nil)
    }
    
    @objc static func if_image(_ iconName: NSString, size: Float = 14.0, color: UIColor?) -> UIImage?
    {
        let scale = UIScreen.main.scale
        let realSize: CGFloat = CGFloat (size) * scale
        let font = UIFont.if_iconFont(realSize)
        UIGraphicsBeginImageContext(CGSize(width: realSize, height: realSize))
        var attributes = Dictionary<NSAttributedString.Key, Any> ()
        attributes[NSAttributedString.Key.font] = font
        if let color = color {
            attributes[NSAttributedString.Key.foregroundColor]=color
        }
        iconName.draw(at: CGPoint.zero, withAttributes: attributes)
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext ()?.cgImage else {     return nil}
        
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: UIImage.Orientation.up)
        return image
    }
}
