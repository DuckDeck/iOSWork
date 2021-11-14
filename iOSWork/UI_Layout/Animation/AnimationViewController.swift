//
//  AnimationViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/13.
//

import UIKit
import SnapKit
class AnimationViewController:BaseViewController{
    
    let sc = UIScrollView(frame: CGRect(x: 0, y: 0, w: ScreenWidth, h: ScreenHeight))
    let view3D = UIView()
    var contentLayer:CATransformLayer?
    let kPanScale:CGFloat = 1.0/180.0
    let viewlayer = UIView()
    let viewRotation = UIView()
    let vTwoSide = TwoSideView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "动画效果"
        view.backgroundColor = UIColor.white
        
        view.addSubview(sc)
        
        let lbl = UILabel().text(text: "Ripple").color(color: UIColor.red).addTo(view: sc)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(100)
        }
        
        let vAni = RippleAnimtaionView(frame: CGRect(x: 130, y: 70, width: 100, height: 100))
        let vAni2 = RippleAnimtaionView2(frame: CGRect(x: 300, y: 70, width: 100, height: 100))
        let bgView = UIView(frame: CGRect(x: 300, y: 70, width: 100, height: 100))
        sc.addSubview(vAni)
        bgView.backgroundColor = UIColor.orange
        bgView.layer.cornerRadius = 50
        sc.addSubview(bgView)
        sc.addSubview(vAni2)
        
        let lbl1 = UILabel().text(text: "立方体").color(color: UIColor.red).addTo(view: sc)
        lbl1.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(lbl.snp.bottom).offset(300)
            make.height.equalTo(25)
        }

        view3D.frame = CGRect(x: 100, y: 300, width: 300, height: 300)
        sc.addSubview(view3D)
        view3D.layer.borderWidth = 1
        let theContentLayer = CATransformLayer()
        theContentLayer.frame = view3D.layer.bounds
        let size = theContentLayer.bounds.size
        theContentLayer.transform = CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0)
        view3D.layer.addSublayer(theContentLayer)
        contentLayer = theContentLayer
        _ = createLayer(x: 0, y: -200 / 2, z: 0, color: UIColor.red, transform: AnimationViewController.makeSideRotation(x: 1, y: 0, z: 0))
        _ = createLayer(x: 0, y: 200 / 2, z: 0, color: UIColor.green, transform: AnimationViewController.makeSideRotation(x: 1, y: 0, z: 0))
        _ = createLayer(x: 200 / 2, y: 0, z: 0, color: UIColor.blue, transform: AnimationViewController.makeSideRotation(x: 0, y: 1, z: 0))
        _ = createLayer(x: -200 / 2, y: 0, z: 0, color: UIColor.cyan, transform: AnimationViewController.makeSideRotation(x: 0, y: 1, z: 0))
        _ = createLayer(x: 0, y: 0, z: -200 / 2, color: UIColor.yellow, transform: CATransform3DIdentity)
        _ = createLayer(x: 0, y: 0, z: 200 / 2, color: UIColor.magenta, transform: CATransform3DIdentity)
        
        view3D.layer.sublayerTransform = AnimationViewController.makePerspectiveTransform()
        
        view3D.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))

        
        viewlayer.frame = CGRect(x: 100, y: 700, width: 300, height: 400)
        viewlayer.layer.borderWidth = 1
        sc.addSubview(viewlayer)
        
        let lbl2 = UILabel().text(text: "Layer动画").color(color: UIColor.red).addTo(view: sc)
        lbl2.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(lbl1.snp.bottom).offset(300)
            make.height.equalTo(25)
        }
        
        let subLayer  = CALayer()
        subLayer.backgroundColor = UIColor.magenta.cgColor
        subLayer.cornerRadius = 8
        subLayer.borderWidth = 4
        subLayer.borderColor = UIColor.black.cgColor
        subLayer.shadowOffset = CGSize(width: 4, height: 5)
        subLayer.shadowRadius = 1
        subLayer.shadowColor = UIColor.black.cgColor
        subLayer.shadowOpacity = 0.8
        subLayer.frame = CGRect(x: 10, y: 15, width: 120, height: 160)
        viewlayer.layer.addSublayer(subLayer)

        let subLayer2 = CALayer()
        subLayer2.cornerRadius = 8
        subLayer2.borderWidth = 4
        subLayer2.borderColor = UIColor.black.cgColor
        subLayer2.shadowOffset = CGSize(width: 4, height: 5)
        subLayer2.shadowRadius = 1
        subLayer2.shadowColor = UIColor.black.cgColor
        subLayer2.shadowOpacity = 0.8
        subLayer2.masksToBounds = true
        subLayer2.frame = CGRect(x: 140, y: 15, width: 120, height: 160)
        viewlayer.layer.addSublayer(subLayer2)
        let imgLayer = CALayer()
        imgLayer.contents = UIImage(named: "2")!.cgImage
        imgLayer.contentsGravity = .resizeAspectFill
        imgLayer.frame = subLayer2.bounds
        subLayer2.addSublayer(imgLayer)
        let anima = CABasicAnimation(keyPath: "opacity")
        anima.fromValue = 1.0
        anima.toValue = 0.0
        anima.autoreverses = true
        anima.repeatCount = 100
        anima.duration = 2.0
        subLayer2.add(anima, forKey: "anim")

        
        let subLayer3 = CALayer()
        subLayer3.backgroundColor = UIColor.green.cgColor
        subLayer3.frame = CGRect(x: 10, y: 200, width: 100, height: 100)
        subLayer3.shadowOffset = CGSize(width: 0, height: 3)
        subLayer3.shadowRadius = 5.0
        subLayer3.shadowColor = UIColor.black.cgColor
        subLayer3.shadowOpacity = 0.8
        subLayer3.cornerRadius = 10
        subLayer3.borderWidth = 3
        subLayer3.borderColor = UIColor.yellow.cgColor
        subLayer3.masksToBounds = true
        viewlayer.layer.addSublayer(subLayer3)
        subLayer3.setNeedsDisplay()
        
        let vDash = UILabel()
        vDash.text = "我有虚线边框"
        vDash.textAlignment = .center
        vDash.frame = CGRect(x: 140, y: 220, w: 130, h: 50)
        vDash.backgroundColor = UIColor.lightGray
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.purple.cgColor
        borderLayer.fillColor = nil
        borderLayer.lineDashPattern = [4,2]
        borderLayer.path = UIBezierPath(rect: vDash.bounds).cgPath
        borderLayer.frame = vDash.bounds
        vDash.layer.addSublayer(borderLayer)
        viewlayer.addSubview(vDash)

        let line = UIView(frame: CGRect(x: 0, y: 300, w: 300, h: 44))
        let ly2 = CAGradientLayer()
        ly2.startPoint = CGPoint(x: 0.5, y: 0)
        ly2.endPoint = CGPoint(x: 0.5, y: 1)
        ly2.colors = [UIColor.clear.cgColor,UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3).cgColor]
        ly2.frame = CGRect(x: 0, y: 0, w: 300, h: 44)
        line.layer.insertSublayer(ly2, at: 0)
        viewlayer.addSubview(line)

        
        viewRotation.frame = CGRect(x: 100, y: viewlayer.bottom + 20, width: 300, height: 400)
        viewRotation.layer.borderWidth = 1
        sc.addSubview(viewRotation)

        let lbl3 = UILabel().text(text: "旋转缩放").color(color: UIColor.red).addTo(view: sc)
        lbl3.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(lbl2.snp.bottom).offset(400)
            make.bottom.equalTo(-700)
            make.height.equalTo(25)
        }

        let imgRotation = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imgRotation.clipsToBounds = true
        imgRotation.contentMode = .scaleAspectFill
        imgRotation.image = UIImage(named: "5")
        viewRotation.addSubview(imgRotation)
        
        UIButton(frame: CGRect(x: 10, y: 330, width: 50, height: 30)).title(title: "左转").color(color: UIColor.green).addTo(view: viewRotation).addClickEvent { btn in
            imgRotation.image = imgRotation.image!.imageRotatedByDegrees(degrees: 30)
        }
        UIButton(frame: CGRect(x: 70, y: 330, width: 50, height: 30)).title(title: "右转").color(color: UIColor.green).addTo(view: viewRotation).addClickEvent { btn in
            imgRotation.image = imgRotation.image!.imageRotatedByDegrees(degrees: -30)
        }
    
    
        vTwoSide.frame = CGRect(x: 100, y: viewRotation.bottom + 20, width: 300, height: 200)
        sc.addSubview(vTwoSide)
        let imgFront = UIImageView()
        let imgBack = UIImageView()
        imgFront.image = UIImage(named: "1")
        imgBack.image = UIImage(named: "2")
        imgFront.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        imgBack.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        vTwoSide.frontView = imgFront
        vTwoSide.backView = imgBack

        UIButton(frame: CGRect(x: 10, y: vTwoSide.top + 100, width: 50, height: 30)).title(title: "翻转").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            self.vTwoSide.turn(duration: 1) {
                
            }
        }

    
    }
    
    
    func createLayer(color:UIColor,transform:CATransform3D)->CALayer{
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        layer.position = view.center
        layer.transform = transform
        view3D.layer.addSublayer(layer)
        return layer
    }
    
    func createLayer(x:CGFloat,y:CGFloat,z:CGFloat,color:UIColor,transform:CATransform3D)->CALayer{
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        layer.position = CGPoint(x: x, y: y)
        layer.zPosition = z
        layer.transform = transform
        contentLayer?.addSublayer(layer)
        //view.layer.addSublayer(layer)
        
        return layer
    }
    
    static func makePerspectiveTransform()->CATransform3D{
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 2000.0
        return perspective
    }
    
    static func makeSideRotation(x:CGFloat,y:CGFloat,z:CGFloat)->CATransform3D{
        return CATransform3DMakeRotation(CGFloat(Double.pi / 2), x, y, z)
    }
    
    @objc func pan(gesture:UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        // var transform = ThreeDViewController.makePerspectiveTransform()
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, kPanScale * translation.x, 0, 1, 0)
        transform = CATransform3DRotate(transform, -kPanScale * translation.y, 1, 0, 0)
        view3D.layer.sublayerTransform = transform
    }

}
