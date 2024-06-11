//
//  NetToolViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit
import PhoneNetSDK
class NetToolViewController: UIViewController {
    var netTool = NetTool()
    var netText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "网络工具"
        view.addSubview(txtUrl)
        txtUrl.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(UIDevice.topAreaHeight + 50)
            make.right.equalTo(-100)
            make.height.equalTo(30)
        }
//        txtUrl.text = "https://www.szwego.com/"
   
        txtUrl.text = "https://www.wsxcme.com/"
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
        netText = ""
        if txtUrl.text?.isEmpty ?? true{
            Toast.showToast(msg: "请输入URL")
            return
        }
        guard let u = URL(string: txtUrl.text!) else {
            Toast.showToast(msg: "url不合法")
            return
        }
        guard let _ = u.host else {
            Toast.showToast(msg: "url没有host")
            return
        }
        let dnss = netTool.getLocalDNSAddress()
        netText += "获取到本机的DNS地址为："
        for item in dnss{
            netText += "[\(item)],"
        }
        netText += "\n"
        Task{
            let res =  await netTool.getDomainIpAddress(url: txtUrl.text!)
            switch res {
            case .success(let ips):
                netText += "获取IP地址成功\n"
                for item in ips{
                    netText += "[\(item.ip)],"
                }
            case .failure(let failure):
                netText = "获取ip地址失败。原因是\(failure.localizedDescription)"
            }
            lblNetInfo.text = netText
            netText += "\n"
        }
        
        netTool.checkPing(url: txtUrl.text!) {[weak self] str in
            if let s  = str {
                self?.netText += "\(s)\n"
                self?.lblNetInfo.text = self?.netText
            }
        } lossCallback: { [weak self](count,err) in
            if err != nil{
                self?.netText += "\(err!.localizedDescription)\n"
                self?.lblNetInfo.text = self?.netText
            } else {
                //if count > 0 { //说明过多ping不通
                    self?.traceRoute()
               // }
            }
        }
    }


    func traceRoute(){
        netText += "\n开始TraceRoute\n"
        netTool.traceRoute(url: txtUrl.text!) { [weak self] str in
            if let s = str,let txt = self?.netText{
                self?.lblNetInfo.text = txt + (s as String);
            }
        } completeCallback: {[weak self] msg, err in
            if err != nil{
                self?.netText += "\(err!.localizedDescription)\n"
                self?.lblNetInfo.text = self?.netText
            } else {
                print(msg)
            }
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
        v.font = UIFont.pingfangMedium(size: 10)
        v.numberOfLines = 0
        v.textColor = .blue
        return v
    }()
}
