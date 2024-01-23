//
//  NetToolViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit

class NetToolViewController: UIViewController {
    var netTool = NetTool()
    var netText = ""
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "诊断", style: .plain, target: self, action: #selector(netDiagnosis))
       
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(txtUrl.snp.bottom)
        }
        scrollView.addSubview(lblNetInfo)
        lblNetInfo.snp.makeConstraints { make in
            make.left.top.equalTo(scrollView).offset(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(ScreenWidth - 20)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func netDiagnosis(){
        if txtUrl.text?.isEmpty ?? true{
            Toast.showToast(msg: "请输入URL")
            return
        }
        Task{
            await diagnosis()
            lblNetInfo.text = netText
        }
    
        
    }

     func diagnosis() async{
       
//        if let ip = NetTool().getIpAddress(url: txtUrl.text!){
//            Toast.showToast(msg: "ip是\(ip)")
//        }

        let res = await netTool.checkDNS(url: txtUrl.text!)
         switch res {
         case .success(let ips):
             netText += "获取到的ip有\n"
             for item in ips{
                 netText += item.ip + "\n"
             }
             
         case .failure(let failure):
            let err = failure as NSError
            netText += err.localizedDescription
            
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
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        return v
    }()
    
    lazy var lblNetInfo: UILabel = {
        let v = UILabel()
        v.font = UIFont.pingfangMedium(size: 12)
        v.numberOfLines = 0
        v.textColor = .blue
        return v
    }()
}
