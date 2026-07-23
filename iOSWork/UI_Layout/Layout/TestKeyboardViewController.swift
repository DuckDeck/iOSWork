//
//  TestKeyboardViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/2/21.
//

import UIKit

class TestKeyboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "键盘测试"
        view.backgroundColor = UIColor.white
        let sc = UIScrollView()
        view.addSubview(sc)
        sc.snp.makeConstraints { make in
            make.top.equalTo(55)
            make.left.right.bottom.equalTo(0)
        }
        let panelView = UIStackView()
        panelView.axis = .vertical
        panelView.spacing = 10
        sc.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(30)
            make.width.equalTo(ScreenWidth - 60)
        }
        let input0 = UITextField()
        input0.placeholder = "我是通用输入框"
        panelView.addArrangedSubview(input0)
        input0.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        let input1 = UITextField()
        input1.keyboardType = .webSearch
        input1.placeholder = "我是搜索输入框"
        panelView.addArrangedSubview(input1)
        input1.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        let input2 = UITextField()
        input2.keyboardType = .emailAddress
        input2.placeholder = "我是邮件输入框"
        panelView.addArrangedSubview(input2)
        input2.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        
        let input3 = UITextField()
        input3.keyboardType = .numberPad
        input3.placeholder = "我是数字输入框"
        panelView.addArrangedSubview(input3)
        input3.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        let lbl1 = UILabel()
        
        lbl1.font = UIFont.if_iconFont(16)
        // 纯 Icon
        lbl1.textColor = .darkGray
        lbl1.text = " \(IconNames.kb_type_9)(如果先前是系统键盘，会使用系统数字键盘，否则会启用第三方键盘的)"
        lbl1.numberOfLines = 0
        panelView.addArrangedSubview(lbl1)
        lbl1.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let input4 = UITextField()
        input4.keyboardType = .phonePad
        input4.placeholder = "我是电话输入框(会强制使用系统的数字键盘)"
        panelView.addArrangedSubview(input4)
        input4.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let input5 = UITextField()
        input5.keyboardType = .decimalPad
        input5.placeholder = "我是小数输入框"
        panelView.addArrangedSubview(input5)
        input5.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        let lbl2 = UILabel()
        lbl2.text = "👆(如果先前是系统键盘，会使用系统数字键盘，否则会启用第三方键盘的)"
        lbl2.font = UIFont.systemFont(ofSize: 12)
        lbl2.textColor = UIColor.black
        lbl2.numberOfLines = 0
        panelView.addArrangedSubview(lbl2)
        lbl2.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        let input6 = UITextField()
        input6.isSecureTextEntry = true

        panelView.addArrangedSubview(input6)
        input6.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let input7 = UITextField()
        input7.keyboardType = .namePhonePad
        input7.placeholder = "用户名电话输入框(会强制使用系统键盘)"
        panelView.addArrangedSubview(input7)
        input7.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let input8 = UITextField()
        input8.keyboardType = .numbersAndPunctuation
        input8.placeholder = "numbersAndPunctuation??输入框,会强制使用系统键盘"
        panelView.addArrangedSubview(input8)
        input8.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        let input9 = UITextView()
        panelView.addSubview(input9)
        input9.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        for v in panelView.arrangedSubviews{
            v.layer.borderColor = UIColor.random.cgColor
            v.layer.borderWidth = 1
        }
        
        // Do any additional setup after loading the view.
    }
    



}
