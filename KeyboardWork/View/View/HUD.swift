//
//  HUD.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/5.
//

import UIKit

class Hud: UIView,CAAnimationDelegate {
    
    var forwardAnimationDuration:CFTimeInterval = 0.3
    var backwardAnimationDuration:CFTimeInterval = 0.2
    var waitAnimationDuration:CFTimeInterval = 1.0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() -> Void {
        addSubview(containerView)
        containerView.addSubview(activityView)
        containerView.addSubview(text)
        containerView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(self)
            make.width.height.equalTo(50)
        }
        self.activityView.snp.makeConstraints({ (maker) in
            maker.centerX.equalTo(self.containerView.snp.centerX)
            maker.centerY.equalTo(self.containerView.snp.centerY)
            maker.width.height.equalTo(10)
        })
        
        self.text.snp.makeConstraints ({ (maker) in
            maker.left.right.equalTo(self.containerView)
            maker.top.bottom.equalTo(self.containerView)
        })
    }
    
    @objc func showProgress() -> Void {
        if superview == nil{
            keyboardVC?.view.addSubview(self)
            snp.makeConstraints { make in
                make.center.equalTo(keyboardVC!.view)
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
        self.containerView.snp.updateConstraints { (make) in
            make.centerY.centerX.equalTo(self)
            make.width.height.equalTo(50)
        }
        self.isHidden = false
        self.superview?.bringSubviewToFront(self)
        containerView.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        self.text.isHidden = true
    }
    
    @objc func hide() -> Void {
        self.isHidden = true
        self.activityView.isHidden = true
        self.text.isHidden = true
    }
    
    @objc func showText(_ text: String,duration:Double = 1.0) -> Void {
        if superview == nil{
            keyboardVC?.view.addSubview(self)
            snp.makeConstraints { make in
                make.center.equalTo(keyboardVC!.view)
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
        self.waitAnimationDuration = duration
        self.hide()
        self.text.layer.removeAllAnimations()
        if !self.isHidden {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        self.superview?.bringSubviewToFront(self)
        containerView.backgroundColor = UIColor.clear
        let size = text.textSizeWithFont(font: self.text.font, constrainedToSize: CGSize(width: kSCREEN_WIDTH, height: 20))
        self.containerView.snp.updateConstraints { (make) in
            make.centerY.centerX.equalTo(self)
            make.width.equalTo(size.width + 18)
            make.height.equalTo(size.height + 18)
        }
        self.isHidden = false
        self.activityView.isHidden = true
        self.text.isHidden = false
        self.text.text = text
       
        self.addAnimationGroup()
    }
    
    func addAnimationGroup(){
        let forwardAnimation = CABasicAnimation(keyPath: "transform.scale")
        forwardAnimation.duration = self.forwardAnimationDuration
        forwardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.7, 0.6, 0.85)
        forwardAnimation.fromValue = 0
        forwardAnimation.toValue = 1
        
        let backWardAnimation = CABasicAnimation(keyPath: "transform.scale")
        backWardAnimation.duration = self.backwardAnimationDuration
        backWardAnimation.beginTime = forwardAnimation.duration + waitAnimationDuration
        backWardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.15, 0.5, -0.7)
        backWardAnimation.fromValue = 1
        backWardAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [forwardAnimation,backWardAnimation]
        animationGroup.duration = forwardAnimation.duration + backWardAnimation.duration + waitAnimationDuration
        animationGroup.isRemovedOnCompletion = false
        animationGroup.delegate = self
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        text.layer.add(animationGroup, forKey: "animation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.hide()
        }
    }
    
    lazy var containerView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView.init()
        ac.style = UIActivityIndicatorView.Style.gray
        ac.color = UIColor.white
        return ac
    }()
    
    lazy var text: UILabel = {
        let text = UILabel.init()
        text.font = UIFont.systemFont(ofSize: 17)
        text.textColor = UIColor.white
        text.backgroundColor = UIColor(white: 0, alpha: 0.7)
        text.textAlignment = .center
        return text
    }()
    deinit {
        print("==============\(self.self) deinit==============")
    }
}
