//
//  ThemeViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/7/10.
//

import Foundation
class ThemeViewController:BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "main_color")
        title = "主题切换"
        let action1 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .unspecified
            self.updateStyle(style: .unspecified)
        }
        action1.title = "跟随系统"
        let action2 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .dark
            self.updateStyle(style: .dark)
        }
        action2.title = "深色模式"
        let action3 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .light
            self.updateStyle(style: .light)
        }
        action3.title = "浅色模式"
        
        let seg = UISegmentedControl(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 50),actions: [action1,action2,action3])
        view.addSubview(seg)
        
        view.addSubview(btnRevertImage)
        btnRevertImage.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(200)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(img)
        img.image = UIImage(named: "2")
        img.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(300)
            make.height.lessThanOrEqualTo(400)
        }
    }

    func updateStyle(style:UIUserInterfaceStyle){
        UIApplication.shared.override(style)
        UserDefaults.standard.overridedUserInterfaceStyle = style
        if style == .dark{
            img.image = UIImage(named: "2")?.revertColor()
        } else {
            img.image = UIImage(named: "2")
        }
    }
    
    @objc func revertImage(){
        img.image = img.image?.revertColor()
    }
    
    lazy var img: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    lazy var btnRevertImage:UIButton = {
        let v = UIButton()
        v.setTitle("反转图片", for: .normal)
        v.setTitleColor(UIColor.label, for: .normal)
        v.addTarget(self, action: #selector(revertImage), for: .touchUpInside)
        v.isHidden = true
        return v
    }()

}


