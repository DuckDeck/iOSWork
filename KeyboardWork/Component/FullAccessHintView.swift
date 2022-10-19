//
//  FullAccessHint.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/19.
//

import Foundation
class FullAccessHintView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(hint:String) {
        self.init(frame: .zero)
        lblHint.text = "开启完全访问，\(hint)"
        addSubview(lblHint)
        lblHint.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalTo(self)
        }
        addSubview(btnOpen)
        btnOpen.snp.makeConstraints { make in
            make.left.equalTo(lblHint.snp.right).offset(8)
            make.centerY.equalTo(self)
            make.right.equalTo(-12)
        }
    }
    
    @objc func gotoFullAccess(){
        
    }
    
    lazy var lblHint: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.white
        v.font = UIFont.pingfangRegular(size: 13)
        return v
    }()
    
    lazy var btnOpen: UIButton = {
        let v = UIButton()
        v.setTitle("去开启 ➣", for: .normal)
        v.setTitleColor(UIColor.orange, for: .normal)
        return v
    }()
}
