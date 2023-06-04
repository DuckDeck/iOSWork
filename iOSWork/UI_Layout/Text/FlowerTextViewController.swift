//
//  FlowerText.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/12/22.
//

import Foundation
import Lottie
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
            make.top.equalTo(100)
            make.height.equalTo(30)
        }
      
        
      
        
        let v = PopView(radius: 12, arrowOffset: 0.5, arrowLocation: .left)
        view.addSubview(v)
        v.backgroundColor = UIColor.yellow
        v.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(240)
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        
        addNofication()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guideView.removeSubviews()
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
    
    func addNofication() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
    
    @objc func keyboardChanged(_ notifi: NSNotification) {
        if KeyboardManage.isUseWGKeyboard {
            DispatchQueue.main.async {
               
                self.guideView.stop()
                self.guideView.removeFromSuperview()
                
                _ = delay(time: 0.5) {
                    self.dismiss(animated: true, completion: nil)
                 
                }
            }
        } else {
            delay(time: 1) {
                self.addGuide()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notifi: NSNotification) {
        let userInfo = notifi.userInfo!
        let rect = userInfo["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        let height = rect.size.height
//        texField.snp_remakeConstraints({ (make) in
//            make.bottom.equalTo(view).offset(-(height))
//            make.left.equalTo(16)
//            make.right.equalTo(-16)
//            make.height.equalTo(46)
//        })
    }
    
    @objc func closeVC() {
        guideView.removeFromSuperview()
        dismiss(animated: true, completion: nil)
       
    }
    
    @objc func keyboardWillHide(_ notifi: NSNotification) {
//        texField.snp_remakeConstraints { (make) in
//            make.top.equalTo(imgView.snp_bottom).offset(50)
//            make.left.equalTo(16)
//            make.right.equalTo(-16)
//            make.height.equalTo(46)
//        }
    }
    
    
    func addGuide() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            if self.guideView.superview != nil{
                return
            }
            let scenes = UIApplication.shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0})
            
            let lastWindow = scenes.last?.windows.last
            
            self.guideView.removeFromSuperview()
            let window = UIApplication.shared.windows.last!
            window.isUserInteractionEnabled = true
            window.windowLevel = .alert
            self.guideView.isUserInteractionEnabled = true
            window.subviews.first?.addSubview(self.guideView)
            self.guideView.play()
            self.guideView.snp.makeConstraints { make in
                make.left.equalTo(-10)
                make.bottom.equalTo(-20)
                make.width.equalTo(260)
                make.height.equalTo(120)
            }
        }
    }
    
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
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.greenSea.cgColor
//        let input = UIView()
//        input.backgroundColor = UIColor.cyan
//        v.inputView = input
        return v
    }()
    

    lazy var guideView: LottieAnimationView = {
        let guideView = LottieAnimationView(name: "switch_keyboard")
        guideView.loopMode = .loop
        return guideView
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
        let width = bounds.size.width
        let height = bounds.size.height
        let bubbleBezier = UIBezierPath()
        switch self.arrowLocation{
        case .left:
            bubbleBezier.move(to: CGPoint(x: 0, y: arrowOffset * height)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: arrowOffset * height - arrowWidth / 2)) // 箭头右上
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
            bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: arrowOffset * height + arrowWidth / 2)) // 箭头右下
        case .right:
            bubbleBezier.move(to: CGPoint(x: 0, y: arrowOffset * height)) // 箭头
            bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: arrowOffset * height - arrowWidth / 2)) // 箭头右上
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
            bubbleBezier.addLine(to: CGPoint(x: arrowWidth, y: arrowOffset * height + arrowWidth / 2)) // 箭头右下
        default:
            break
        }
        bubbleBezier.close()
        let bubbleShape = CAShapeLayer()
        bubbleShape.path = bubbleBezier.cgPath
        bubbleShape.lineWidth = 2
        bubbleShape.strokeColor = UIColor.systemRed.cgColor
        bubbleShape.fillColor = backgroundColor?.cgColor
        layer.addSublayer(bubbleShape)
       
    }
    
    
}
