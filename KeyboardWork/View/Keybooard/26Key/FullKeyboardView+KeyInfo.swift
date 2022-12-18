//
//  FullKeyboardView+KeyInfo.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

extension FullKeyboardView{
    
    func setChinese26Data(){
        let f = [("q","1"),("w","2"),("e","3"),("r","4"),("t","5"),("y","6"),("u","7"),("i","8"),("o","9"),("p","0")]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset)
            k.showTip = false
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.chinese)
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = [("a","~"),("s","！"),("d","@"),("f","#"),("g","%"),("h","“"),("j","”"),("k","*"),("l","？")]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 10)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent2, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.chinese)
            k.showTip = UIDevice.current.orientation.rawValue <= 2
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [("z","（"),("x","）"),("c","-"),("v","_"),("b","："),("n","；"),("m","/")]
        let letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
        var row4 = [KeyInfo]()
        var shiftKey = KeyInfo()
        shiftKey.fillColor = cKeyBgColor2
        shiftKey.image = "icon_key_shift_off"
        shiftKey.keyType = .shift(.shift)
        shiftKey.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        shiftKey.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(shiftKey)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 20)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + letterStart, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.chinese)
            if item.offset == 0{
                k.hotArea = k.position.large(left: 10, top: 5, right: 2.5, bottom: 5)
            } else if item.offset == t.count - 1{
                k.hotArea = k.position.large(left: 5, top: 5, right: 10, bottom: 5)
            }
            k.showTip = UIDevice.current.orientation.rawValue <= 2
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyWidthShift - keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        
        let xScale = (kSCREEN_WIDTH - 33) / 342
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            widths = [42 * xScale,41 * xScale,32 * xScale,116 * xScale,43 * xScale,68 * xScale]
        case .PhoneHor:
            widths = [keyWidthShift,keyWidthShift,keyWidth,4 * keyWidth + 3 * keyHorGap,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            if UIDevice.isNotch{
                widths = [42 * xScale,42 * xScale,32 * xScale,116 * xScale,42 * xScale,68 * xScale]
            } else{
                widths = [42 * xScale,42 * xScale,42 * xScale,106 * xScale,42 * xScale,68 * xScale]
            }
        }
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.fontSize = 18
        symKey.fillColor = cKeyBgColor2
        symKey.textColor = cKeyTextColor
        symKey.keyType = .switchKeyboard(.symbleChiese)
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        var sKey:KeyInfo!
        if UIDevice.isNotch{
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(numKey)
            
            var commaKey = KeyInfo()
            commaKey.text = "，"
            commaKey.tip = "。"
            commaKey.fillColor = cKeyBgColor
            commaKey.textColor = cKeyTextColor
            commaKey.keyType = .normal(.character)
            commaKey.fontSize = 20
            commaKey.tipSize = 14
            commaKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(commaKey)
            sKey =  commaKey
        } else {
            var switchKey = KeyInfo()
//            switchKey.image = "icon_key_switch"
//            switchKey.fillColor = cKeyBgColor2
//            switchKey.keyType = .special("切换键盘")
            switchKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(switchKey)
            
            
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(numKey)
            sKey = numKey
        }
        
       
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: sKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_ch_en_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.english)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[5], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }

    func setEnglish26Data(shiftType:KeyShiftType = .normal){
        let f = [("q","1"),("w","2"),("e","3"),("r","4"),("t","5"),("y","6"),("u","7"),("i","8"),("o","9"),("p","0")]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset)
            k.showTip = false
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        
        let s = [("a","~"),("s","!"),("d","@"),("f","#"),("g","%"),("h","'"),("j","&"),("k","*"),("l","?")]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 10)
            if shiftType != .normal{                //大写移除符号
                k.showTip = false
            }
            k.showTip = UIDevice.current.orientation.rawValue <= 2
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent2, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [("z","("),("x",")"),("c","-"),("v","_"),("b",":"),("n",";"),("m","/")]
        let letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
        var row4 = [KeyInfo]()
        var shiftKey = KeyInfo()
        shiftKey.fillColor = cKeyBgColor2
        switch shiftType {
        case .normal:
            shiftKey.image = "icon_key_shift_off"
            shiftKey.keyType = .shift(.shift)
        case .shift:
            shiftKey.image = "icon_key_shift_on"
            shiftKey.keyType = .shift(.normal)
            if #available(iOSApplicationExtension 12.0, *) {
                shiftKey.fillColor = cKeyShiftOnColor
            }
        case .lock:
            shiftKey.image = "icon_key_shift_lock"
            shiftKey.keyType = .shift(.normal)
            if #available(iOSApplicationExtension 12.0, *) {
                shiftKey.fillColor = cKeyShiftOnColor
            }
        }
        shiftKey.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        shiftKey.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(shiftKey)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = shiftType == .normal ? item.element.0 : item.element.0.uppercased()
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 20)
            if shiftType != .normal{            //大写移除符号
                k.showTip = false
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + letterStart, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            k.showTip = UIDevice.current.orientation.rawValue <= 2
            if item.offset == 0{
                k.hotArea = k.position.large(left: 10, top: 5, right: 2.5, bottom: 5)
            } else if item.offset == t.count - 1{
                k.hotArea = k.position.large(left: 5, top: 5, right: 10, bottom: 5)
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyIndent1 - keyWidthShift, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        
        var row5 = [KeyInfo]()
        let xScale = (kSCREEN_WIDTH - 33) / 342
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            widths = [42 * xScale,41 * xScale,32 * xScale,116 * xScale,43 * xScale,68 * xScale]
        case .PhoneHor:
            widths = [keyWidthShift,keyWidthShift,keyWidth,4 * keyWidth + 3 * keyHorGap,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            if UIDevice.isNotch{
                widths = [42 * xScale,42 * xScale,32 * xScale,116 * xScale,42 * xScale,68 * xScale]
            } else{
                widths = [42 * xScale,42 * xScale,42 * xScale,106 * xScale,42 * xScale,68 * xScale]
            }
        }
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.fillColor = cKeyBgColor2
        symKey.textColor = cKeyTextColor
        symKey.fontSize = 18
        symKey.keyType = .switchKeyboard(.symbleEnglish)
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var sKey:KeyInfo!
        if UIDevice.isNotch{
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(numKey)
            
            var commaKey = KeyInfo()
            commaKey.text = ","
            commaKey.tip = "."
            commaKey.fillColor = cKeyBgColor
            commaKey.textColor = cKeyTextColor
            commaKey.fontSize = 20
            commaKey.tipSize = 14
            commaKey.keyType = .normal(.character)
            commaKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(commaKey)
            sKey =  commaKey
        } else {
            var switchKey = KeyInfo()
            switchKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(switchKey)
            
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(numKey)
            sKey = numKey
        }
                
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: sKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_en_ch_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.chinese)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[5], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }
    
    func setChineseSymbleData(){
        let f = ["1","2","3","4","5","6","7","8","9","0"]
        let fs = ["1一壹１①⑴⒈❶㊀㈠","贰2二２②⑵⒉❷㊁㈡","③叁3三３⑶⒊❸㊂㈢","⒋④肆4四４⑷❹㊃㈣","㊄⒌⑤伍5五５⑸❺㈤","㈥㊅⒍⑥陆6六６⑹❻","㈦㊆❼⒎⑦柒7七７⑺","㈧㊇❽⒏⑻⑧捌8八８","㈨㊈❾⒐⑼⑨９玖9九","°⓪零０0"]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.tips = Array(fs[item.offset]).map({ c in
                return SymbleInfo(text: String(c), angle: nil)
            })
            if item.offset < 9{
                k.defaultSymbleIndex = item.offset
            } else {
                k.defaultSymbleIndex = 4
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = ["-","/","：","；","（","）","￥","@","“","”"]
        let ss = [[SymbleInfo(text: "-", angle: nil),SymbleInfo(text: "－", angle: .fullAngle),SymbleInfo(text: "–", angle: nil),SymbleInfo(text: "–", angle: nil), SymbleInfo(text: "•", angle: nil)],
                  [SymbleInfo(text: "/", angle: nil),SymbleInfo(text: "/", angle: .fullAngle),SymbleInfo(text: "\\", angle: nil)],
                  [SymbleInfo(text: "：", angle: nil),SymbleInfo(text: ":", angle: .halfAngle)],
                  [SymbleInfo(text: "；", angle: nil),SymbleInfo(text: ";", angle: .halfAngle)],
                  [SymbleInfo(text: "（", angle: nil),SymbleInfo(text: "(", angle: .halfAngle)],
                  [SymbleInfo(text: ")", angle: .halfAngle),SymbleInfo(text: "）", angle: nil)],
                  [SymbleInfo(text: "＄", angle: nil),SymbleInfo(text: "$", angle: nil),SymbleInfo(text: "₽", angle: nil),SymbleInfo(text: "₩", angle: nil),SymbleInfo(text: "€", angle: nil),SymbleInfo(text: "¥", angle: nil),SymbleInfo(text: "￥", angle: .fullAngle),SymbleInfo(text: "£", angle: nil)],
                  [SymbleInfo(text: "@", angle: .halfAngle),SymbleInfo(text: "＠", angle: nil)],
                  [SymbleInfo(text: "『", angle: nil),SymbleInfo(text: "「", angle: nil),SymbleInfo(text: "＂", angle: nil),SymbleInfo(text: "\"", angle: nil),SymbleInfo(text: "“", angle: nil)],
                  [SymbleInfo(text: "』", angle: .halfAngle),SymbleInfo(text: "」", angle: nil),SymbleInfo(text: "＂", angle: nil),SymbleInfo(text: "\"", angle: nil),SymbleInfo(text: "”", angle: nil)]]
        let needBackKeys1 = [0,1,2,6]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.tips = ss[item.offset]
            if item.offset < 5 || item.offset == 7{
                k.defaultSymbleIndex = 0
            }
            else if item.offset == 6{
                k.defaultSymbleIndex = 6
            } else {
                k.defaultSymbleIndex = ss[item.offset].count - 1
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            if !needBackKeys1.contains(item.offset){
                k.canBack = true
            }
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = ["。","，","、","？","！","."]
        let ts = [[SymbleInfo(text: "。", angle: nil),SymbleInfo(text: "……", angle: nil),SymbleInfo(text: "…", angle: nil)],
                  [SymbleInfo(text: ",", angle: .halfAngle),SymbleInfo(text: "，", angle: nil)],[],
                  [SymbleInfo(text: "？", angle: nil),SymbleInfo(text: "?", angle: .halfAngle)],
                  [SymbleInfo(text: "!", angle: .halfAngle),SymbleInfo(text: "！", angle: nil)],
                  [SymbleInfo(text: "…", angle: nil),SymbleInfo(text: "．", angle: .fullAngle),SymbleInfo(text: ".", angle: nil)]]
        let tsIndex = [0,1,-1,0,1,2]
        var keyWidth1 : CGFloat = 0
        var letterStart : CGFloat = 0
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        case .PhoneHor:
            letterStart = row3[2].position.minX
            keyWidth1 =  keyWidth
        case .PhoneVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        }
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.fontSize = 18
        sep.keyType = .switchKeyboard(.symbleChieseMore)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !ts[item.offset].isEmpty{
                k.tips = ts[item.offset]
                k.defaultSymbleIndex = tsIndex[item.offset]
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap) + letterStart, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset != 5{
                k.canBack = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyIndent1 - keyWidthShift, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea =  CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
       
        var row5 = [KeyInfo]()
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor,.PhoneHor:
            widths = [keyWidthShift,keyWidthShift,kSCREEN_WIDTH - 4 * (keyHorGap + keyWidthShift) - 2 * keyIndent1,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            let xScale = (kSCREEN_WIDTH - 28) / 347
            widths = [61 * xScale,59 * xScale,116 * xScale,43 * xScale,68 * xScale]
        }
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.fontSize = 18
        symKey.fillColor = UIColor.yellow
        symKey.textColor = UIColor.white
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_key_emoji"
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
     
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_ch_en_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleEnglish)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y:keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
        
        
    }

    func setEnglishSymbleData(){
        let f = ["1","2","3","4","5","6","7","8","9","0"]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = ["-","/",":",";","(",")","$","&","@","\""]
        let ss = ["-–—•","/\\","","","","","¢₽₩¥£€$","&§","","«»„“”\""]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !ss[item.offset].isEmpty{
                k.tips = Array(ss[item.offset]).map({ c in
                    return SymbleInfo(text: String(c), angle: nil)
                })
            }
            if item.offset == 9 || item.offset == 6{
                k.defaultSymbleIndex = ss[item.offset].count - 1
            } else {
                k.defaultSymbleIndex = 0
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset > 2{
                k.canBack = true
            }
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [".",",","?","!","`"]
        let ts = [".…","","?¿","!¡","`‘’'"]
        var keyWidth1 : CGFloat = 0
        var letterStart : CGFloat = 0
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        case .PhoneHor:
            letterStart = row3[2].position.minX
            keyWidth1 =  (6 * keyWidth + keyHorGap) * 0.2
        case .PhoneVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - keyHorGap * 4) / 5.0
        }
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.keyType = .switchKeyboard(.symbleEnglishMore)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.fontSize = 18
        sep.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !ts[item.offset].isEmpty{
                k.tips = Array(ts[item.offset]).map({ c in
                    return SymbleInfo(text: String(c), angle: nil)
                })
            }
            if item.offset == 4{
                k.defaultSymbleIndex = 3
            } else{
                k.defaultSymbleIndex = 0
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap) + letterStart, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset > 0{
                k.canBack = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyIndent1 - keyWidthShift, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor,.PhoneHor:
            widths = [keyWidthShift,keyWidthShift,kSCREEN_WIDTH - 4 * (keyHorGap + keyWidthShift) - 2 * keyIndent1,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            let xScale = (kSCREEN_WIDTH - 28) / 347
            widths = [61 * xScale,59 * xScale,116 * xScale,43 * xScale,68 * xScale]
        }
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.fontSize = 18
        symKey.fillColor = UIColor.yellow
        symKey.textColor = UIColor.white
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_key_emoji"
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
     
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_en_ch_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleChiese)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }

    func setChineseSymbleMoreData(){
        let f = ["【","】","{","}","#","%","^","*","+","="]
        let fs = [[SymbleInfo(text: "【", angle: nil),SymbleInfo(text: "［", angle: nil),SymbleInfo(text: "[", angle: nil),SymbleInfo(text: "〔", angle: nil)],
                  [SymbleInfo(text: "】", angle: nil),SymbleInfo(text: "］", angle: nil),SymbleInfo(text: "]", angle: nil),SymbleInfo(text: "〕", angle: nil)],
                  [SymbleInfo(text: "｛", angle: nil),SymbleInfo(text: "{", angle: .halfAngle)],
                  [SymbleInfo(text: "｝", angle: nil),SymbleInfo(text: "}", angle: .halfAngle)],
                  [SymbleInfo(text: "#", angle: nil),SymbleInfo(text: "＃", angle: .fullAngle)],
                  [SymbleInfo(text: "‰", angle: nil),SymbleInfo(text: "％", angle: .fullAngle),SymbleInfo(text: "%", angle: nil)],
                  [SymbleInfo(text: "＾", angle: .fullAngle),SymbleInfo(text: "^", angle: nil)],
                   [SymbleInfo(text: "*", angle: nil),SymbleInfo(text: "＊", angle: .fullAngle)],
                  [SymbleInfo(text: "＋", angle: .fullAngle),SymbleInfo(text: "+", angle: nil)],
                  [SymbleInfo(text: "≈", angle: nil),SymbleInfo(text: "≠", angle: nil),SymbleInfo(text: "＝", angle: .fullAngle),SymbleInfo(text: "=", angle: nil)]]
        let fsIndex = [0,0,0,0,0,2,1,0,1,3]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.tips = fs[item.offset]
            k.defaultSymbleIndex = fsIndex[item.offset]
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = ["_","-","\\","|","~","《","》","$","&","•"]
        let ss = [[SymbleInfo(text: "_", angle: nil),SymbleInfo(text: "＿", angle: .fullAngle)],[],[SymbleInfo(text: "\\", angle: nil),SymbleInfo(text: "＼", angle: .fullAngle)],
                  [SymbleInfo(text: "｜", angle: nil),SymbleInfo(text: "|", angle: .halfAngle)],
                  [SymbleInfo(text: "~", angle: .halfAngle),SymbleInfo(text: "～", angle: nil)],
                  [SymbleInfo(text: "《", angle: nil),SymbleInfo(text: "〈", angle: nil),SymbleInfo(text: "<", angle: nil),SymbleInfo(text: "＜", angle: nil)],
                  [SymbleInfo(text: "＞", angle: nil),SymbleInfo(text: ">", angle: nil),SymbleInfo(text: "〉", angle: nil),SymbleInfo(text: "》", angle: nil)],[],
                  [SymbleInfo(text: "§", angle: nil),SymbleInfo(text: "＆", angle: .fullAngle),SymbleInfo(text: "&", angle: nil)],
                  [SymbleInfo(text: "°", angle: nil),SymbleInfo(text: "•", angle: nil),SymbleInfo(text: "·", angle: nil)]]
        let ssIndex = [0,-1,0,0,1,0,3,-1,2,2]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !ss[item.offset].isEmpty{
                k.tips = ss[item.offset]
                k.defaultSymbleIndex = ssIndex[item.offset]
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset != 1 && item.offset != 4{
                k.canBack = true
            }
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = ["...","，","。","？","！","'"]
        let ts = [[SymbleInfo(text: "⋯", angle: nil),SymbleInfo(text: "…", angle: nil)],
                  [SymbleInfo(text: ",", angle: .halfAngle),SymbleInfo(text: "，", angle: nil)],
                  [SymbleInfo(text: "。", angle: nil),SymbleInfo(text: "……", angle: nil),SymbleInfo(text: "…", angle: nil)],
                  [SymbleInfo(text: "？", angle: nil),SymbleInfo(text: "?", angle: .halfAngle)],
                  [SymbleInfo(text: "!", angle: .halfAngle),SymbleInfo(text: "！", angle: nil)],
                  [SymbleInfo(text: "`", angle: nil),SymbleInfo(text: "’", angle: nil),SymbleInfo(text: "‘", angle: nil),SymbleInfo(text: "＇", angle: .fullAngle),SymbleInfo(text: "'", angle: nil)],]
        let tsIndex = [1,1,-1,0,1,4]
        var keyWidth1 : CGFloat = 0
        var letterStart : CGFloat = 0
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        case .PhoneHor:
            letterStart = row3[2].position.minX
            keyWidth1 =  keyWidth
        case .PhoneVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        }
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "符"
        sep.keyType = .switchKeyboard(.symbleChiese)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.fontSize = 18
        sep.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.tips = ts[item.offset]
            k.defaultSymbleIndex = tsIndex[item.offset]
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap) + letterStart, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset != 0{
                k.canBack  = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyIndent1 - keyWidthShift, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor,.PhoneHor:
            widths = [keyWidthShift,keyWidthShift,kSCREEN_WIDTH - 4 * (keyHorGap + keyWidthShift) - 2 * keyIndent1,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            let xScale = (kSCREEN_WIDTH - 28) / 347
            widths = [61 * xScale,59 * xScale,116 * xScale,43 * xScale,68 * xScale]
        }

        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.fontSize = 18
        symKey.fillColor = UIColor.yellow
        symKey.textColor = UIColor.white
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_key_emoji"
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_ch_en_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleEnglishMore)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }

    func setEnglishSybmbleMoreData(){
        let f = ["[","]","{","}","#","%","^","*","+","="]
        let fs = ["","","","","","%‰","","","","≈≠="]
        var row2 = [KeyInfo()]
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !fs[item.offset].isEmpty{
                k.tips = Array(fs[item.offset]).map({ c in
                    return SymbleInfo(text: String(c), angle: nil)
                })
            }
            if item.offset == 5{
                k.defaultSymbleIndex = 0
            }
            if item.offset == 9{
                k.defaultSymbleIndex = 2
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = ["_","\\","|","~","<",">","€","£","¥","・"]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [".",",","?","!","`"]
        let ts = [".…","","?¿","!¡","`‘’'"]
        var keyWidth1 : CGFloat = 0
        var letterStart : CGFloat = 0
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 25) / 6.0
        case .PhoneHor:
            letterStart = row3[2].position.minX
            keyWidth1 =  (6 * keyWidth + keyHorGap) * 0.2
        case .PhoneVer:
            letterStart = (kSCREEN_WIDTH - keyInnerArea) / 2.0
            keyWidth1 =  (keyInnerArea - 4 * keyHorGap) / 5.0
        }
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "符"
        sep.fontSize = 18
        sep.keyType = .switchKeyboard(.symbleEnglish)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.position = CGRect(x: keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            if !ts[item.offset].isEmpty{
                k.tips = Array(ts[item.offset]).map({ c in
                    return SymbleInfo(text: String(c), angle: nil)
                })
            }
            if item.offset == 4{
                k.defaultSymbleIndex = 3
            } else {
                k.defaultSymbleIndex = 0
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap) + letterStart, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row4.append(k)
        }
        var del = KeyInfo()
        del.image = "icon_key_delete"
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - keyWidthShift - keyIndent1, y: keyTop, width: keyWidthShift, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyWidthShift - 12, y: 3, width: keyWidthShift + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)

        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor,.PhoneHor:
            widths = [keyWidthShift,keyWidthShift,kSCREEN_WIDTH - 4 * (keyHorGap + keyWidthShift) - 2 * keyIndent1,keyWidthShift,keyWidthShift]
        case .PhoneVer:
            let xScale = (kSCREEN_WIDTH - 28) / 347
            widths = [61 * xScale,59 * xScale,116 * xScale,43 * xScale,68 * xScale]
        }
        var row5 = [KeyInfo]()
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.fontSize = 18
        symKey.fillColor = UIColor.yellow
        symKey.textColor = UIColor.white
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent1, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.image = "icon_key_emoji"
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)

        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_en_ch_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleChieseMore)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }
}
