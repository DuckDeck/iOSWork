//
//  FlowerText.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/12/22.
//

import Foundation
class FlowerTextViewController:UIViewController,UITextFieldDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
//        let lbl = UILabel()
//        lbl.text = "\u{0041}\u{030a}"
//        view.addSubview(lbl)
//        lbl.snp.makeConstraints { make in
//            make.left.equalTo(10)
//            make.top.equalTo(100)
//
//        }
        
        view.addSubview(txtInput)
        txtInput.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(70)
            make.height.equalTo(30)
        }
        
    }
    
//    let k = "你大有你有我什么"
//    var dataenc = k.data(using: String.Encoding.nonLossyASCII)
//    var encodevalue = String(data: dataenc!, encoding: String.Encoding.utf8)
//    let x = encodevalue!.split(separator: "\\u")
//    let xx = x.map { n in
//        "\\u\(n)\\u030a"
//    }.joined()
//
//    var datadec  = xx.data(using: String.Encoding.utf8)
//    var decodevalue = String(data: datadec!, encoding: String.Encoding.nonLossyASCII)
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        var dataenc = str.data(using: String.Encoding.nonLossyASCII)
        var encodevalue = String(data: dataenc!, encoding: String.Encoding.utf8)
        let x = encodevalue!.split("\\u")
        let xx = x.map { n in
            "\\u\(n)\\u030a"
        }.joined()
    
        let datadec  = xx.data(using: String.Encoding.utf8)
        let decodevalue = String(data: datadec!, encoding: String.Encoding.nonLossyASCII)
        return true
    }
    
    lazy var txtInput: UITextField = {
        let v = UITextField()
        v.placeholder  = "请输入花漾字"
        v.textColor = UIColor.carrot
        v.font = UIFont.systemFont(ofSize: 15)
        v.delegate = self
        return v
    }()
}
