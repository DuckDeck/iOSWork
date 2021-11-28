//
//  ProcessVideoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/28.
//

import Foundation
class ProcessVideoViewController: UIViewController {
    let imgView = UIImageView()
    let imgViewOrigin = UIImageView()
    let path = Bundle.main.path(forResource: "cxk", ofType: "mp4")!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
       imgViewOrigin.contentMode = .scaleAspectFit
       imgViewOrigin.addTo(view: view).snp.makeConstraints { (m) in
         m.left.right.equalTo(0)
          m.top.equalTo(0)
          m.height.equalTo(ScreenHeight / 2 - 50)
      }
        imgView.contentMode = .scaleAspectFit
        imgView.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(imgViewOrigin.snp.bottom).offset(10)
            m.height.equalTo(ScreenHeight / 2-100)
       }
       
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(setPreviewImage), userInfo: nil, repeats: true)

    }
    
    @objc func setPreviewImage()  {
        guard let images = OpenCV.getVideoImage(path) as? [UIImage] else{
            return
        }
        
        if images.count <= 0 {
            return
        }
        imgViewOrigin.image = images[0]
          imgView.image = images[1]
    }
   
}
