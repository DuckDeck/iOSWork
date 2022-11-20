//
//  SwitchKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/5/7.
//

import Foundation
import UIKit
class SwitchKeyboardView:KeyboardNav{
    var icons = [("icon_setting_choose_zh9_normal","中文9键"),("icon_setting_choose_zh26_normal","中文26键"),
                 ("icon_setting_choose_eng_normal","英文26键"),("icon_setting_switch_keyboard","切换输入法")]
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        title = "切换键盘"
        addSubview(settingGrid)
        settingGrid.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.width.greaterThanOrEqualTo(kSCREEN_WIDTH - 56)
            make.top.equalTo(44)
            make.height.greaterThanOrEqualTo(250)
            make.bottom.equalTo(0)
        }
        
        
        var btns = [UIView]()


        for item in icons.enumerated() {
            let btn = LayoutButton()
            btn.imageSize = CGSize(width: 32, height: 32)
            btn.layoutStyle = .TopImageBottomTitle
            btn.midSpacing = 8
            btn.layer.cornerRadius = 8
            btn.tag = item.offset + 1
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitleColor(Colors.color222222, for: .normal)
            btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
            btn.setTitle(item.element.1, for: .normal)
            btn.setBackgroundColor(color: UIColor(hexString: "202f64")!.withAlphaComponent(0.06), forState: .highlighted)
            btn.setImage(UIImage.yh_imageNamed(item.element.0), for: .normal)
            btns.append(btn)
            
        }
        
        settingGrid.arrViews = btns
        
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   
    
    lazy var settingGrid: GridView = {
        let v = GridView()
        v.cellSize = CGSize(width: 109, height: 93)
        v.maxWidth = kSCREEN_WIDTH
        v.horizontalSpace = 8
        v.verticalSpace = 8
        let margin = (kSCREEN_WIDTH - 343) / 2
        v.padding = UIEdgeInsets(top: 16, left: margin, bottom: 16, right: margin)
        return v
    }()
    
    @objc func btnClick(sender:UIButton){
        switch sender.tag{
        case 1:
            KeyboardInfo.KeyboardType = .chinese9
        case 2:
            KeyboardInfo.KeyboardType = .chinese26
        case 3:
            
            let exception = NSException(name: NSExceptionName(rawValue:"arbitrary"), reason:"arbitrary reason", userInfo: nil)
                exception.raise()
            
            KeyboardInfo.KeyboardType = .english
        case 4:
            keyboardVC?.switchKeyboard()
        default:break
        }
        if sender.tag < 4{
            globalKeyboard = nil
            keyboardVC?.popToKeyboard()
        }
    }
    
 
  
}
