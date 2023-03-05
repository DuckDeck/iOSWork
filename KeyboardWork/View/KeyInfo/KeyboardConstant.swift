//
//  KeyboardConstant.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/17.
//

import Foundation


var ReInputKey:KeyInfo{
    var k = KeyInfo()
    let type = keyboardVC?.textDocumentProxy.returnKeyType ?? .default
    if  globalHeader?.isHavePinYin ?? false || type == .search || type == .go {
        k.text = "重输"
        k.keyType = .reInput
    } else {
        k.text = "换行"
        k.keyType = .newLine
    }
    k.fillColor = cKeyBgColor2
    k.textColor = cKeyTextColor
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
