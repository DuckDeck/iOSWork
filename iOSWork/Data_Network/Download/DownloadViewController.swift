//
//  DownloadViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/2/23.
//

import Foundation
import UIKit
import SnapKit
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
        
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(200)
            make.height.equalTo(400)
        }
        imgView.setImg(url: "https://wx1.sinaimg.cn/large/008heIDbgy1hhlhzs8falj30u013z46f.jpg")
    }
    
    @objc func startDownload(){
//        let urls = ["http://lovelive.ink:9001/video/RockNRoll.mkv","http://lovelive.ink:9001/img/16295348101.jpg","http://lovelive.ink:9001/img/16295368926.jpg","http://lovelive.ink:9001/img/1630211243z2.jpg"]
        let urls = ["https://xcimg.szwego.com/20210116/a1610803638361_1135.jpg"]
        Toast.showLoading()
        
        MediaTool.downloadToFile(resources: urls) { failCount, paths in
            Toast.dismissLoading()
            print(paths)
        }
    }

    lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
}
