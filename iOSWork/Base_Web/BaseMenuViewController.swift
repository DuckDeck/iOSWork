//
//  BaseMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation
class BaseMenuViewController:BaseViewController{
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        navigationController?.hidesBottomBarWhenPushed = true
    }
}
