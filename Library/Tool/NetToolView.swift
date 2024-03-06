//
//  NetToolView.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/3/5.
//

import Foundation
class NetToolView:UIView{
    
    enum NetDiagnosisError:Error{
        case UrlEmpty, urlConvertFail, urlEmptyHost
    }
    
    enum NetInfo{
        case dns([String]), ip([String]), ping(String),pingResult(String),traceRoute(String)
    }
    
    var netTool = NetTool()
    
    var domainInfo:DomainInfo?
    var debugText = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalTo(self)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.right.bottom.equalTo(0)
        }
        
    }
    
    func setdomain(info:DomainInfo){
        if domainInfo?.name == info.name{
            return
        }
        
        lblTitle.text = "诊断域名\(info.url)"
    }
    
    func startDiagnosis(process:((_ info:NetInfo?,_ error:NetDiagnosisError?)->Void)){
        guard let info = domainInfo else {
            process(nil,.UrlEmpty)
            return
        }
        if info.url.isEmpty{
            process(nil,.UrlEmpty)
            return
        }
        guard let url =  URL(string: info.url) else {
            process(nil,.urlConvertFail)
            return
        }
        
        guard let _ = url.host else {
            process(nil,.urlEmptyHost)
            return
        }
        
        let dns = netTool.getLocalDNSAddress()
        process(.dns(dns),nil)
        
       
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lblTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont.pingfangMedium(size: 16)
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        return v
    }()
    
}
