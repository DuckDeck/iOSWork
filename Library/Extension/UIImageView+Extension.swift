//
//  UIImageView+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
extension UIImageView{
    
    func setImg(url:String?){
        setImg(url: url, completed: nil, placeHolder: nil)
    }
    
    func setImg(url:String?,  completed:((_ img:UIImage)->Void)?,placeHolder:String?,errorHolder:String="file_not_exist")  {
        if(url==nil||url!.count==0){
            self.image = UIImage(named: errorHolder)
            return
        }

        let act = UIActivityIndicatorView()
        addSubview(act)
        act.color = UIColor.gray
        act.startAnimating()
        act.snp.makeConstraints { (m) in
            m.center.equalTo(self)
            m.width.height.equalTo(20)
        }
        
        if url!.hasPrefix("http"){
            let res = KF.ImageResource(downloadURL: URL(string: url!)!)
            var place:UIImage? = nil
            if let p = placeHolder{
                place = UIImage(named: p)
            }
            
            kf.setImage(with: res, placeholder:place, options: [.transition(.fade(1))], progressBlock: nil) { (res) in
                act.stopAnimating()
                act.removeFromSuperview()
                switch res{
                case .success(let img):
                    completed?(img.image)
                case .failure( _):
                    self.image = UIImage(named: errorHolder)
                }
            }
        }
        else{
            image = UIImage(named: url!)
        }
    }

    
  
    
}

extension UIImageView{
    func addMask(img:UIImage?)  {
        for sub in self.subviews{
            if sub.tag == -100{
                return
            }
        }
        let imgMask = UIImageView(image: img)
        imgMask.tag = -100
        addSubview(imgMask)
        imgMask.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }
    
    func addMask(color:UIColor)  {
        for sub in self.subviews{
            if sub.tag == -100{
                return
            }
        }
        let vMask = UIView().bgColor(color: color)
        vMask.tag = -100
        addSubview(vMask)
        vMask.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }
    
    func removeMask() {
        for sub in self.subviews{
            if sub.tag == -100{
                sub.removeFromSuperview()
            }
        }
    }
}
