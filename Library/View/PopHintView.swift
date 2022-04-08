//
//  PopHintView.swift
//  Library
//
//  Created by Stan Hu on 2022/4/7.
//

import Foundation
import UIKit
class PopHintView:UIView{
    
    enum Direction{
        case top,bottom,left,right
    }
    
    var direction = Direction.top
    var tranOffset : Float = 0.5
    var contentView:UIView?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(tranOffset:Float,direction:Direction,contentView:UIView) {
        self.init(frame: CGRect.zero)
        self.direction = direction
        if tranOffset > 0.9{
            self.tranOffset = 0.9
        }
        if tranOffset < 0.1{
            self.tranOffset = 0.1
        }
        self.tranOffset = tranOffset
        self.contentView = contentView
        self.addSubview(contentView)
        
        switch direction {
        case .top:
            self.contentView?.snp.makeConstraints({ make in
                make.left.right.bottom.equalTo(0)
                make.top.equalTo(10)
            })
        case .bottom:
            self.contentView?.snp.makeConstraints({ make in
                make.left.right.top.equalTo(0)
                make.bottom.equalTo(-10)
            })
        case .left:
            self.contentView?.snp.makeConstraints({ make in
                make.top.right.bottom.equalTo(0)
                make.left.equalTo(10)
            })
        case .right:
            self.contentView?.snp.makeConstraints({ make in
                make.left.bottom.top.equalTo(0)
                make.right.equalTo(-10)
            })
        }
        
       
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addlayer()
        bringSubviewToFront(contentView!)
    }
    
    func addlayer(){
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
        var keyFrame = CGRect.zero
        switch direction {
        case .top:
            keyFrame = CGRect(x: 0, y: 10, width: frame.size.width, height: frame.size.height - 10)
        case .bottom:
            keyFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 10)
        case .left:
            keyFrame = CGRect(x: 10, y: 0, width: frame.size.width - 10, height: frame.size.height)
        case .right:
            keyFrame = CGRect(x: 0, y: 0, width: frame.size.width - 10, height: frame.size.height)
        }
        let path = UIBezierPath(roundedRect: keyFrame, cornerRadius: 8)
        keyLayer.path = path.cgPath
        layer.addSublayer(keyLayer)
        

        let traLayer = CAShapeLayer()
        traLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
        let traPath = UIBezierPath()
        switch direction {
        case .top:
            traPath.move(to: CGPoint(x: frame.size.width * tranOffset - 6, y: 10))
            traPath.addLine(to: CGPoint(x: frame.size.width * tranOffset, y: 0))
            traPath.addLine(to: CGPoint(x: frame.size.width * tranOffset + 6, y: 10))
        case .bottom:
            traPath.move(to: CGPoint(x: frame.size.width * tranOffset - 6, y: frame.size.height - 10))
            traPath.addLine(to: CGPoint(x: frame.size.width * tranOffset, y: frame.size.height))
            traPath.addLine(to: CGPoint(x: frame.size.width * tranOffset + 6, y: frame.size.height - 10))
        case .left:
            traPath.move(to: CGPoint(x: 10, y: frame.size.height * tranOffset - 6))
            traPath.addLine(to: CGPoint(x: 0, y: frame.size.height * tranOffset))
            traPath.addLine(to: CGPoint(x: 10, y: frame.size.height * tranOffset + 6))
        case .right:
            traPath.move(to: CGPoint(x: frame.size.width - 10, y: frame.size.height * tranOffset - 6))
            traPath.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height * tranOffset))
            traPath.addLine(to: CGPoint(x: frame.size.width - 10, y: frame.size.height * tranOffset + 6))
        }
      
        traPath.close()
        traPath.lineJoinStyle = .round
        traLayer.path = traPath.cgPath
        layer.addSublayer(traLayer)
    }

    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}
