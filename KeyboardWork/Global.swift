//
//  Global.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import UIKit
  
let kColor222222 = UIColor(hexString: "222222")!
let kColorb3b7bC = UIColor(hexString: "b3b7bC")!
let kColor0a0a0a = UIColor(hexString: "0a0a0a")!
let kColor3a9a52 = UIColor(hexString: "3a9a52")!
let kColora6a6a6 = UIColor(hexString: "a6a6a6")!
let kColor898a8d = UIColor(hexString: "898a8d")!
let kColord1d5db = UIColor(hexString: "d1d5db")!
let kColor888888 = UIColor(hexString: "888888")!
let kColorbbbbbb = UIColor(hexString: "bbbbbb")!
let kCOlora9abb0 = UIColor(hexString: "a9abb0")!


let kSCREEN_WIDTH = UIScreen.main.bounds.size.width


var keyboardVC : KeyboardViewController?
var globalKeyboard : KeyboardView?


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


var returnKey:KeyInfo{
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
            k.fillColor = kColorb3b7bC
            if !k.text.isEmpty{
                k.textColor = kColor888888
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

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint.init(x: self.origin.x + self.size.width/2, y: self.origin.y + self.size.height/2)
        }
    }
    
    func centerRect(w:CGFloat,h:CGFloat)->CGRect{
        if w >= self.width || h >= self.height{
            return self
        }
        return CGRect(x: center.x - w / 2, y: center.y - h / 2, width: w, height: h)
    }
    
    func large(w:CGFloat,h:CGFloat) -> CGRect{
        return CGRect(x: origin.x - w, y: origin.y - h, width: size.width + w, height: size.height + h)
    }
    func large() -> CGRect{
        if self.minX > 20 && self.minX < 25{
            return CGRect(x: origin.x - 15, y: origin.y - 5, width: size.width + 17, height: size.height + 10)
        } else if self.maxX > UIScreen.main.bounds.width - 25 && self.maxX < UIScreen.main.bounds.width - 20{
            return CGRect(x: origin.x - 2, y: origin.y - 5, width: size.width + 17, height: size.height + 10)
        }
        return CGRect(x: origin.x - 2, y: origin.y - 5, width: size.width + 4, height: size.height + 10)
    }
}
