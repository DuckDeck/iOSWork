//
//  ScaleViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/2/10.
//

import UIKit
import SnapKit

class ScaleViewController: UIViewController {

 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "视图缩放"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "生成图片", style: .plain, target: self, action: #selector(createImg))
        
        view.addSubview(imgScale)
        imgScale.clipsToBounds = true
        imgScale.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)

            make.width.equalTo(ScreenWidth)
        }
        
  
        
        view.addSubview(btnStep)
        btnStep.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(100)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func stepChange(sender:UIStepper){
        print(sender.value)
        
        imgScale.transform = CGAffineTransform(scaleX: sender.value, y: sender.value)
        
    }
    
    @objc func createImg(){

        let img = imgScale.asImage()
        print(img.size)
//        img.saveToAlbum()
        print(img.memorySize)
        UIPasteboard.general.image = img
        
        
    }
    
    
    lazy var btnStep: UIStepper = {
        let v = UIStepper()
        v.stepValue = 0.1
        v.maximumValue = 2
        v.minimumValue = 0
        v.addTarget(self, action: #selector(stepChange(sender:)), for: .valueChanged)
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var imgScale: UIImageView = {
        let v = UIImageView(image: UIImage(named: "3"))
        v.contentMode = .scaleAspectFill
        return v
    }()
 
}
