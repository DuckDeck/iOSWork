//
//  FlowerText.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/12/22.
//

import Foundation
class FlowerTextViewController:UIViewController,UITextFieldDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
//        let lbl = UILabel()
//        lbl.text = "\u{0041}\u{030a}"
//        view.addSubview(lbl)
//        lbl.snp.makeConstraints { make in
//            make.left.equalTo(10)
//            make.top.equalTo(100)
//
//        }
        
        view.addSubview(txtInput)
        txtInput.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(70)
            make.height.equalTo(30)
        }
      
        
        let arrowTop: CGFloat = 10
        let arrowWidth: CGFloat = 10
        let arrowHeight: CGFloat = 10
        let radius: CGFloat = 20
        let width: CGFloat = 200 - arrowWidth
        let height: CGFloat = 100
        
        let bubble = UIView(frame: CGRect(x: 150, y: 130, width: 200, height: 100))

        let bubbleBezier = UIBezierPath()
        bubbleBezier.move(to: CGPoint(x: 0, y: radius + arrowTop + arrowHeight / 2)) // 箭头
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius + arrowTop)) // 箭头右上
        //bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius)) // 左上圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: arrowWidth+radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth+radius, y: 0)) // 左上
        bubbleBezier.addLine(to: CGPoint(x: width-radius, y: 0)) // 右上
        //bubbleBezier.addLine(to: CGPoint(x: width, y: radius)) // 右上圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: radius), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
        bubbleBezier.addLine(to: CGPoint(x: width, y: height-radius)) // 右下
        //bubbleBezier.addLine(to: CGPoint(x: width-radius, y: height)) // 右下圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth+radius, y: height)) // 左下
        //bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: height-radius)) // 左下圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: arrowWidth+radius, y: height-radius), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius + arrowTop + arrowHeight)) // 箭头右下
        bubbleBezier.close()
        let bubbleShape = CAShapeLayer()
        bubbleShape.path = bubbleBezier.cgPath
        bubbleShape.lineWidth = 2
        bubbleShape.strokeColor = UIColor.systemRed.cgColor
        bubbleShape.fillColor = UIColor.clear.cgColor
        bubble.layer.addSublayer(bubbleShape)
        view.addSubview(bubble)
        
        let v = PopView(raius: 12, arrowOffset: 0.4)
        view.addSubview(v)
        v.backgroundColor = UIColor.yellow
        v.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(240)
            make.width.equalTo(300)
            make.height.equalTo(100)
        }
        
        
    }
    
//    let k = "你大有你有我什么"
//    var dataenc = k.data(using: String.Encoding.nonLossyASCII)
//    var encodevalue = String(data: dataenc!, encoding: String.Encoding.utf8)
//    let x = encodevalue!.split(separator: "\\u")
//    let xx = x.map { n in
//        "\\u\(n)\\u030a"
//    }.joined()
//
//    var datadec  = xx.data(using: String.Encoding.utf8)
//    var decodevalue = String(data: datadec!, encoding: String.Encoding.nonLossyASCII)
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        var dataenc = str.data(using: String.Encoding.nonLossyASCII)
        var encodevalue = String(data: dataenc!, encoding: String.Encoding.utf8)
        let x = encodevalue!.split("\\u")
        let xx = x.map { n in
            "\\u\(n)\\u030a"
        }.joined()
    
        let datadec  = xx.data(using: String.Encoding.utf8)
        let decodevalue = String(data: datadec!, encoding: String.Encoding.nonLossyASCII)
        return true
    }
    
    lazy var txtInput: UITextField = {
        let v = UITextField()
        v.placeholder  = "请输入花漾字"
        v.textColor = UIColor.carrot
        v.font = UIFont.systemFont(ofSize: 15)
        v.delegate = self
        return v
    }()
}

class PopView:UIView{
    
    enum ArrowLocation{
        case left,top,right,bottom
    }
    var arrowLocation = ArrowLocation.left
    var radius : CGFloat = 10
    var arrowOffset : CGFloat = 0.5
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(radius:CGFloat,arrowOffset:CGFloat,arrowLocation:ArrowLocation) {
        self.init(frame: .zero)
        self.radius = radius
        self.arrowOffset = arrowOffset
        self.arrowLocation = arrowLocation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let arrowTop: CGFloat = 10
        let arrowWidth: CGFloat = 10
        let arrowHeight: CGFloat = 10
        

        let bubbleBezier = UIBezierPath()
        bubbleBezier.move(to: CGPoint(x: 0, y: radius + arrowTop + arrowHeight / 2)) // 箭头
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius + arrowTop)) // 箭头右上
        //bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius)) // 左上圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: arrowWidth+radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth+radius, y: 0)) // 左上
        bubbleBezier.addLine(to: CGPoint(x: width-radius, y: 0)) // 右上
        //bubbleBezier.addLine(to: CGPoint(x: width, y: radius)) // 右上圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: radius), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
        bubbleBezier.addLine(to: CGPoint(x: width, y: height-radius)) // 右下
        //bubbleBezier.addLine(to: CGPoint(x: width-radius, y: height)) // 右下圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth+radius, y: height)) // 左下
        //bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: height-radius)) // 左下圆角
        bubbleBezier.addArc(withCenter: CGPoint(x: arrowWidth+radius, y: height-radius), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
        bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: radius + arrowTop + arrowHeight)) // 箭头右下
        bubbleBezier.close()
        let bubbleShape = CAShapeLayer()
        bubbleShape.path = bubbleBezier.cgPath
        bubbleShape.lineWidth = 2
        bubbleShape.strokeColor = UIColor.systemRed.cgColor
        bubbleShape.fillColor = UIColor.clear.cgColor
        layer.addSublayer(bubbleShape)
       
    }
    
    
}
