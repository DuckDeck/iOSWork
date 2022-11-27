//
//  HeaderPasteboardView.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit
import SwiftyJSON
class HeaderPasteboardView: UIView {

    var pastText = ""
    var recognizes:[RecognizeType]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(btnClose)
        addSubview(textLabel)
        addSubview(stackView)
        let line = UIView()
        line.backgroundColor = Colors.colorF5F5F5
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
            make.top.equalTo(43)
        }
        textLabel.snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.left.equalTo(12)
            m.right.equalTo(-44)
            m.height.equalTo(44)
        }
        
        btnClose.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(36)
            make.bottom.equalTo(0)
        }
    }
    
 
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPastString(text:String,recognize:[RecognizeType]){
        self.pastText = text
        textLabel.text = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\n", with: "")
        self.recognizes = recognize
        stackView.arrangedSubviews.forEach{$0.removeFromSuperview()}
        for item in recognize{
            let btn = UIButton()
            switch item {
            case .phone(_):
                btn.setImage(UIImage.tintImage("icon_pastboard_choose_phone", color: UIColor(hexString: "bfc1c6")!.withAlphaComponent(0.6)), for: .normal)
                btn.addTarget(self, action: #selector(choosePhone), for: .touchUpInside)
            case .wechat(_):
                btn.setImage(UIImage.tintImage("icon_pastboard_choose_wechat", color: UIColor(hexString: "bfc1c6")!.withAlphaComponent(0.6)), for: .normal)
                btn.addTarget(self, action: #selector(chooseWechat), for: .touchUpInside)
            }
            stackView.addArrangedSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(36)
            }
        }
        
        let btnChoose = UIButton()
        btnChoose.isHidden = text.isEmpty
        btnChoose.setImage(UIImage.tintImage("icon_pastboard_splt_word", color: UIColor(hexString: "bfc1c6")!.withAlphaComponent(0.6)), for: .normal)
        btnChoose.addTarget(self, action: #selector(chooseWord), for: .touchUpInside)
        stackView.addArrangedSubview(btnChoose)
        btnChoose.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
       
    }
    @objc func close(){
        PastboardManage.addKeyboardPastString(str: pastText)
        removeFromSuperview()
    }
   
    @objc func chooseWord(){
        Toast.showProgress()
       
    }

    
    @objc func choosePhone(){
        for item in recognizes!{
            switch item {
            case .phone(let str):
                PastboardManage.addKeyboardPastString(str: str)
                PastInfo.insert(str: str)
                UIPasteboard.general.string = str
                Toast.showText("已经复制手机号")
            case .wechat(_):
                break
            }
        }
        removeFromSuperview()
    }
    
    @objc func chooseWechat(){
        for item in recognizes!{
            switch item {
            case .phone(_):
                break
            case .wechat(let str):
                PastboardManage.addKeyboardPastString(str: str)
                UIPasteboard.general.string = str
                PastInfo.insert(str: str)
                Toast.showText("已经复制微信号")
            }
        }
        removeFromSuperview()
    }
  
    @objc func chooseText(){
        removeFromSuperview()
        keyboardVC?.insert(text: pastText)
//        globalKeyboard?.keyboard?.updateReturnKey(key: ReturnKey)
    }
    
    lazy var textLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "PingFangSC-Regular", size: 18)
        lbl.textColor = cKeyTextColor
        lbl.textAlignment = .left
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseText))
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(tap)
        return lbl
    }()

    
    lazy var btnClose: UIButton = {
        let v = UIButton()
        v.setImage(UIImage.tintImage("icon_clear_balck", color: UIColor.white), for: .normal)
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        v.backgroundColor = UIColor.white
        return v
    }()

    
    lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 10
        v.alignment = .center
        return v
    }()

}
