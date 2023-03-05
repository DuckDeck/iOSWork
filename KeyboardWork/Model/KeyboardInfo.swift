//
//  KeyboardInfo.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

struct KeyboardInfo:Codable{
    var keyboardType:KeyboardType = .chinese26
    /// 模糊音
    var fuzzyInput = false
    /// 纠错
    var correctInput = true
    
    var shake = false
    private static let keyboardHorHeight = "keyboardHorHeight"    //键盘横屏高度
    private static let keyboardVerHeight = "keyboardHorHeight"    //键盘竖屏高度

    static let keyboardInfo = Store(name: "keyboardInfo", defaultValue: KeyboardInfo(),isUseKeyboardStore: true)
    
    static var KeyboardType : KeyboardType{
        get{return KeyboardInfo.keyboardInfo.Value.keyboardType}
        set{var tmp = KeyboardInfo.keyboardInfo.Value;tmp.keyboardType = newValue;KeyboardInfo.keyboardInfo.Value = tmp}
    }
    static var FuzzyInput : Bool{
        get{return KeyboardInfo.keyboardInfo.Value.fuzzyInput}
        set{var tmp = KeyboardInfo.keyboardInfo.Value;tmp.fuzzyInput = newValue;KeyboardInfo.keyboardInfo.Value = tmp}
    }
    static var CorrectInput : Bool{
        get{return KeyboardInfo.keyboardInfo.Value.correctInput}
        set{var tmp = KeyboardInfo.keyboardInfo.Value;tmp.correctInput = newValue;KeyboardInfo.keyboardInfo.Value = tmp}
    }
    static var Shake : Bool{
        get{return KeyboardInfo.keyboardInfo.Value.shake}
        set{var tmp = KeyboardInfo.keyboardInfo.Value;tmp.shake = newValue;KeyboardInfo.keyboardInfo.Value = tmp}
    }
    
    
    static var boardHeight:CGFloat{
        var height = 0
        let tmpDict = Store<[String:String]>.innerValue(key: "KeyboardSetting") ?? [String:String]()
        if UIDevice.current.orientation.isPortrait{
            height = Int(tmpDict[keyboardVerHeight] ?? "") ?? 0
        } else {
            height = Int(tmpDict[keyboardHorHeight] ?? "") ?? 0
        }
        if height == 0{
           return standardBoardHeight
        }
        return  CGFloat(height)
    }
    
    static var standardBoardHeight:CGFloat{
        switch UIDevice.current.deviceDirection{
        case .PadVer:
            return 264
        case .PadHor:
            return 352
        case .PhoneHor:
            return 161
        case .PhoneVer:
            if UIScreen.main.bounds.width < kSepScreenWidth{
                return 216
            } else {
                return 226 
            }
        }
    }
    
}

var KBScale: CGFloat {
    return kSCREEN_WIDTH / 375.0
//    if UIDevice.isIpad {
//        return s * 1.2
//    } else {
//        if orientation == .horizontal {
//            return s * 0.8
//        }
//        return s
//    }
}
