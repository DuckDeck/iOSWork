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
            make.bottom.equalTo(-70)
            make.height.equalTo(30)
        }
      
        
      
        
        let v = PopArrowView(radius: 12, arrowOffset: 0.2, arrowLocation: .bottom, fillColor: UIColor.red, borderColor: .clear, arrowWidth: 12, arrowHeight: 6)
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(240)
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        
        let lbl = UILabel()
        v.addSubview(lbl)
        lbl.text = "我是一个好东西"
        lbl.textColor = UIColor.white
        lbl.snp.makeConstraints { make in
            make.center.equalTo(v)
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

class PopArrowView:UIView{
    
    enum ArrowLocation{
        case left,top,right,bottom
    }
    var arrowLocation = ArrowLocation.left
    var fillColor:UIColor = .clear
    var boderColor:UIColor = .clear
    var radius : CGFloat = 10
    var arrowOffset : CGFloat = 0.5
    var arrowWidth : CGFloat = 10   //箭头宽度
    var arrowHeight : CGFloat = 10  //箭头高度
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(radius:CGFloat,arrowOffset:CGFloat,arrowLocation:ArrowLocation,fillColor:UIColor,borderColor:UIColor,arrowWidth:CGFloat,arrowHeight:CGFloat) {
        self.init(frame: .zero)
        self.radius = radius
        self.arrowOffset = arrowOffset
        self.arrowLocation = arrowLocation
        self.fillColor = fillColor
        self.boderColor = borderColor
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.size.width
        let height = bounds.size.height
        let bubbleBezier = UIBezierPath()
        switch self.arrowLocation{
        case .left:
            bubbleBezier.move(to: CGPoint(x: 0, y: arrowOffset * height)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: arrowHeight, y: arrowOffset * height - arrowWidth / 2)) // 箭头右上
            bubbleBezier.addArc(withCenter: CGPoint(x: arrowHeight+radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
            bubbleBezier.addLine(to: CGPoint(x: arrowHeight+radius, y: 0)) // 左上
            bubbleBezier.addLine(to: CGPoint(x: width-radius, y: 0)) // 右上
            bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: radius), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
            bubbleBezier.addLine(to: CGPoint(x: width, y: height-radius)) // 右下
            bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
            bubbleBezier.addLine(to: CGPoint(x: arrowHeight+radius, y: height)) // 左下
            bubbleBezier.addArc(withCenter: CGPoint(x: arrowHeight+radius, y: height-radius), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
            bubbleBezier.addLine(to: CGPoint(x: arrowHeight, y: arrowOffset * height + arrowWidth / 2)) // 箭头右下
        case .right:
            bubbleBezier.move(to: CGPoint(x: width, y: arrowOffset * height)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: width - arrowHeight, y: arrowOffset * height + arrowWidth / 2)) // 箭头左下
            bubbleBezier.addLine(to: CGPoint(x: width - arrowHeight, y: height - radius))
            bubbleBezier.addArc(withCenter: CGPoint(x: width - arrowHeight - radius , y: height - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
            bubbleBezier.addLine(to: CGPoint(x: radius , y: height)) // 左下
            bubbleBezier.addArc(withCenter: CGPoint(x: radius , y: height - radius), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
            bubbleBezier.addLine(to: CGPoint(x: 0, y: radius)) // 左上
            bubbleBezier.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
            bubbleBezier.addLine(to: CGPoint(x: width - radius - arrowHeight, y: 0)) // 右上
            bubbleBezier.addArc(withCenter: CGPoint(x: width - radius - arrowHeight, y: radius), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
            bubbleBezier.addLine(to: CGPoint(x: width - arrowHeight, y: arrowOffset * height - arrowWidth / 2)) // 右边
        case .top:
            bubbleBezier.move(to: CGPoint(x: arrowOffset * width, y: 0)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: arrowOffset * width + arrowWidth / 2, y: arrowHeight)) // 箭头右
            bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: radius + arrowHeight), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
            bubbleBezier.addLine(to: CGPoint(x: width, y: height - radius)) // 左上
            bubbleBezier.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
            bubbleBezier.addLine(to: CGPoint(x: radius, y: height)) // 左下
            bubbleBezier.addArc(withCenter: CGPoint(x: radius, y: height-radius), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
            bubbleBezier.addLine(to: CGPoint(x: 0, y: radius + arrowHeight)) // 左下
            bubbleBezier.addArc(withCenter: CGPoint(x: radius, y: radius + arrowHeight), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
            bubbleBezier.addLine(to: CGPoint(x: arrowOffset * width - arrowWidth / 2, y: arrowHeight)) // 箭头右下
        case .bottom:
            bubbleBezier.move(to: CGPoint(x: arrowOffset * width, y: height)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: arrowOffset * width - arrowWidth / 2, y: height - arrowHeight)) // 箭头左下
            bubbleBezier.addLine(to: CGPoint(x: radius, y: height - arrowHeight))
            bubbleBezier.addArc(withCenter: CGPoint(x: radius , y: height - radius - arrowHeight), radius: radius, startAngle: CGFloat.pi*0.5, endAngle: CGFloat.pi, clockwise: true) // 左下圆角
            bubbleBezier.addLine(to: CGPoint(x: 0 , y: radius)) // 左上
            bubbleBezier.addArc(withCenter: CGPoint(x: radius , y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi*1.5, clockwise: true) // 左上圆角
            bubbleBezier.addLine(to: CGPoint(x: width - radius, y: 0)) // 右上
            bubbleBezier.addArc(withCenter: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*2, clockwise: true) // 右上圆角
            bubbleBezier.addLine(to: CGPoint(x: width, y: height - radius - arrowHeight)) // 右下
            bubbleBezier.addArc(withCenter: CGPoint(x: width - radius, y: height - radius - arrowHeight), radius: radius, startAngle: 0, endAngle: CGFloat.pi*0.5, clockwise: true) // 右下圆角
            bubbleBezier.addLine(to: CGPoint(x: arrowOffset * width + arrowWidth / 2, y: height - arrowHeight)) // 下边
        }
        bubbleBezier.close()
        let bubbleShape = CAShapeLayer()
        bubbleShape.path = bubbleBezier.cgPath
        bubbleShape.lineWidth = 2
        bubbleShape.strokeColor = self.boderColor.cgColor
        bubbleShape.fillColor = self.fillColor.cgColor
        layer.insertSublayer(bubbleShape, at: 0)
    }
    
}
