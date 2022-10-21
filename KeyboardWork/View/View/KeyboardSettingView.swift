//
//  KeyboardSettingView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/5/13.
//

import Foundation
import UIKit

struct SettingInfo{
    var title = ""
    var tip = ""
    var isOn = false
    var type:SettingEnum
}

enum SettingEnum : Int{
    case shake = 1
}

class KeyboardSettingView:KeyboardNav{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        title = "键盘设置"
        
        if !keyboardVC!.hasFullAccess{
            let hintView = FullAccessHintView(hint: "体验打字震动等功能")
            hintView.layer.cornerRadius = 12
            addSubview(hintView)
            hintView.snp.makeConstraints { make in
                make.top.equalTo(44)
                make.centerX.equalTo(self)
                make.height.equalTo(24)
            }
        }
        
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(40)
            make.height.lessThanOrEqualTo(232)
        }
        
        let v = createCell(setting: SettingInfo(title: "键盘震动", tip: "开启键盘震动，打字体验更爽", isOn: KeyboardInfo.Shake, type: .shake))
        stackView.addArrangedSubview(v)
        
        let action1 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .unspecified
            keyboardVC?.overrideUserInterfaceStyle = .unspecified
        }
        action1.title = "跟随系统"
        let action2 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .dark
            keyboardVC?.overrideUserInterfaceStyle = .dark
        }
        action2.title = "深色模式"
        let action3 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .light
            keyboardVC?.overrideUserInterfaceStyle = .light
        }
        action3.title = "浅色模式"
        
        let seg = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50),actions: [action1,action2,action3])
        stackView.addArrangedSubview(seg)
        
        let style = UserDefaults.standard.overridedUserInterfaceStyle
        if style == .unspecified{
            seg.selectedSegmentIndex = 0
        } else if style == .light{
            seg.selectedSegmentIndex =  2
        } else {
            seg.selectedSegmentIndex = 1
        }
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func switchClick(sender:UISwitch){
        if  let type = SettingEnum(rawValue: sender.tag){
            switch type {
            case .shake:
                if sender.isOn{
                    if keyboardVC?.hasFullAccess ?? false{
                        KeyboardInfo.Shake = true
                    } else {
                        Toast.showText("请开启完全访问再启用")
                        sender.isOn = false
                    }
                } else {
                    KeyboardInfo.Shake = false
                }
                
            }
        }
    }
    
    func createCell(setting:SettingInfo)->UIView{
        let v = UIView()
        let lblTitle = UILabel()
        lblTitle.text = setting.title
        lblTitle.font = UIFont.pingfangRegular(size: 16)
        lblTitle.textColor = kColor222222
        v.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.height.equalTo(24)
        }
        
        let lblSubTitle = UILabel()
        lblSubTitle.numberOfLines = 0
        lblSubTitle.text = setting.tip
        lblSubTitle.font = UIFont.pingfangMedium(size: 12)
        lblSubTitle.textColor = kColor888888
        v.addSubview(lblSubTitle)
        lblSubTitle.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(lblTitle.snp.bottom).offset(6)
            make.right.equalTo(-56)
            make.bottom.equalTo(-18)
        }
        
        let swi = UISwitch()
        swi.isOn = setting.isOn
        swi.tag = setting.type.rawValue
        v.addSubview(swi)
        swi.addTarget(self, action: #selector(switchClick(sender:)), for: .valueChanged)
        swi.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.equalTo(50)
            make.centerY.equalTo(lblTitle)
        }
        
        return v
    }
    
    lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        return v
    }()
}
