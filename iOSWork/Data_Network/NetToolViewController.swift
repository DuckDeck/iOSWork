//
//  NetToolViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit

class NetToolViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网络工具"
        
       
        view.addSubview(txtUrl)
        txtUrl.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(UIDevice.topAreaHeight + 50)
            make.right.equalTo(-100)
            make.height.equalTo(30)
        }
        txtUrl.text = "https://www.szwego.com/"
        
        let btnGetIp = UIButton()
        btnGetIp.setTitle("获取IP", for: .normal)
        btnGetIp.addTarget(self, action: #selector(getIp), for: .touchUpInside)
        view.addSubview(btnGetIp)
        btnGetIp.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.width.equalTo(100)
            make.centerY.equalTo(txtUrl)
            make.height.equalTo(30)
        }
        // Do any additional setup after loading the view.
    }
    

    @objc func getIp(){
        if txtUrl.text?.isEmpty ?? true{
            Toast.showToast(msg: "请输入URL")
            return
        }
        if let ip = NetTool().getIpAddress(url: txtUrl.text!){
            Toast.showToast(msg: "ip是\(ip)")
        }
        
    }

    lazy var txtUrl: UITextField = {
        let v = UITextField()
        v.placeholder = "输入url"
        v.layer.borderWidth = 0.5
        v.layer.cornerRadius = 4
        v.layer.borderColor = UIColor.silver.cgColor
        return v
    }()
}
