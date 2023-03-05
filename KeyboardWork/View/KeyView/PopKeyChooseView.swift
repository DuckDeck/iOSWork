//
//  PopKeyChooseView.swift
//  WGKeyBoard
//
//  Created by Stan Hu on 2022/7/12.
//

import Foundation
import UIKit
class PopKeyChooseView:UIView{
    
    var keys : [SymbleInfo]!

    private var _selectIndex = -1
    var selectIndex : Int{
        set{
            if !keys.isEmpty && newValue >= keys.count{
                return
            }
            if newValue < 0{
                return
            }
            Shake.keyShake()
            if _selectIndex != newValue{
                if _selectIndex >= 0{
                    let lblOld = stackView.arrangedSubviews[_selectIndex] as! UILabel
                    lblOld.textColor = Colors.color222222
                    if #available(iOSApplicationExtension 12.0, *) {
                        if traitCollection.userInterfaceStyle == .dark{
                            lblOld.textColor = UIColor.white
                        }
                    }
                    lblOld.backgroundColor = cKeyBgColor
                    if let lblAngle = lblOld.viewWithTag(100) as? UILabel{
                        lblAngle.textColor = Colors.color222222
                        if #available(iOSApplicationExtension 12.0, *) {
                            if traitCollection.userInterfaceStyle == .dark{
                                lblAngle.textColor = UIColor.white
                            }
                        }
                    }
                }
                _selectIndex = newValue
                let lblNew = stackView.arrangedSubviews[_selectIndex] as! UILabel
                lblNew.textColor = UIColor.white
                lblNew.backgroundColor = Colors.color49C167
                if let lblAngle = lblNew.viewWithTag(100) as? UILabel{
                    lblAngle.textColor = UIColor.white
                }
            }
        }
        get{
            return _selectIndex
        }
    }
    var selectedText:String{
        return self.keys[self.selectIndex].text
    }
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect,keys:[SymbleInfo],defaultIndex:Int = -1) {
        self.init(frame: frame)
        backgroundColor = cKeyBgColor
        self.keys = keys
        layer.cornerRadius = 12
        layer.borderColor = cPopChooseBorderColor.cgColor
        layer.borderWidth = 0.5
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.top.equalTo(4)
            make.bottom.right.equalTo(-4)
        }
        let itemWidth = kSCREEN_WIDTH <= 320 ? 30 : 36
        let fontSize : CGFloat = kSCREEN_WIDTH <= 320 ? 25 : 30
        for item in keys.enumerated(){
            let lbl = UILabel()
            lbl.text = String(item.element.text)
            lbl.textColor = cKeyTextColor
            lbl.textAlignment = .center
            lbl.layer.cornerRadius = 8
            lbl.clipsToBounds = true
            if item.element.text.count > 1{
                lbl.font =  UIFont.paleRegular(size: 15)
            } else {
                lbl.font =  UIFont.paleRegular(size: fontSize)
            }
            stackView.addArrangedSubview(lbl)
            lbl.snp.makeConstraints { make in
                make.width.equalTo(itemWidth)
                make.height.equalTo(44)
            }
            if let angle = item.element.angle{
                let lblAngle = UILabel()
                lblAngle.text = angle == .fullAngle ? "全" : "半"
                lblAngle.font = UIFont.systemFont(ofSize: 8)
                lblAngle.tag = 100
                lblAngle.textColor = cKeyTextColor
                lbl.addSubview(lblAngle)
                lblAngle.snp.makeConstraints { make in
                    make.top.equalTo(2)
                    make.right.equalTo(-2)
                }
            }
        }
        if defaultIndex >= 0{
            self.selectIndex = defaultIndex
        } else {
            self.selectIndex = keys.count / 2
        }
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        return v
    }()
    
}
