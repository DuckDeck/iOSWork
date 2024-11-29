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

    /// 使用iconName生成UIImage
    /// - Parameters:
    ///   - iconName: icon的名字
    ///   - size: 大小
    ///   - padding: 有时需要icon内需要有padding
    ///   - color: icon的颜色
    ///   - bgColor: img的背景色
    /// - Returns: uiimage对象
    static func if_image(_ iconName: String, size: Float, padding: Float = 0, color: UIColor?, bgColor: UIColor? = nil) -> UIImage? {
        let scale = UIScreen.main.scale
        let realSize = CGFloat(size) * scale
        var tmp = realSize
        if padding > 0, padding < size {
            tmp = realSize - CGFloat(padding) * scale * 2
        }
        let font = UIFont.if_iconFont(tmp)
        return autoreleasepool { () -> UIImage? in
            UIGraphicsBeginImageContext(CGSize(width: tmp, height: tmp))
            var attributes = [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.font] = font
            if let color = color {
                attributes[NSAttributedString.Key.foregroundColor] = color
            }
            iconName.draw(at: CGPoint.zero, withAttributes: attributes)
            guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
            var image: UIImage? = UIImage(cgImage: cgImage, scale: scale, orientation: UIImage.Orientation.up)
            if let bg = bgColor, let img2 = UIImage(color: bg) {
                UIGraphicsBeginImageContext(CGSize(width: realSize, height: realSize))
                img2.draw(in: CGRect(x: 0, y: 0, width: realSize, height: realSize))
                image?.draw(in: CGRect(x: realSize / 2 - tmp / 2, y: realSize / 2 - tmp / 2, width: tmp, height: tmp))
                image = UIGraphicsGetImageFromCurrentImageContext()
            }
            return image
        }
    }

    /// 生成深色模式和浅色模式的图片
    /// - Parameters:
    ///   - iconName: icon的名字
    ///   - size: 大小
    ///   - color: 浅色颜色
    ///   - dark: 深色颜色
    /// - Returns: uiimage对象
    static func if_image(_ iconName: String, size: Float, color: UIColor?, dark: UIColor?) -> UIImage? {
        let scale = UIScreen.main.scale
        let realSize = CGFloat(size) * scale
        let font = UIFont.if_iconFont(realSize)
        return autoreleasepool { () -> UIImage? in
            UIGraphicsBeginImageContext(CGSize(width: realSize, height: realSize))
            var attributes = [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.font] = font

            if #available(iOS 13.0, *) {
                if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified {
                    if let color = dark {
                        attributes[NSAttributedString.Key.foregroundColor] = color
                    }

                } else {
                    if UserDefaults.standard.overridedUserInterfaceStyle == .light {
                        if let color = color {
                            attributes[NSAttributedString.Key.foregroundColor] = color
                        }
                    } else if color != nil {
                        if let color = dark {
                            attributes[NSAttributedString.Key.foregroundColor] = color
                        }
                    }
                }
            }

            iconName.draw(at: CGPoint.zero, withAttributes: attributes)
            guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
            return UIImage(cgImage: cgImage, scale: scale, orientation: UIImage.Orientation.up)
        }
    }
}
