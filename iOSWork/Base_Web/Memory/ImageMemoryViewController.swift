//
//  ImageMemoryViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/2/20.
//

import UIKit

class ImageMemoryViewController: UIViewController {

    let btnOpenImage = UIButton()
    let btnShowImage = UIButton()
    var img:UIImage?
    let imgView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "图片内存关系"
        view.backgroundColor = UIColor.white
        let panelView = UIStackView()
        panelView.axis = .horizontal
        view.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(50)
        }
        panelView.addArrangedSubview(btnOpenImage)
        btnOpenImage.title(title: "打开8k图片").color(color: UIColor.random).snp.makeConstraints { make in
            make.height.equalTo(50)
            
        }
        
        btnOpenImage.addTarget(self, action: #selector(openImage), for: .touchUpInside)
        panelView.addArrangedSubview(btnShowImage)
        btnShowImage.title(title: "显示8k图片").color(color: UIColor.random).snp.makeConstraints { make in
            make.height.equalTo(50)
            
        }
        btnShowImage.addTarget(self, action: #selector(ShowImage), for: .touchUpInside)

        view.addSubview(imgView)
        imgView.layer.borderColor = UIColor.random.cgColor
        imgView.layer.borderWidth = 1
        imgView.contentMode = .scaleAspectFit
        imgView.snp.makeConstraints { make in
            make.top.equalTo(panelView.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(imgView.snp.width).multipliedBy(1)
        }
        
    }
    
    @objc func openImage(){
        let img = UIImage(named: "8k")
        self.img = img
        Toast.showToast(msg: "打开图片。img占用内存为\(img!.memorySize)")
    }

    @objc func ShowImage(){
        imgView.image = img
    }
    


}
