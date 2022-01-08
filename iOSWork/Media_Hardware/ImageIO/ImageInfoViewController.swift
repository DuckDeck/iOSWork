//
//  ImageInfoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/1/8.
//

import Foundation
class ImageInfoViewController:BaseViewController{
    
    var imgView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ImageIO"
        view.backgroundColor = UIColor.white
        let navBtn1 = UIBarButtonItem(title: "网络图片", style: .plain, target: self, action: #selector(chooseNetImage))
        let navBtn2 = UIBarButtonItem(title: "本地图片", style: .plain, target: self, action: #selector(chooseLocalImage))
        navigationItem.rightBarButtonItems = [navBtn1,navBtn2]
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(imgView.snp.width).multipliedBy(1)
        }
        
    }
    
    @objc func chooseNetImage(){
        let vc = SnapkitTableViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.dismissBlock = { url in
            self.getImgInfo(url: url)
        }
        present(vc, animated: true, completion: nil)
    
    }
    
    @objc func chooseLocalImage(){
        
    }
    
    func getImgInfo(url:String){
        var imgInfo = ImageInfo(url: url) { img in
            self.imgView.image = img
            let height = ScreenWidth / (img.size.width / img.size.height)
            self.imgView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
        
        if let info = imgInfo.imageExif{
            
        }
            

    }
    
}
