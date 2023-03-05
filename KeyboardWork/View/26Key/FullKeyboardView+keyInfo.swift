//
//  FullKeyboardView+keyInfo.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/16.
//

import UIKit

extension FullKeyboardView{
    
    func setChinese26Data(){
        let f = [("Q","1"),("W","2"),("E","3"),("R","4"),("T","5"),("Y","6"),("U","7"),("I","8"),("O","9"),("P","0")]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset)
            k.showTip =  UIDevice.current.orientation.rawValue <= 2
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.chinese)
            row2.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row2)
        
        let s = [("A","~"),("S","！"),("D","@"),("F","#"),("G","%"),("H","“"),("J","”"),("K","*"),("L","？")]
        var row3 = [KeyInfo]()
        for item in s.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 10)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.chinese)
            k.showTip = UIDevice.current.orientation.rawValue <= 2
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [("Z","（"),("X","）"),("C","-"),("V","_"),("B","："),("N","；"),("M","/")]
      
        var row4 = [KeyInfo]()
        var shiftKey = KeyInfo()
        shiftKey.fillColor = cKeyBgColor2
        shiftKey.text = "\u{21E7}"
        shiftKey.textColor = cKeyTextColor
        shiftKey.keyType = .shift(.shift)
        shiftKey.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        shiftKey.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(shiftKey)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element.0
            k.tip = item.element.1
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.id = UInt8(item.offset + 20)
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + 3 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth, height: keyHeight)
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
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            widths = [keyWidth,keyWidth,keyWidth, 6 * unitWidth - keyHorGap, keyWidth,2.5 * unitWidth - keyHorGap]
        case .PhoneHor, .PhoneVer:
            if UIDevice.isNotch{
                widths = [2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap ,keyWidth,5 * unitWidth - keyHorGap, 2.5 * unitWidth - keyHorGap, 3.5 * unitWidth - keyHorGap]
            } else {
                widths = [2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,6.5 * unitWidth - keyHorGap, 2.5 * unitWidth - keyHorGap, 3.5 * unitWidth - keyHorGap]
            }
        }
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.textColor = cKeyTextColor
        symKey.fontSize = 20
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .switchKeyboard(.symbleChiese)
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        var tmpKey:KeyInfo!
        if UIDevice.isNotch{
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.textColor = cKeyTextColor
            numKey.fillColor = cKeyBgColor2
            numKey.fontSize = 18
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(numKey)
            
            var commaKey = KeyInfo()
            commaKey.text = "，"
            commaKey.fillColor = cKeyBgColor
            commaKey.textColor = cKeyTextColor
            commaKey.keyType = .normal(.character)
            commaKey.tipSize = 14
            commaKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(commaKey)
            tmpKey = commaKey
        } else {
            var switchKey = KeyInfo()
            switchKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            switchKey.keyType = .switchInput
            row5.append(switchKey)
            tmpKey = switchKey
            
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(numKey)
            tmpKey = numKey
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                var commaKey = KeyInfo()
                commaKey.text = "，"
                commaKey.fillColor = cKeyBgColor
                commaKey.textColor = cKeyTextColor
                commaKey.keyType = .normal(.character)
                commaKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
                row5.append(commaKey)
                tmpKey = commaKey
            }
        }
        
       
        
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        tmpKey = spaceKey
        if UIDevice.isNotch || UIDevice.current.userInterfaceIdiom == .pad{
            var fullStopKey = KeyInfo()
            fullStopKey.text = "。"
            fullStopKey.tip = "."
            fullStopKey.tipSize = 21
            fullStopKey.tips = [SymbleInfo(text: ".", angle: nil),SymbleInfo(text: "。", angle: nil)]
            fullStopKey.fillColor = cKeyBgColor
            fullStopKey.textColor = cKeyTextColor
            fullStopKey.keyType = .normal(.character)
            fullStopKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: (UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 2) * unitWidth - keyHorGap, height: keyHeight)
            row5.append(fullStopKey)
            tmpKey =  fullStopKey
        }
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{592A}"
        switchKey.textColor = cKeyTextColor
        switchKey.fontSize = 18
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.english)
        var subKey = SubKeyInfo()
        subKey.text = "\u{9633}"
        subKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ??  KeyInfo.returnKey()
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
            k.showTip =  UIDevice.current.orientation.rawValue <= 2
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [("z","("),("x",")"),("c","-"),("v","_"),("b",":"),("n",";"),("m","/")]
        var row4 = [KeyInfo]()
        var shiftKey = KeyInfo()
        shiftKey.fillColor = cKeyBgColor2
        switch shiftType {
        case .normal:
            shiftKey.text = "\u{21E7}"
            shiftKey.textColor = cKeyTextColor
            shiftKey.keyType = .shift(.shift)
        case .shift:
            shiftKey.text = "\u{2B06}"
            shiftKey.textColor = Colors.color1E2028
            shiftKey.keyType = .shift(.normal)
            if #available(iOSApplicationExtension 12.0, *) {
                shiftKey.fillColor = cKeyShiftOnColor
            }
        case .lock:
            shiftKey.text = "\u{21EA}"
            shiftKey.textColor = Colors.color1E2028
            shiftKey.keyType = .shift(.normal)
            if #available(iOSApplicationExtension 12.0, *) {
                shiftKey.fillColor = cKeyShiftOnColor
            }
        }
        
        shiftKey.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        shiftKey.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + 3 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth, height: keyHeight)
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
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        
        var row5 = [KeyInfo]()
        var widths : [CGFloat]!
        switch UIDevice.current.deviceDirection{
        case .PadHor,.PadVer:
            widths = [keyWidth,keyWidth,keyWidth, 6 * unitWidth - keyHorGap, keyWidth,2.5 * unitWidth - keyHorGap]
        case .PhoneHor, .PhoneVer:
            if UIDevice.isNotch{
                widths = [2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,keyWidth,5 * unitWidth - keyHorGap, 2.5 * unitWidth - keyHorGap, 3.5 * unitWidth - keyHorGap]
            } else {
                widths = [2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,6.5 * unitWidth - keyHorGap, 2.5 * unitWidth - keyHorGap, 3.5 * unitWidth - keyHorGap]
            }
        }
        var symKey = KeyInfo()
        symKey.text = "符"
        symKey.fontSize = 20
        symKey.textColor = cKeyTextColor
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .switchKeyboard(.symbleEnglish)
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var tmpKey:KeyInfo!
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
            commaKey.fillColor = cKeyBgColor
            commaKey.textColor = cKeyTextColor
            commaKey.keyType = .normal(.character)
            commaKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(commaKey)
            tmpKey = commaKey
           
        } else {
            var switchKey = KeyInfo()
            switchKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
            row5.append(switchKey)
            tmpKey = switchKey
           
            var numKey = KeyInfo()
            numKey.text = "123"
            numKey.fontSize = 18
            numKey.fillColor = cKeyBgColor2
            numKey.textColor = cKeyTextColor
            numKey.keyType = .switchKeyboard(.number)
            numKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
            row5.append(numKey)
            tmpKey = numKey
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                var commaKey = KeyInfo()
                commaKey.text = ","
                commaKey.fillColor = cKeyBgColor
                commaKey.textColor = cKeyTextColor
                commaKey.keyType = .normal(.character)
                commaKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
                row5.append(commaKey)
                tmpKey = commaKey
            }
        }
                
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        tmpKey = spaceKey
        
        if UIDevice.isNotch || UIDevice.current.userInterfaceIdiom == .pad{
            var commaKey = KeyInfo()
            commaKey.text = "."
            commaKey.fillColor = cKeyBgColor
            commaKey.textColor = cKeyTextColor
            commaKey.fontSize = 20
            commaKey.tipSize = 14
            commaKey.keyType = .normal(.character)
            commaKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: (UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 2) * unitWidth - keyHorGap, height: keyHeight)
            row5.append(commaKey)
            tmpKey =  commaKey
        }
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{6708}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        switchKey.keyType = .switchKeyboard(KeyboardInfo.KeyboardType)
        var subKey = SubKeyInfo()
        subKey.text = "\u{4EAE}"
        subKey.textColor = cKeyTextColor
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ?? KeyInfo.returnKey()
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[5], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }
    
    func setChineseSymbleData(){
        var f : [String]!
        
        f = ["1","2","3","4","5","6","7","8","9","0"]
        
        let fs = ["1一壹１①⑴⒈❶㊀㈠","贰2二２②⑵⒉❷㊁㈡","③叁3三３⑶⒊❸㊂㈢","⒋④肆4四４⑷❹㊃㈣","㊄⒌⑤伍5五５⑸❺㈤","㈥㊅⒍⑥陆6六６⑹❻","㈦㊆❼⒎⑦柒7七７⑺","㈧㊇❽⒏⑻⑧捌8八８","㈨㊈❾⒐⑼⑨９玖9九","°⓪零０0"]
        let needBackKeys0 = [1,2,3,4,5,6,7]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
           
            if needBackKeys0.contains(item.offset){
                k.canBack = true
            }
            
            if item.offset < 9{
                k.defaultSymbleIndex = item.offset
            } else {
                k.defaultSymbleIndex = 4
            }
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
        let keyWidth1 = (kSCREEN_WIDTH - 7 * unitWidth) / 6 - keyHorGap
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.fontSize = 16
        sep.keyType = .switchKeyboard(.symbleChieseMore)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap) + 3.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset != 5{
                k.canBack = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
       
        var row5 = [KeyInfo]()
        let widths = [3.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,8 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,3.5 * unitWidth - keyHorGap]
        
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textColor = cKeyTextColor
        symKey.fontSize = 20
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.text = "\u{7B11}"
        emojiKey.textColor = cKeyTextColor
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
     
        
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{592A}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleEnglish)
        var subKey = SubKeyInfo()
        subKey.text = "\u{9633}"
        subKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ??  KeyInfo.returnKey()
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y:keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
        
        
    }

    func setEnglishSymbleData(){
        var f : [String]!
        f = ["1","2","3","4","5","6","7","8","9","0"]
        let needBackKeys0 = [0,1,2,3,4,5,6,7]
        var row2 = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            if needBackKeys0.contains(item.offset){
                k.canBack = true
            }
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
        let keyWidth1 = (kSCREEN_WIDTH - 8 * unitWidth) / 5 - keyHorGap
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "#+="
        sep.keyType = .switchKeyboard(.symbleEnglishMore)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.fontSize = 16
        sep.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap)  + 4 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset > 0{
                k.canBack = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        let widths = [3.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,8 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,3.5 * unitWidth - keyHorGap]
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textColor = cKeyTextColor
        symKey.fontSize = 20
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.text = "\u{7B11}"
        emojiKey.textColor = cKeyTextColor
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
     
        
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{6708}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleChiese)
        var subKey = SubKeyInfo()
        subKey.text = "\u{4EAE}"
        subKey.textColor = cKeyTextColor
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ?? KeyInfo.returnKey()
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
        let keyWidth1 = (kSCREEN_WIDTH - 7 * unitWidth) / 6 - keyHorGap
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "符"
        sep.textColor = cKeyTextColor
        sep.keyType = .switchKeyboard(.symbleChiese)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.fontSize = 20
        sep.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(sep)
        for item in t.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.tips = ts[item.offset]
            k.defaultSymbleIndex = tsIndex[item.offset]
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap)  + 3.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            if item.offset != 0{
                k.canBack  = true
            }
            row4.append(k)
        }
        var del = KeyInfo()
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)
        
        var row5 = [KeyInfo]()
        let widths = [3.5 * unitWidth - keyHorGap,2.5 * unitWidth  - keyHorGap,8 * unitWidth  - keyHorGap,2.5 * unitWidth  - keyHorGap,3.5 * unitWidth  - keyHorGap]

        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.textColor = cKeyTextColor
        symKey.fontSize = 20
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.text = "\u{7B11}"
        emojiKey.textColor = cKeyTextColor
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)
        
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{592A}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleEnglishMore)
        var subKey = SubKeyInfo()
        subKey.text = "\u{9633}"
        subKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ?? KeyInfo.returnKey()
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }

    func setEnglishSybmbleMoreData(){
        let f = ["[","]","{","}","#","%","^","*","+","="]
        let fs = ["","","","","","%‰","","","","≈≠="]
        var row2 = [KeyInfo]()
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row3.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(row3)
        
        let t = [".",",","?","!","`"]
        let ts = [".…","","?¿","!¡","`‘’'"]
        let keyWidth1 = (kSCREEN_WIDTH - 8 * unitWidth) / 5 - keyHorGap
        var row4 = [KeyInfo]()
        var sep = KeyInfo()
        sep.text = "符"
        sep.textColor = cKeyTextColor
        sep.fontSize = 20
        sep.keyType = .switchKeyboard(.symbleEnglish)
        sep.fillColor = cKeyBgColor2
        sep.textColor = cKeyTextColor
        sep.position = CGRect(x: keyIndent, y: keyTop, width: keyShiftWidth, height: keyHeight)
        sep.hotArea = CGRect(x: 0, y: 3, width: keyShiftWidth + 12, height: keyHeight + 10)
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
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth1 + keyHorGap)  + 4 * unitWidth + keyHorGap / 2, y: keyTop, width: keyWidth1, height: keyHeight)
            k.keyType = .normal(.character)
            k.canBack = true
            row4.append(k)
        }
        var del = KeyInfo()
        del.text = "\u{232B}"
        del.textColor = cKeyTextColor
        del.keyType = .del
        del.fillColor = cKeyBgColor2
        del.position = CGRect(x: kSCREEN_WIDTH - 2.5 * unitWidth + keyHorGap / 2, y: keyTop, width: keyShiftWidth, height: keyHeight)
        del.hotArea = CGRect(x: kSCREEN_WIDTH - keyShiftWidth - 12, y: 3, width: keyShiftWidth, height: keyHeight + 10)
        row4.append(del)
        keyTop += keyHeight + keyVerGap
        keys.append(row4)

        let widths = [3.5 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,8 * unitWidth - keyHorGap,2.5 * unitWidth - keyHorGap,3.5 * unitWidth - keyHorGap]
        var row5 = [KeyInfo]()
        var symKey = KeyInfo()
        symKey.text = "返回"
        symKey.fontSize = 20
        symKey.textColor = cKeyTextColor
        symKey.fillColor = cKeyBgColor2
        symKey.keyType = .backKeyboard
        symKey.position = CGRect(x: keyIndent, y: keyTop, width: widths[0], height: keyHeight)
        row5.append(symKey)
        
        var emojiKey = KeyInfo()
        emojiKey.text = "\u{7B11}"
        emojiKey.textColor = cKeyTextColor
        emojiKey.fillColor = cKeyBgColor2
        emojiKey.position = CGRect(x: symKey.position.maxX + keyHorGap, y: keyTop, width: widths[1], height: keyHeight)
        emojiKey.keyType = .switchKeyboard(.emoji)
        row5.append(emojiKey)

        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: emojiKey.position.maxX + keyHorGap, y: keyTop, width: widths[2], height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{6708}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: keyTop, width: widths[3], height: keyHeight)
        switchKey.keyType = .switchKeyboard(.symbleChieseMore)
        var subKey = SubKeyInfo()
        subKey.text = "\u{4EAE}"
        subKey.textColor = cKeyTextColor
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ??  KeyInfo.returnKey()
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: keyTop, width: widths[4], height: keyHeight)
        row5.append(enterKey)
        keys.append(row5)
    }
}
