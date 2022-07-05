//
//  KeyboardNav.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/5.
//

import UIKit

class KeyboardNav: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
       addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(40)
        }
        
        navBar.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.center.equalTo(navBar)
        }
        
        navBar.addSubview(btnBack)
        btnBack.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(navBar)
        }
        
    }
    
    @objc func back() {
        keyboardVC?.pop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var navBar: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var lblTitle: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.label
        return v
    }()
    
    lazy var btnBack: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        v.addTarget(self, action: #selector(back), for: .touchUpInside)
        return v
    }()
}
