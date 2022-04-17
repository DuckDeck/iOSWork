//
//  FullKeyboardView+KeyInfo.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

extension FullKeyboardView{
    
    
  
    
    func setChinese26Data(){
        let f = [("Q","1"),("W","2"),("E","3"),("R","4"),("T","5"),("Y","6"),("U","7"),("I","8"),("O","9"),("P","0")]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44)
            k.keyType = .normal(.chinese)
            firstKeys.append(k)
        }
        
        let s = [("A","~"),("S","！"),("D","@"),("F","#"),("G","%"),("H","“"),("J","”"),("K","*"),("L","？")]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset + 10)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 23.5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.chinese)
            secondKeys.append(k)
        }
        
        let t = [("Z","（"),("X","）"),("C","-"),("V","_"),("B","："),("N","；"),("M","/")]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var sep = KeyInfo()
        sep.text = "分词"
        sep.keyType = .separate
        sep.fillColor = kColorb3b7bC
        sep.textColor = kColor0a0a0a
        sep.textSize = 18
        sep.position = CGRect(x: 5, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset + 20)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + sep.position.maxX + 12, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.chinese)
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        forthKeys.removeAll()
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.textSize = 18
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.keyType = .switchKeyboard(.symbleChiese)
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.textSize = 18
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
        var commaKey = KeyInfo()
        commaKey.text = "，"
        commaKey.tip = "。"
        commaKey.fillColor = UIColor.white
        commaKey.textColor = kColor222222
        commaKey.keyType = .normal(.character)
        commaKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 32 * xScale, height: 44)
        forthKeys.append(commaKey)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: commaKey.position.maxX + 5, y: 5, width: 79 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_chinese"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.english)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }

    func setEnglish26Data(shiftType:KeyShiftType = .normal){
        let f = [("q","1"),("w","2"),("e","3"),("r","4"),("t","5"),("y","6"),("u","7"),("i","8"),("o","9"),("p","0")]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44)
            k.keyType = .normal(.character)
            firstKeys.append(k)
        }
        
        let s = [("a","~"),("s","!"),("d","@"),("f","#"),("g","%"),("h","'"),("j","&"),("k","*"),("l","?")]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset + 10)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 23.5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            secondKeys.append(k)
        }
        
        let t = [("z","("),("x",")"),("c","-"),("v","_"),("b",":"),("n",";"),("m","/")]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var shiftKey = KeyInfo()
        switch shiftType {
        case .normal:
            shiftKey.image = "icon_keyboard_shift_off"
            shiftKey.keyType = .shift(.shift)
        case .shift:
            shiftKey.image = "icon_keyboard_shift_on"
            shiftKey.keyType = .shift(.lock)
        case .lock:
            shiftKey.image = "icon_keyboard_shift_lock"
            shiftKey.keyType = .shift(.normal)
        }
        
        shiftKey.fillColor = kColorb3b7bC
        shiftKey.textColor = kColor0a0a0a
        shiftKey.position = CGRect(x: 5, y: 5, width: xScale * 42, height: 44)
        thirdKeys.append(shiftKey)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.id = UInt8(item.offset + 20)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + shiftKey.position.maxX + 13.5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        forthKeys.removeAll()
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.textSize = 18
        symKey.keyType = .switchKeyboard(.symbleEnglish)
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.textSize = 18
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
        var commaKey = KeyInfo()
        commaKey.text = ","
        commaKey.tip = "."
        commaKey.fillColor = UIColor.white
        commaKey.textColor = kColor222222
        commaKey.keyType = .normal(.character)
        commaKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 32 * xScale, height: 44)
        forthKeys.append(commaKey)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: commaKey.position.maxX + 5, y: 5, width: 79 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_english"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.chinese)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }
    
    func setChineseSymbleData(){
        let f = ["1","2","3","4","5","6","7","8","9","0"]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            firstKeys.append(k)
        }
        
        let s = ["-","/","：","；","（","）","￥","@","“","”"]
        let needBackKeys1 = [0,1,2,6]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            if !needBackKeys1.contains(item.offset){
                k.canBack = true
            }
            secondKeys.append(k)
        }
        
        let t = ["。","，","、","？","！","."]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.textSize = 18
        sep.keyType = .switchKeyboard(.symbleChieseMore)
        sep.fillColor = kColorb3b7bC
        sep.textColor = kColor0a0a0a
        sep.position = CGRect(x: 5, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (39 * xScale + 4) + sep.position.maxX + 12, y: 5, width: 39 * xScale, height: 44 )
            k.popViewImage = "icon_keyboard_pop_center_big"
            k.keyType = .normal(.character)
            if item.offset != 5{
                k.canBack = true
            }
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        
        forthKeys.removeAll()
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textSize = 18
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 52 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.textSize = 18
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
     
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 102 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_chinese"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.symbleEnglish)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }


    func setEnglishSymbleData(){
        let f = ["1","2","3","4","5","6","7","8","9","0"]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            firstKeys.append(k)
        }
        
        let s = ["-","/",":",";","(",")","$","&","@","\""]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            if item.offset > 2{
                k.canBack = true
            }
            secondKeys.append(k)
        }
        
        let t = [".",",","?","!","`"]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.keyType = .switchKeyboard(.symbleEnglishMore)
        sep.fillColor = kColorb3b7bC
        sep.textColor = kColor0a0a0a
        sep.textSize = 18
        sep.position = CGRect(x: 5, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (47.6 * xScale + 4) + sep.position.maxX + 12, y: 5, width: 47.6 * xScale, height: 44 )
            k.popViewImage = "icon_keyboard_pop_center_bigger"
            k.keyType = .normal(.character)
            if item.offset > 0{
                k.canBack = true
            }
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        forthKeys.removeAll()
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textSize = 18
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 52 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.textSize = 18
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
     
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 102 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_english"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.symbleChiese)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }


    func setChineseSymbleMoreData(){
        let f = ["【","】","{","}","#","%","^","*","+","="]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            k.canBack = true
            firstKeys.append(k)
        }
        
        let s = ["_","-","\\","|","~","《","》","$","&","•"]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            if item.offset != 1 && item.offset != 4{
                k.canBack = true
            }
            secondKeys.append(k)
        }
        
        let t = ["...","，","。","？","！","'"]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var sep = KeyInfo()
        sep.text = "符"
        sep.keyType = .switchKeyboard(.symbleChiese)
        sep.fillColor = kColorb3b7bC
        sep.textColor = kColor0a0a0a
        sep.textSize = 18
        sep.position = CGRect(x: 5, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (39 * xScale + 4) + sep.position.maxX + 12, y: 5, width: 39 * xScale, height: 44 )
            k.popViewImage = "icon_keyboard_pop_center_big"
            k.keyType = .normal(.character)
            if item.offset != 0{
                k.canBack  = true
            }
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        
        forthKeys.removeAll()
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textSize = 18
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 52 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.textSize = 18
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 102 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_chinese"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.symbleEnglishMore)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }

    func setEnglishSybmbleMoreData(){
        let f = ["[","]","{","}","#","%","^","*","+","="]
        let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
        let keyWidth = xScale * 32
        if firstKeys == nil{
            firstKeys = [KeyInfo]()
        }
        firstKeys.removeAll()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            k.canBack = true
            firstKeys.append(k)
        }
        
        let s = ["_","\\","|","~","<",">","€","£","¥","・"]
        if secondKeys == nil{
            secondKeys = [KeyInfo]()
        }
        secondKeys.removeAll()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + 5) + 5, y: 5, width: keyWidth, height: 44 )
            k.keyType = .normal(.character)
            k.canBack = true
            secondKeys.append(k)
        }
        
        let t = [".",",","?","!","`"]
        if thirdKeys == nil{
            thirdKeys = [KeyInfo]()
        }
        thirdKeys.removeAll()
        var sep = KeyInfo()
        sep.text = "符"
        sep.textSize = 18
        sep.keyType = .switchKeyboard(.symbleEnglish)
        sep.fillColor = kColorb3b7bC
        sep.textColor = kColor0a0a0a
        sep.position = CGRect(x: 5, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = UIColor.white
            k.textColor = kColor222222
            k.position = CGRect(x: CGFloat(item.offset) * (47.6 * xScale + 4) + sep.position.maxX + 12, y: 5, width: 47.6 * xScale, height: 44 )
            k.popViewImage = "icon_keyboard_pop_center_bigger"
            k.keyType = .normal(.character)
            k.canBack = true
            thirdKeys.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_delete_white"
        del.keyType = .del
        del.fillColor = kColorb3b7bC
        del.position = CGRect(x: thirdKeys.last!.position.maxX + 11, y: 5, width: xScale * 44, height: 44)
        thirdKeys.append(del)
        
        if forthKeys == nil{
            forthKeys = [KeyInfo]()
        }
        forthKeys.removeAll()
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_keyboard_emoji"
        emojiKey.fillColor = kColorb3b7bC
        emojiKey.position = CGRect(x: 5, y: 5, width: 38 * xScale, height: 44)
        emojiKey.keyType = .switchKeyboard(.emoji)
        forthKeys.append(emojiKey)
        
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textSize = 18
        symKey.fillColor = kColorb3b7bC
        symKey.textColor = kColor0a0a0a
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: emojiKey.position.maxX + 5, y: 5, width: 52 * xScale, height: 44)
        forthKeys.append(symKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.textSize = 18
        numKey.fillColor = kColorb3b7bC
        numKey.textColor = kColor0a0a0a
        numKey.keyType = .switchKeyboard(.number)
        numKey.position = CGRect(x: symKey.position.maxX + 5, y: 5, width: 38 * xScale, height: 44)
        forthKeys.append(numKey)
        
     
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: numKey.position.maxX + 5, y: 5, width: 102 * xScale, height: 44)
        spaceKey.keyType = .space
        forthKeys.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_english"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 5, y: 5, width: 42 * xScale, height: 44)
        switchKey.keyType = .switchKeyboard(.symbleChieseMore)
        forthKeys.append(switchKey)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 5, y: 5, width: 68 * xScale, height: 44)
        forthKeys.append(enterKey)
    }
}
