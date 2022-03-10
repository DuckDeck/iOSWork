//
//  ExtraView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import UIKit
class ExtraView: UIView {
    
    var globalColors: GlobalColors.Type?
    var darkMode: Bool
    var solidColorMode: Bool
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        self.globalColors = globalColors
        self.darkMode = darkMode
        self.solidColorMode = solidColorMode
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.white
        
        addSubview(btnBack)
        btnBack.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.globalColors = nil
        self.darkMode = false
        self.solidColorMode = false
        
        super.init(coder: aDecoder)
    }
    
    @objc func back(){
        removeFromSuperview()
    }
    
    lazy var btnBack: UIButton = {
        let v = UIButton()
        v.setTitle("返回", for: .normal)
        v.setTitleColor(UIColor.red, for: .normal)
        v.addTarget(self, action: #selector(back), for: .touchUpInside)
        return v
    }()
    
    lazy var stackView: UIStackView = {
        let v = UIStackView()
        return v
    }()
    
}
