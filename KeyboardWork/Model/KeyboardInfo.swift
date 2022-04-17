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
    /// 自动发送
    var manualSend = true
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
    static var ManualSend : Bool{
        get{return KeyboardInfo.keyboardInfo.Value.manualSend}
        set{var tmp = KeyboardInfo.keyboardInfo.Value;tmp.manualSend = newValue;KeyboardInfo.keyboardInfo.Value = tmp}
    }
}
