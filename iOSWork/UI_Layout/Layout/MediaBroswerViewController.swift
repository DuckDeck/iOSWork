//
//  MediaBroswerViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/29.
//

import Foundation
class MediaBroswerViewController: UIViewController {
    
    var arrMedia:[MediaModel]{
        get{
            var arrMedia = [MediaModel]()
            var m = MediaModel()
            m.type = .Image
            m.url = "https://pic.netbian.com/uploads/allimg/211127/001033-16379430335612.jpg"
            arrMedia.append(m)
             m = MediaModel()
            m.type = .Image
            m.url = "https://pic.netbian.com/uploads/allimg/211124/003353-1637685233484f.jpg"
            arrMedia.append(m)
             m = MediaModel()
            m.type = .Image
            m.url = "https://pic.netbian.com/uploads/allimg/211125/002326-163777100602af.jpg"
            arrMedia.append(m)
            return arrMedia
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView(){
        let viewBroswer = MediaBroswerView(frame: UIScreen.main.bounds)
        viewBroswer.mediaModel = arrMedia
        view.addSubview(viewBroswer)
    }
}
