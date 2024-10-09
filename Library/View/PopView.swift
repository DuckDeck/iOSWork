//
//  PopView.swift
//  WGKeyboard
//
//  Created by Stan Hu on 2024/9/5.
//  Copyright © 2024 WeAblum. All rights reserved.
//

import Foundation

struct MenuButton {
    var font = UIFont.pingfangMedium(size: 14)
    var color = UIColor.black
    var text = ""
    var img: UIImage?
    var height: CGFloat = 48
}
    
struct MenuTitle {
    var font = UIFont.pingfangMedium(size: 14)
    var color = UIColor.black
    var text = ""
    var height: CGFloat = 64 // 整个title高度，副标题不用这个
}

enum PopStyle {
    case pop, sheet
}

class PopView: UIView, UIGestureRecognizerDelegate {
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private var contentHeight: CGFloat = 0
    var clickBlock: ((_ index: Int) -> Void)?
    var popStyle: PopStyle = .pop
    
    
    /// 初始化popview
    /// - Parameters:
    ///   - title: 标题
    ///   - subTitle: 副标题
    ///   - buttons: 按钮
    ///   - popStyle: 样式
    convenience init(title: MenuTitle?, subTitle: MenuTitle?, buttons: [MenuButton], popStyle: PopStyle) {
        self.init(frame: .zero)
        backgroundColor = .black.withAlphaComponent(0.7)
        self.popStyle = popStyle
        addSubview(vContent)
        
        vContent.snp.makeConstraints { make in
            if popStyle == .sheet {
                make.left.right.bottom.equalTo(0)
            } else {
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.7)
            }
        }
        
        if let title = title {
            let vHead = UIView()
            vContent.addSubview(vHead)
            vHead.snp.makeConstraints { make in
                make.left.top.right.equalTo(0)
                make.height.equalTo(title.height)
            }
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.alignment = .center
            vHead.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            let lblTitle = UILabel()
            lblTitle.text = title.text
            lblTitle.font = title.font
            lblTitle.textColor = title.color
            stackView.addArrangedSubview(lblTitle)
            
            if let subTitle = subTitle {
                let lblSubTitle = UILabel()
                lblSubTitle.text = subTitle.text
                lblSubTitle.font = subTitle.font
                lblSubTitle.textColor = subTitle.color
                stackView.addArrangedSubview(lblSubTitle)
            }
        }
        
        var top = title?.height ?? 0
        for item in buttons.enumerated() {
            let line = UIView().bgColor(color: .lightText.withAlphaComponent(0.08))
            vContent.addSubview(line)
            line.snp.makeConstraints { make in
                make.top.equalTo(top)
                make.left.right.equalTo(0)
                make.height.equalTo(1)
            }
            
            let btn = LayoutButton()
            if let img = item.element.img {
                btn.setImage(img, for: .normal)
                btn.midSpacing = 8
                btn.imageSize = img.size
            } else {
                btn.imageSize = CGSizeZero
                btn.midSpacing = 0
            }
            btn.setTitle(item.element.text, for: .normal)
            btn.setTitleColor(item.element.color, for: .normal)
            btn.titleLabel?.font = item.element.font
            btn.tag = item.offset + 800
            btn.setBackgroundColor(color: .white, forState: .normal)
            btn.setBackgroundColor(color: .lightText.withAlphaComponent(0.06), forState: .highlighted)
            btn.addTarget(self, action: #selector(click(sender:)), for: .touchUpInside)
            vContent.addSubview(btn)
            if popStyle == .sheet || buttons.count >= 3 {
                btn.snp.makeConstraints { make in
                    make.top.equalTo(top + 1)
                    make.left.right.equalTo(0)
                    make.height.equalTo(item.element.height)
                    if item.offset == buttons.count - 1 {
                        make.bottom.equalTo(0)
                    }
                }
                top += item.element.height
            } else {
                btn.snp.makeConstraints { make in
                    make.top.equalTo(top + 1)
                    make.bottom.equalTo(0)
                    if item.offset == 0 {
                        make.left.equalToSuperview()
                    } else {
                        make.right.equalToSuperview()
                    }
                    make.height.equalTo(item.element.height)
                    make.width.equalToSuperview().multipliedBy(buttons.count == 1 ? 1 : 0.5)
                }
                if buttons.count == 2 {
                    let line = UIView().bgColor(color: .lightText.withAlphaComponent(0.08))
                    vContent.addSubview(line)
                    line.snp.makeConstraints { make in
                        make.centerY.equalTo(btn)
                        make.centerX.equalToSuperview()
                        make.height.equalTo(btn).multipliedBy(0.7)
                        make.width.equalTo(1)
                    }
                }
            }
        }
        layoutIfNeeded()
        if popStyle == .sheet || buttons.count >= 3 {
            contentHeight = top
        } else {
            contentHeight = top + buttons[0].height
        }
        if popStyle == .sheet {
            vContent.snp.updateConstraints { make in
                make.bottom.equalTo(top)
            }
        }
        
        isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(tap(ges:)))
        addGestureRecognizer(ges)
        ges.delegate = self
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        layoutIfNeeded()
        
        if self.popStyle == .sheet {
            UIView.animate(withDuration: 0.3) {
                self.vContent.snp.updateConstraints { make in
                    make.bottom.equalTo(0)
                }
                self.layoutIfNeeded()
            }
        } else {
            self.vContent.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            UIView.animate(withDuration: 0.15) {
                self.vContent.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: popStyle == .sheet ? 0.3 : 0.15) {
            if self.popStyle == .sheet {
                self.vContent.snp.updateConstraints { make in
                    make.bottom.equalTo(self.contentHeight)
                }
                self.layoutIfNeeded()
            } else {
                self.vContent.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func click(sender: UIButton) {
        clickBlock?(sender.tag - 800)
        dismiss()
    }
    
    @objc func tap(ges: UITapGestureRecognizer) {
        dismiss()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if vContent.frame.contains(touch.location(in: self)) {
            return false
        }
        return true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var vContent: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        if popStyle == .sheet {
            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        return v
    }()
}
