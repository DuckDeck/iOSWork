//
//  SwitchKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/5/7.
//

import Foundation
import UIKit
class SwitchKeyboardView:KeyboardNav{
    override init(frame: CGRect) {
        super.init(frame: frame)
        title = "切换键盘"
        backgroundColor = UIColor.white
       addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(100)
        }
        
        stackView.addArrangedSubview(btn9Key)
        stackView.addArrangedSubview(btn26Key)
        stackView.addArrangedSubview(btnEngKey)
        
    }
    
    
    @objc func switchKeyboard(sender:UIButton){
        switch sender.tag{
        case 1:
            KeyboardInfo.KeyboardType = .chinese9
        case 2:
            KeyboardInfo.KeyboardType = .chinese26
        case 3:
            KeyboardInfo.KeyboardType = .english
        default:
            break
        }
        
        keyboardVC?.popToKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.spacing = 20
        return v
    }()
    
    lazy var btn9Key: LayoutButton = {
        let v = LayoutButton()
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_zh9_normal"), for: .normal)
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_zh9_normal"), for: .selected)
        v.setTitle("中文9键", for: .normal)
        v.titleLabel?.font = UIFont.pingfangRegular(size: 12)
        v.setTitleColor(kColor222222, for: .normal)
        v.layoutStyle = .TopImageBottomTitle
        v.midSpacing = 4
        v.imageSize = CGSize(width: 32, height: 32)
        v.frame = CGRect(x: 0, y: 0, width: 76, height: 70)
        v.tag = 1
        v.addTarget(self, action: #selector(switchKeyboard(sender:)), for: .touchUpInside)
        return v
    }()
    
    lazy var btn26Key: LayoutButton = {
        let v = LayoutButton()
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_zh26_normal"), for: .normal)
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_zh26_normal"), for: .selected)
        v.setTitle("中文26键", for: .normal)
        v.titleLabel?.font = UIFont.pingfangRegular(size: 12)
        v.setTitleColor(kColor222222, for: .normal)
        v.layoutStyle = .TopImageBottomTitle
        v.midSpacing = 4
        v.imageSize = CGSize(width: 32, height: 32)
        v.frame = CGRect(x: 0, y: 0, width: 76, height: 70)
        v.tag = 2
        v.addTarget(self, action: #selector(switchKeyboard(sender:)), for: .touchUpInside)
        return v
    }()
    
    lazy var btnEngKey: LayoutButton = {
        let v = LayoutButton()
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_eng_normal"), for: .normal)
        v.setImage(UIImage.yh_imageNamed("icon_setting_choose_eng_normal"), for: .selected)
        v.setTitle("英文26键", for: .normal)
        v.titleLabel?.font = UIFont.pingfangRegular(size: 12)
        v.setTitleColor(kColor222222, for: .normal)
        v.layoutStyle = .TopImageBottomTitle
        v.midSpacing = 4
        v.imageSize = CGSize(width: 32, height: 32)
        v.frame = CGRect(x: 0, y: 0, width: 76, height: 70)
        v.tag = 3
        v.addTarget(self, action: #selector(switchKeyboard(sender:)), for: .touchUpInside)
        return v
    }()
}
