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
        
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(17.5)
            make.height.equalTo(0.5)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(line.snp.bottom)
        }
        
        let btnSetting = UIButton()
        btnSetting.setImage(UIImage(systemName: "gear"), for: .normal)
        btnSetting.addTarget(self, action: #selector(menuClick(sender: )), for: .touchUpInside)
        btnSetting.tag = 1
        stackView.addArrangedSubview(btnSetting)
        btnSetting.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        let btnEmoji = UIButton()
        btnEmoji.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        btnEmoji.addTarget(self, action: #selector(menuClick(sender: )), for: .touchUpInside)
        btnEmoji.tag = 2
        stackView.addArrangedSubview(btnEmoji)
        btnEmoji.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        let btnSwitchKeyboard = UIButton()
        btnSwitchKeyboard.setImage(UIImage(systemName: "globe"), for: .normal)
        btnSwitchKeyboard.addTarget(self, action: #selector(menuClick(sender:)), for: .touchUpInside)
        btnSwitchKeyboard.tag = 3
        stackView.addArrangedSubview(btnSwitchKeyboard)
        btnSwitchKeyboard.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        let btnPasteboard = UIButton()
        btnPasteboard.setImage(UIImage(systemName: "wallet.pass"), for: .normal)
        btnPasteboard.addTarget(self, action: #selector(menuClick(sender:)), for: .touchUpInside)
        btnPasteboard.tag = 4
        stackView.addArrangedSubview(btnPasteboard)
        btnPasteboard.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        stackView.addArrangedSubview(UIView())
        
        let btnCloseKeyboard = UIButton()
        btnCloseKeyboard.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        btnCloseKeyboard.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        stackView.addArrangedSubview(btnCloseKeyboard)
        btnCloseKeyboard.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
    
    @objc func menuClick(sender:UIButton){
        switch sender.tag{
        case 1:
            keyboardVC?.addSettingView()
        case 2:
            globalKeyboard?.switchKeyboard(keyboardType: .emoji)
        case 3:
            keyboardVC?.addSwitchKeyboardView()
        case 4:
            keyboardVC?.addPasteboardView()
        default:
            break
        }
    }
    
    func refreshStatus(){
        let content = keyboardVC?.allText.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if content.isEmpty{
            return
        }
        let res = calculate(content)
        switch res{
        case .value(let num):
            print(num)
        case .error(_):
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
        v.alignment = .center
        return v
    }()
}
