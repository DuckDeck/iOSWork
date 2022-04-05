//
//  PopKeyChooseView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

class PopKeyChooseView:UIView{
    
    var keys:String!
    
    private var _selectIndex = 0
    var selectIndex : Int{
        set{
            if newValue >= keys.count{
                return
            }
            if newValue < 0{
                return
            }
            if _selectIndex != newValue{
                let lblOld = stackView.arrangedSubviews[_selectIndex] as! UILabel
                lblOld.textColor = UIColor(hexString: "222222")
                lblOld.backgroundColor = UIColor.white
                _selectIndex = newValue
                let lblNew = stackView.arrangedSubviews[_selectIndex] as! UILabel
                lblNew.textColor = UIColor.white
                lblNew.backgroundColor = UIColor(hexString: "49c167")
            }
        }
        get{
            return _selectIndex
        }
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect,keys:String) {
        self.init(frame: frame)
        backgroundColor = UIColor.white
        self.keys = keys
        layer.cornerRadius = 5
        layer.borderColor = UIColor(hexString:  "bbbbbb")?.cgColor
        layer.borderWidth = 0.5
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.top.equalTo(4)
            make.bottom.right.equalTo(-4)
        }
        
        for item in keys.enumerated(){
            let lbl = UILabel()
            lbl.text = String(item.element)
            lbl.font =  UIFont(name: "PingFangSC-Regular", size: 24)
            lbl.textColor = UIColor(hexString: "222222")
            lbl.textAlignment = .center
            lbl.layer.cornerRadius = 4
            lbl.clipsToBounds = true
            stackView.addArrangedSubview(lbl)
            lbl.snp.makeConstraints { make in
                make.width.equalTo(30)
                make.height.equalTo(44)
            }
        }
        self.selectIndex = keys.count / 2
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
