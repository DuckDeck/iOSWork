//
//  GradientLabel.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/14.
//

import UIKit
class GradientLabel: UIView {
    lazy var textAttributes:[NSAttributedString.Key:AnyObject] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            
            NSAttributedString.Key.font:UIFont(name: "HelveticaNeue-Thin", size: 28.0)!,
            NSAttributedString.Key.paragraphStyle:style
        ]
    }()
    
    lazy var gradientLayer:CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [UIColor.black.cgColor,UIColor.white.cgColor,UIColor.black.cgColor]
        gradientLayer.colors = colors
        let locations = [0.25,0.5,0.75]
        gradientLayer.locations = locations as [NSNumber]?
        
        //添加一个动画
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0,0.1,0.25]
        gradientAnimation.toValue = [0.75,0.95,1.0]
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity
        gradientLayer.add(gradientAnimation, forKey: nil)
        
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3*bounds.size.width, height: bounds.size.height)
        
        layer.addSublayer(gradientLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBInspectable var text: String! {
        didSet {
            
            setNeedsDisplay()
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            text.draw(in: bounds, withAttributes: textAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
            maskLayer.contents = image?.cgImage
            
            gradientLayer.mask = maskLayer
        }
    }
}
