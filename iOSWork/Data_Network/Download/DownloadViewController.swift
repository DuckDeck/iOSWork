//
//  DownloadViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/2/23.
//

import Foundation
import UIKit
class DownloadViewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "文件下载"
        view.backgroundColor = UIColor.white
        
        
        let btnDownload = UIButton().title(title: "开始下载").setFont(font: 16).color(color: UIColor.random).addTo(view: view)
        btnDownload.addTarget(self, action: #selector(startDownload), for: .touchUpInside)
        btnDownload.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(100)
        }
        
        
    }
    
    @objc func startDownload(){
        let urls = ["http://lovelive.ink:9001/video/RockNRoll.mkv","http://lovelive.ink:9001/img/16295348101.jpg","http://lovelive.ink:9001/img/16295368926.jpg","http://lovelive.ink:9001/img/1630211243z2.jpg"]
        
        Toast.showLoading()
        
        MediaTool.downloadToFile(resources: urls) { failCount, paths in
            Toast.dismissLoading()
            print(paths)
        }
    }

}
