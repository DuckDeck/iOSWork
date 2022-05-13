//
//  HeaderView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit

class Header:UIView{
    
}

class HeaderView: Header {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(30)
        }
        
        let btnSetting = UIButton()
        
        btnSetting.setImage(UIImage.yh_imageNamed("icon_setting_set"), for: .normal)
        btnSetting.addTarget(self, action: #selector(menuClick(sender: )), for: .touchUpInside)
        btnSetting.tag = 1
        stackView.addArrangedSubview(btnSetting)
        btnSetting.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        let btnSwitchKeyboard = UIButton()
        btnSwitchKeyboard.setImage(UIImage.yh_imageNamed("icon_setting_keyboard_typeinchange_normal"), for: .normal)
        btnSwitchKeyboard.addTarget(self, action: #selector(menuClick(sender:)), for: .touchUpInside)
        btnSwitchKeyboard.tag = 2
        stackView.addArrangedSubview(btnSwitchKeyboard)
        btnSwitchKeyboard.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        stackView.addArrangedSubview(UIView())
        
        let btnCloseKeyboard = UIButton()
        btnCloseKeyboard.setImage(UIImage.yh_imageNamed("icon_menu_close_keyboard"), for: .normal)
        btnCloseKeyboard.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        stackView.addArrangedSubview(btnCloseKeyboard)
        btnCloseKeyboard.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        
        
    }
    
    @objc func menuClick(sender:UIButton){
        switch sender.tag{
        case 2:
            keyboardVC?.addSwitchKeyboardView()
        default:
            break
        }
    }
    
    @objc func closeClick(){
        keyboardVC?.dismissKeyboard()
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
