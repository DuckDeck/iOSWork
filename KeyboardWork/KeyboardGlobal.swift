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

enum KeyboardHeight: CGFloat {
    case normal = 50.0, big = 200
    var value: CGFloat {
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            return 380
        case .PhoneHor,.PhoneVer:
            return self.boardHeight + self.rawValue
        }
    }
    
    var headerHeight:CGFloat{
        if UIDevice.current.deviceDirection == .PhoneHor{
            return 42
        } else {
            return 50
        }
    }
    
    var boardHeight:CGFloat{
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor:
            return 318
        case .PhoneHor:
            return (UIScreen.main.bounds.width < 400 ? 180 : 200)
        case .PhoneVer:
            return (UIScreen.main.bounds.width < 400 ? 203 : 223)
        }
    }
}


var ReturnKey:KeyInfo{
        var k = KeyInfo()
        
        let type = keyboardVC?.textDocumentProxy.returnText ?? ""
        k.text = type
        let str = keyboardVC?.currentText ?? ""
        if type == "换行"{
            k.isEnable = true
        } else{
            k.isEnable = !str.isEmpty
        }
        if k.isEnable{
            k.fillColor = UIColor.orange
            if !k.text.isEmpty{
                k.textColor = UIColor.white
                k.textSize = 18
            }
            k.keyType = .returnKey(.usable)
        } else {
            k.fillColor = UIColor("b3b7bc")
            if !k.text.isEmpty{
                k.textColor = Colors.color888888
                k.textSize = 18
            }
            if !k.image.isEmpty{
                k.image = "icon_keyboard_enter_gray"
            }
            k.keyType = .returnKey(.disable)
        }
        
        return k
}


let FullLeftCharacher = Set<String>.init(arrayLiteral: "，","。","；","：","》","？","！","、","）","】")
let FullRightCharacher = Set<String>.init(arrayLiteral: "（","【","《")
extension String{
    var characherOffset:CGFloat{
        if FullLeftCharacher.contains(self){
            return 5
        } else if FullRightCharacher.contains(self){
            return -5
        }
        return 0
    }
}



let Toast = Hud(frame: CGRect.zero)
