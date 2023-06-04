//
//  KeyboardManage.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/6/4.
//

import Foundation
class KeyboardManage:NSObject{
    
   
    @objc static let shared = KeyboardManage()
    
    @objc static var isWGKeyboardEnable:Bool{
        guard let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] else {
            return false
        }
        return keyboards.contains("ShadowEdge.iOSWorking.KeyboardWork")
    }
    
    @objc static var isUseWGKeyboard:Bool{
        let  type = UIApplication.shared.textInputMode?.value(forKey: "identifierWithLayouts") as? String ?? ""
        print("==========================当前键盘是\(type)==========================")
        //目前这个API不准。参考 https://stackoverflow.com/questions/26153336/how-do-i-find-out-the-current-keyboard-used-on-ios8
        return type == "ShadowEdge.iOSWorking.KeyboardWork"
    }
    
}
