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

}


class KeyboardSettingView:UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func switchClick(sender:UISwitch){
        
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
        v.addSubview(swi)
        swi.addTarget(self, action: #selector(switchClick(sender:)), for: .valueChanged)
        swi.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.width.equalTo(50)
            make.centerY.equalTo(lblTitle)
        }
        
        return v
    }
}
