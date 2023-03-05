//
//  Global.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import UIKit
  



let kSCREEN_WIDTH = UIScreen.main.bounds.size.width
let kSCREEN_HEIGHT = UIScreen.main.bounds.size.height

var keyboardVC : KeyboardViewController?
var globalHeader: HeaderView?
var globalKeyboard : KeyboardView?
var globalKeybaordStatus = KeyboardStatus.inActive
var globalKeyboardHeight = KeyboardHeight.normal
extension UITextDocumentProxy {
    var returnText : String {
        guard let _type = returnKeyType else { return "完成" }
        var returnStr = "发送"
        switch _type {
        case .go:
            returnStr = "前往"
        case .google:
            returnStr = "Google"
        case .join:
            returnStr = "加入"
        case .next:
            returnStr = "下一步"
        case .route:
            returnStr = "Route"
        case .search:
            returnStr = "搜索"
        case .send:
            returnStr = "发送"
        case .yahoo:
            returnStr = "Yahoo"
        case .done:
            returnStr = "完成"
        case .emergencyCall:
            returnStr = "EmergencyCall"
        case .continue:
            returnStr = "继续"
        default:break
        }
        return returnStr
    }
    
    func isNumberType() -> Bool {
        var res = false
        if let type = self.keyboardType {
            if type == .numberPad || type == .numbersAndPunctuation || type == .namePhonePad {
                res = true
            }
        }
        return res
    }
    
    func clearText() {
        if let length = self.documentContextBeforeInput?.count{
            for _ in 0..<length {
                deleteBackward()
            }
        }
        if let length = documentContextAfterInput?.count {
            for _ in stride(from: length, to: 0, by: -1) {
                deleteBackward()
            }
        }
    }
}



let kSepScreenWidth : CGFloat  = 391            //区别屏幕宽度的分界大小，


var globalCache = [String:String]()                    //临时保存的值，键盘后台被杀会重置


let Toast = Hud(frame: CGRect.zero)

