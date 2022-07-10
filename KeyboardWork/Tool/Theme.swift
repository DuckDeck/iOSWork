//
//  Theme.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/10.
//

import Foundation
enum Theme:String{
    case keyboardBgColor = "keyboard_bg_color"
    var color:UIColor{
        return UIColor(named: self.rawValue)!
    }
}
