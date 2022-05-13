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
        
        let panelView = UIStackView()
        panelView.axis = .vertical
        panelView.spacing = 10
        view.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
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
        
        let input4 = UITextField()
        input4.keyboardType = .phonePad
        input4.placeholder = "我是电话输入框"
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
        
        let input6 = UITextField()
        input6.isSecureTextEntry = true

        panelView.addArrangedSubview(input6)
        input6.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        for v in panelView.arrangedSubviews{
            v.layer.borderColor = UIColor.random.cgColor
            v.layer.borderWidth = 1
        }
        
        // Do any additional setup after loading the view.
    }
    



}
