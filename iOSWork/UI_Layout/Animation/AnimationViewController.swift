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
    var slider:GrandSlider?
    var currentImageNameCount = 1
    var views:[UIView] = [UIView]()
    var viewReplication = UIView(frame: CGRect(x: 0, y: 2100, width: UIScreen.main.bounds.size.width, height: 100))
    var viewReplication2 = UIView(frame: CGRect(x: 0, y: 2200, width: UIScreen.main.bounds.size.width, height: 100))

    let imgCombine = UIImageView(frame: CGRect(x: 70, y: 2700, width: ScreenWidth - 140, height: 200))
    let imgSpring = UIImageView(frame: CGRect(x: 70, y: 2970, width: ScreenWidth - 140, height: 200))
    let imgKeyframe = UIImageView(frame: CGRect(x: 70, y: 3250, width: ScreenWidth - 140, height: 200))
    
    lazy var avatar1:AnimationVIew = {
        let avaterView = AnimationVIew()
        avaterView.frame = CGRect(x: ScreenWidth - 90 - 20, y: 3500, width: 90, height: 90)
        return avaterView
    }()
    
    lazy var avatar2:AnimationVIew = {
        let avaterView = AnimationVIew()
        avaterView.frame = CGRect(x: 20, y: 3500, width: 90, height: 90)
        return avaterView
    }()

    
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

        UIButton(frame: CGRect(x: 10, y: vTwoSide.top + 100, width: 50, height: 30)).title(title: "点我翻转").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            self.vTwoSide.turn(duration: 1) {
                
            }
        }

        let lbl4 = UILabel().text(text: "轮番图").color(color: UIColor.red).addTo(view: sc)
        lbl4.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(lbl3.snp.bottom).offset(650)
            make.height.equalTo(25)
        }

        
        var img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with:URL(string: "https://up.enterdesk.com/edpic/8f/3f/54/8f3f541605b08c893226e6f593b5905f.jpg"))
        img.layer.borderWidth = 0.5
        img.layer.borderColor = UIColor.red.cgColor
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://up.enterdesk.com/edpic/0e/76/f7/0e76f703c83883674702228a504550fd.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://up.enterdesk.com/edpic/18/cd/fd/18cdfdef962cb5b8c58bf69b7bdc3905.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://img1.gamersky.com/upimg/users/2021/05/23/origin_202105231402365717.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://img1.gamersky.com/upimg/users/2021/05/23/origin_202105231358568024.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://img1.gamersky.com/upimg/users/2021/05/23/origin_202105231401022973.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
        img.kf.setImage(with: URL(string: "https://img1.gamersky.com/upimg/users/2021/10/31/origin_202110311359353552.jpg"))
        views.append(img)
        slider = GrandSlider(frame: CGRect(x: 100, y: vTwoSide.bottom + 20, width: 300, height: 240),animationDuration:2)
        slider?.views = views
        slider?.tap   = {(view,index) in
            
        }
        slider?.dotGap = 5
        slider?.dotWidth = 15
        slider?.normalDotColor = UIColor.blue
        slider?.highlightedDotColor = UIColor.red
        sc.addSubview(slider!)

        let lbl5 = UILabel().text(text: "Replication动画").color(color: UIColor.red).addTo(view: sc)
        lbl5.snp.makeConstraints { make in
            make.centerX.equalTo(ScreenWidth / 2)
            make.top.equalTo(lbl4.snp.bottom).offset(160)
            make.height.equalTo(25)
        }

        
        setupView1()
        
        setupView2()
    
    
        let lbl6 = UILabel().text(text: "Gradient动画").color(color: UIColor.red).addTo(view: sc)
        lbl6.snp.makeConstraints { make in
            make.centerX.equalTo(ScreenWidth / 2)
            make.top.equalTo(lbl5.snp.bottom).offset(280)
            make.bottom.equalTo(-1300)
            make.height.equalTo(25)
        }
        
        let lblGradient = GradientLabel(frame: CGRect(x: ScreenWidth / 2 - 150, y: 2400, width: 300, height: 44))
        lblGradient.text = ">---滑动来解锁"
        sc.addSubview(lblGradient)

        let imgGra = UIImageView(frame: CGRect(x: 80, y: 2380, width: ScreenWidth - 160, height: 240))
        imgGra.clipsToBounds = true
        imgGra.contentMode = .scaleAspectFill
        imgGra.image = UIImage(named: "4")
        sc.addSubview(imgGra)
        let viewGradient = UIView(frame: imgGra.frame)
        sc.addSubview(viewGradient)
        let gradientColor = CAGradientLayer()
        gradientColor.frame = img.bounds
        let color1 = UIColor.white.withAlphaComponent(0.1)
        let color2 = UIColor.white
        gradientColor.colors = [color1.cgColor,color2.cgColor]
        //设置渲染的起始结束位置（纵向渐变）
        gradientColor.startPoint = CGPoint(x: 0, y: 0)
        gradientColor.endPoint = CGPoint(x: 0, y: 1)
        gradientColor.cornerRadius = 21
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        gradientColor.locations = gradientLocations
        viewGradient.layer.addSublayer(gradientColor)

        
        
        UIButton(frame: CGRect(x: 80, y: imgGra.bottom + 30, width: ScreenWidth - 160, height: 30)).title(title: "点我开始组合动画").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            self.startCombineAnimation()
        }

        imgCombine.image = UIImage(named: "5")
        sc.addSubview(imgCombine)
        

        UIButton(frame: CGRect(x: 80, y: imgCombine.bottom + 30, width: ScreenWidth - 160, height: 30)).title(title: "点我开始弹性动画").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            self.startSpringAnimation()
        }

        imgSpring.image = UIImage(named: "3")
        sc.addSubview(imgSpring)

        UIButton(frame: CGRect(x: 80, y: imgSpring.bottom + 30, width: ScreenWidth - 160, height: 30)).title(title: "点我开始关键动画").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            self.startKeyFrameAnimation()
        }

        imgKeyframe.image = UIImage(named: "4")
        sc.addSubview(imgKeyframe)

        
        UIButton(frame: CGRect(x: 80, y: imgKeyframe.bottom + 30, width: ScreenWidth - 160, height: 30)).title(title: "点我开始特别动画").color(color: UIColor.green).addTo(view: sc).addClickEvent { btn in
            let avaterSize = self.avatar1.frame.size
            let morphSize = CGSize(width: avaterSize.width * 0.85, height: avaterSize.height * 1.05)
            let bounceXOffset = ScreenWidth / 2.0 - self.avatar1.lineWidth * 2 - self.avatar1.frame.width
            self.avatar2.boundsOffset(bounceXOffset, morphSize: morphSize)
            self.avatar1.boundsOffset(self.avatar1.frame.origin.x - bounceXOffset, morphSize: morphSize)
        }
        
        avatar1.image = UIImage(named: "2")!
        avatar2.image = UIImage(named: "3")!
        avatar1.lblName.text = "FOX"
        avatar2.lblName.text = "DOG"
        
        sc.addSubview(avatar1)
        sc.addSubview(avatar2)

        
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

    
    func setupView1()  {
        sc.addSubview(viewReplication)
        // Do any additional setup after loading the view.
        
        //CALayer的子类CAReplicatorLayer通过它可以对其创建的对象进行复制,从而做出复杂的效果.
        let replicator = CAReplicatorLayer()
        let dot = CALayer()
        let dotLength:CGFloat = 6.0
        let dotOffset:CGFloat = 8.0
        replicator.frame = viewReplication.bounds
        viewReplication.layer.addSublayer(replicator)
        
        dot.frame = CGRect(x: replicator.frame.size.width - dotLength, y: replicator.position.y, width: dotLength, height: dotLength)
        dot.backgroundColor = UIColor.lightGray.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 1.5
        replicator.addSublayer(dot)
        
        replicator.instanceCount = Int(viewReplication.frame.size.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0)
        
        //2 . 让它动起来,并且让每一个dot做一点延迟.
        //        let move = CABasicAnimation(keyPath: "position.y")
        //        move.fromValue = dot.position.y
        //        move.toValue = dot.position.y - 50
        //        move.duration  = 1.0
        //        move.repeatCount = 10
        //        dot.addAnimation(move, forKey: nil)
        //        replicator.instanceDelay = 0.02
        
        //加个更大的动画效果
        
        replicator.instanceDelay = 0.02
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D:CATransform3DIdentity)
        scale.toValue = NSValue(caTransform3D:CATransform3DMakeScale(1.4, 15, 1.0))
        scale.duration = 0.33
        scale.repeatCount = Float.infinity
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dot.add(scale, forKey: "dotScale")
        
        //4 .添加一个渐变色
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = 0.33
        fade.beginTime = CACurrentMediaTime() + 0.33
        fade.repeatCount = Float.infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dot.add(fade, forKey: "dotOpacity")
        //5 . 添加渐变的颜色
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = UIColor.magenta.cgColor
        tint.toValue = UIColor.cyan.cgColor
        tint.duration = 0.66
        tint.beginTime = CACurrentMediaTime() + 0.28
        tint.fillMode = CAMediaTimingFillMode.backwards
        tint.repeatCount = Float.infinity
        tint.autoreverses = true
        tint.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dot.add(tint, forKey: "dotColor")
        
        //设置成上下摇摆
        let initialRotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        initialRotation.fromValue = 0.0
        initialRotation.toValue = 0.01
        initialRotation.duration = 0.33
        initialRotation.isRemovedOnCompletion = false
        initialRotation.fillMode = CAMediaTimingFillMode.backwards
        initialRotation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        replicator.add(initialRotation, forKey: "initialRocation")
        
        let rotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        rotation.fromValue = 0.01
        rotation.toValue = -0.01
        rotation.duration = 0.99
        rotation.beginTime = CACurrentMediaTime() + 0.33
        rotation.repeatCount = Float.infinity
        rotation.autoreverses = true
        rotation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        replicator.add(rotation, forKey: "replicatorRotation")
    }
    
    func setupView2()  {
        sc.addSubview(viewReplication2)
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 10, height: 80)
        layer.backgroundColor = UIColor.white.cgColor
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.add(scaleYAnimation(), forKey: "scaleAnimation")
        
       
        let replicator = CAReplicatorLayer()
        replicator.instanceCount = 10  //        设置复制层里面包含子层的个数
        replicator.instanceTransform = CATransform3DMakeTranslation(45, 10, 0) //        设置子层相对于前一个层的偏移量
        replicator.instanceDelay = 0.2 //        设置子层相对于前一个层的延迟时间
        replicator.instanceColor = UIColor.green.cgColor //        设置层的颜色，(前提是要设置层的背景颜色，如果没有设置背景颜色，默认是透明的，再设置这个属性不会有效果。
        replicator.instanceGreenOffset = -0.2 //        颜色的渐变，相对于前一个层的渐变（取值-1~+1）.RGB有三种颜色，所以这里也是绿红蓝三种。
        replicator.instanceRedOffset = -0.2
        replicator.instanceBlueOffset = -0.2
        replicator.addSublayer(layer) //        需要把子层加入到复制层中，复制层按照前面设置的参数自动复制
        
        viewReplication2.layer.addSublayer(replicator)
    }
    
 
   
    
    func scaleYAnimation() -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "transform.scale.y")
        anim.toValue = 0.1
        anim.duration = 0.4
        anim.autoreverses = true
        anim.repeatCount = MAXFLOAT
        return anim
    }
    
    @objc func startCombineAnimation(){
        let groupAnimation = CAAnimationGroup()
        groupAnimation.beginTime = CACurrentMediaTime() + 1
        groupAnimation.duration = 3
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.both
        
        groupAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupAnimation.repeatCount = 4.5
        groupAnimation.autoreverses = true
        groupAnimation.speed = 2.0
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.5
        scaleDown.toValue = 1.0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = CGFloat(Double.pi / 4)
        rotate.toValue = 0.0
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.5
        fade.toValue = 1.0
        groupAnimation.animations = [scaleDown,rotate,fade]
        imgCombine.layer.add(groupAnimation, forKey: "groupAnimation")

    }
    @objc func startSpringAnimation(){
        let scaleDown = CASpringAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.5
        scaleDown.toValue  = 1.0
        // settlingDuration：结算时间（根据动画参数估算弹簧开始运动到停止的时间，动画设置的时间最好根据此时间来设置）
        scaleDown.duration = scaleDown.settlingDuration
        // mass：质量（影响弹簧的惯性，质量越大，弹簧惯性越大，运动的幅度越大) 默认值为1
        scaleDown.mass = 3.0
        // stiffness：弹性系数（弹性系数越大，弹簧的运动越快）默认值为100
        scaleDown.stiffness = 150.0
        // damping：阻尼系数（阻尼系数越大，弹簧的停止越快）默认值为10
        scaleDown.damping = 50
        // initialVelocity：初始速率（弹簧动画的初始速度大小，弹簧运动的初始方向与初始速率的正负一致，若初始速率为0，表示忽略该属性）默认值为0
        scaleDown.initialVelocity = 100
        imgSpring.layer.add(scaleDown, forKey: nil)
    }

    @objc func startKeyFrameAnimation(){
        let swagger = CAKeyframeAnimation(keyPath: "transform.rotation")
        swagger.duration = 3
        swagger.repeatCount = MAXFLOAT
        swagger.values = [0.0,-Double.pi / 16,0.0,Double.pi / 12,0.0]
        swagger.keyTimes = [0.0,0.25,0.5,0.75,1.0]
        imgKeyframe.layer.add(swagger, forKey: nil)
    }

}
