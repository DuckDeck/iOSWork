//
//  CalculatorViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/3/6.
//

import UIKit

class CalculatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "计算输入"
        
        
        view.addSubview(textInput)
        textInput.addTarget(self, action: #selector(changeText), for: .editingChanged)
        textInput.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(34)
        }
        
        view.addSubview(lblResult)
        lblResult.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(150)
        }
        
        // Do any additional setup after loading the view.
    }

    @objc func changeText(){
        if let index = getCalIndex(textInput.text!){
            let input = textInput.text!.substring(from: index)
            if !input.isEmpty{
                let res = calculate(input)
                switch res{
                case .value(let num):
                    lblResult.text = "\(num)"
                case .error(let err):
                    lblResult.text = err.message
                }
            }
        }
    }
    
    lazy var lblResult: UILabel = {
        let v = UILabel().setUIFont(font: UIFont.systemFont(ofSize: 18, weight: .bold)).color(color: UIColor.red)
        return v.borderColor(color: UIColor.blue).borderWidth(width: 1)
    }()
    
    lazy var textInput: UITextField = {
        let v = UITextField()
        v.keyboardType = .decimalPad
        v.textColor = UIColor.green
        return v.borderColor(color: UIColor.blue).borderWidth(width: 1)
    }()

}
