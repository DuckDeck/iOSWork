//
//  DynamicMitoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandKit
class DynamicMitoViewController: UIViewController {

 
  
    
    var grandMenu:GrandMenu?
    var grandMenuTable:GrandMenuTable?
    
    let arrMenu = ["全部","娱乐明星","网络红人","歌曲舞蹈","影视大全","动漫卡通","游戏天地","动物萌宠","风景名胜","天生尤物","其他视频"]

    
    var currentDisplayTaskPageIndex = 0
    var arrControllers = [MitoListViewController]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        for item in arrMenu{
            let vc = MitoListViewController()
            vc.cat = item
            vc.imgType = 1
            arrControllers.append(vc)
        }
        
        grandMenu = GrandMenu(frame: CGRect(x: 0, y: 0, w: 300, h: 40), titles: arrMenu)
        grandMenu?.backgroundColor = UIColor.clear
        grandMenu?.selectMenu = {[weak self] (item:GrandMenuItem, index:Int) in
            self?.grandMenuTable?.contentViewCurrentIndex = index
        }
        grandMenu?.itemColor = UIColor.black
        grandMenu?.itemSeletedColor = UIColor.blue
        grandMenu?.itemFont = 16
        grandMenu?.itemSelectedFont = 17
        grandMenu?.averageManu = false
        grandMenu?.sliderColor = UIColor.blue
        grandMenu?.sliderBarLeftRightOffset = 8
        grandMenu?.sliderBarHeight = 2
        navigationItem.titleView = grandMenu
        
        grandMenuTable = GrandMenuTable(frame: CGRect(x: 0, y: UIDevice.topAreaHeight, width: ScreenWidth, height: ScreenHeight - UIDevice.topAreaHeight), childViewControllers: arrControllers, parentViewController: self)
        grandMenuTable?.scrollToIndex = {[weak self](index:Int)in
            self?.grandMenu?.selectSlideBarItemAtIndex(index)
            self?.currentDisplayTaskPageIndex = index
            
        }
        view.addSubview(grandMenuTable!)
        
        
    }
    

    

}
