//
//  NumberBoardView.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/15.
//

import Foundation
import UIKit
class NumberKeyboardView:Keyboard{

    var pressedKey: KeyInfo?
    var panPoint: CGPoint?
    var previousPoint: CGPoint?
    var isGesture = false
    var panPosition: CGPoint?
    var hotAreaVerOffset : [CGFloat]!
    
    var keyTop : CGFloat = 0            //该行按键的上边
    var unitWidth20 : CGFloat = 0
    var unitWidth18 : CGFloat = 0
    var keyHeightBottom : CGFloat = 0
    var keyIndent:CGFloat{
        return keyHorGap / 2
    }
    var sensorKeyboardSource = ""
    var rowRanges = [CGFloat]()
    var ranges = [[CGFloat]]()
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(returnKey:KeyInfo?) {
        self.init(frame: .zero)
        self.tmpReturnKey = returnKey
        keyboardName = "123数字页"
        self.currentKeyBoardType = .number
        backgroundColor = keyboardBgColor
        keyboardWidth = kSCREEN_WIDTH
        hotAreaVerOffset =  [0.1,0.5,0.6,0.7,1]
        createLayout()
        createKeys()
        createRange()
        createBoard()
        createGesture()
    }

    func createLayout(){
        unitWidth20 = kSCREEN_WIDTH / 20
        unitWidth18 = kSCREEN_WIDTH / 18
        switch UIDevice.current.deviceDirection{
        case .PadVer:
            scale = 1.12
            keyTopMargin = 6
            keyHorGap = 10
            keyVerGap = 6
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PadHor:
            scale = 1.12
            keyTopMargin = 8
            keyHorGap = 14
            keyVerGap = 8
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PhoneHor:
            keyTopMargin = 5
            keyHorGap = 11
            keyVerGap = 5.5
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 24) / 4
        case .PhoneVer:
            keyTopMargin = 7
            
            keyVerGap = 7
            keyHorGap = 6
            keyHeightBottom = stardKeyHeight
            scale = kSCREEN_WIDTH < kSepScreenWidth ? 1 : 1.075
        }
            keyHeight = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - keyHeightBottom) / 3 - keyVerGap
        
        keyTop = keyTopMargin
    }
    
    func createKeys(){
      
       
        var row2 = [KeyInfo]()
        var row3 = [KeyInfo]()
        var row4 = [KeyInfo]()
        var row5 = [KeyInfo]()
        let keyTexts = ["1","2","3","4","5","6","7","8","9"]
        for item in keyTexts.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.keyType = .normal(.character)
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.pressColor = cKeyBgPressColor
            let r = item.offset / 3
            let c = item.offset % 3
            k.position = CGRect(x: 3 * unitWidth18 + keyHorGap / 2 + unitWidth18 * 4  * CGFloat(c), y: keyTop + (keyHeight + keyVerGap) * CGFloat(r), width: unitWidth18 * 4 - keyHorGap, height: keyHeight)
            if r == 0{
                row2.append(k)
            } else if r == 1{
                row3.append(k)
            } else {
                row4.append(k)
            }
        }
        
        var delKey = KeyInfo()
        delKey.position = CGRect(x: row2.last!.position.maxX + keyHorGap, y: row2.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        delKey.text = "\u{232B}"
        delKey.fontSize = 21
        delKey.textColor = cKeyTextColor
        delKey.fillColor = cKeyBgColor2
        delKey.pressColor = UIColor.white | Colors.color696B70
        delKey.keyType = .del
        row2.append(delKey)
        
        var atKey = KeyInfo()
        atKey.position = CGRect(x: row3.last!.position.maxX + keyHorGap, y: row3.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        atKey.fillColor = cKeyBgColor2
        atKey.textColor = cKeyTextColor
        atKey.pressColor = UIColor.white | Colors.color696B70
        atKey.fontSize = 21
        atKey.text = "@"
        atKey.keyType = .normal(.character)
        
        row3.append(atKey)
        
        var pointKey = KeyInfo()
        pointKey.position = CGRect(x: row4.last!.position.maxX + keyHorGap, y: row4.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        pointKey.text = "."
        pointKey.fontSize = 21
        pointKey.fillColor = cKeyBgColor2
        pointKey.textColor = cKeyTextColor
        pointKey.pressColor = UIColor.white | Colors.color696B70
        pointKey.keyType = .normal(.character)
        row4.append(pointKey)
        
        var symbleKey = KeyInfo()
        symbleKey.text = "符"
        symbleKey.textColor = cKeyTextColor
        symbleKey.fillColor = cKeyBgColor2
        symbleKey.pressColor = UIColor.white | Colors.color696B70
        symbleKey.position = CGRect(x: keyIndent, y: row4.first!.position.maxY + keyVerGap, width: unitWidth18 * 3 - keyHorGap, height: keyHeightBottom)
        symbleKey.keyType = .switchKeyboard(.symbleChiese)
        row5.append(symbleKey)
                
        var backKey = KeyInfo()
        backKey.text = "返回"
        backKey.textColor = cKeyTextColor
        backKey.fillColor = cKeyBgColor2
        backKey.pressColor = UIColor.white | Colors.color696B70
        backKey.position = CGRect(x: symbleKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: unitWidth18 * 4 - keyHorGap, height: keyHeightBottom)
        backKey.keyType = .backKeyboard
        row5.append(backKey)
        
        var zeroKey = KeyInfo()
        zeroKey.text = "0"
        zeroKey.textColor = cKeyTextColor
        zeroKey.fillColor = cKeyBgColor
        zeroKey.pressColor = cKeyBgPressColor
        zeroKey.position = CGRect(x: backKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: unitWidth18 * 4 - keyHorGap, height: keyHeightBottom)
        zeroKey.keyType = .normal(.character)
        row5.append(zeroKey)
                
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.pressColor = cKeyBgPressColor
        spaceKey.position = CGRect(x: zeroKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: unitWidth18 * 4 - keyHorGap, height: keyHeightBottom)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var enterKey = tmpReturnKey ?? KeyInfo.returnKey()
        enterKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeightBottom)
        row5.append(enterKey)
        
        keys.append(row2)
        keys.append(row3)
        keys.append(row4)
        keys.append(row5)
    }
    
    func createRange(){
        for row in keys.enumerated(){
            rowRanges.append(row.element.first!.position.maxY + hotAreaVerOffset[row.offset] * keyHorGap)
            var tmp = [CGFloat]()
            for item in row.element.enumerated(){
                if item.offset == row.element.count - 1{
                    tmp.append(item.element.position.maxX + keyIndent)
                } else {
                    tmp.append(item.element.position.maxX + keyVerGap / 2)
                }
            }
            ranges.append(tmp)
        }
    }
    
    override func createBoard(){
        let leftShadowLayer = CAShapeLayer()
        let leftShadowRect = CGRect(x: keyIndent, y: keys[2][0].position.maxY - 10, width: unitWidth18 * 3 - keyHorGap, height: 11)
        leftShadowLayer.fillColor = cKeyShadowColor.cgColor
        leftShadowLayer.path = UIBezierPath(roundedRect: leftShadowRect, cornerRadius: 5).cgPath
        layer.addSublayer(leftShadowLayer)
        addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalTo(keyIndent)
            
            make.top.equalTo(keys[0][0].position.minY)
            make.height.equalTo(keys[2][0].position.maxY - keys[0][0].position.minY)
            
            make.width.equalTo(unitWidth18 * 3 - keyHorGap)
        }
        //绘制白底
       
        for i in 0..<keys.count{
            for j in 0..<keys[i].count{
                let k = keys[i][j]
                let keyLayer = CAShapeLayer()
                keyLayer.fillColor = k.fillColor.cgColor
                let path = UIBezierPath(roundedRect: k.position, cornerRadius: 5)
                keyLayer.path = path.cgPath
                keys[i][j].keyLayer = keyLayer
                layer.addSublayer(keyLayer)
                
                // shadowlayer
                if  i == 0{
                    
                } else {
                    let shadowLayer = CAShapeLayer()
                    let shadowRect = CGRect(x: k.position.origin.x, y: k.position.maxY - 10, width: k.position.width, height: 11)
                    shadowLayer.fillColor = cKeyShadowColor.cgColor
                    shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
                    layer.insertSublayer(shadowLayer, below: keyLayer)
                }
                // imageLayer
                if !k.image.isEmpty {
                    let img = UIImage.themeImg(k.image,origin: true)
                    let imgLayer = CALayer()
                    imgLayer.frame = k.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
                    imgLayer.contents = img.cgImage
                    keys[i][j].imgLayer = imgLayer
                    layer.addSublayer(imgLayer)
                }
                
                if !k.text.isEmpty {
                    let txtSize = k.text.getSize(font: UIFont.paleRegular(size: 20 * scale))
                    let txtLayer = CATextLayer()
                    txtLayer.frame = k.position.centerRect(w: txtSize.width, h: txtSize.height)
                    txtLayer.foregroundColor = k.textColor.cgColor
                    txtLayer.string = k.text
                    txtLayer.contentsScale = UIScreen.main.scale
                    txtLayer.font =  UIFont.paleRegular(size: 20 * scale) as CTFont
                    txtLayer.fontSize = 20 * scale
                    keys[i][j].textLayer = txtLayer
                    layer.addSublayer(txtLayer)
                }
            }
        }
    }
    
    func createGesture(){
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPress(key:KeyInfo){
        delegate?.keyPress(key: key)
    }
    
    override func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State){
        delegate?.keyLongPress(key: key, state: state)
    }
    
    override func updateStatus(_ status: BoardStatus) {
        if status != boardStatus{
            updateReturnKey(key: KeyInfo.returnKey())
            boardStatus = status
        }
    }
    
    override func update(returnKey:KeyInfo){
        self.updateReturnKey(key: returnKey)
        boardStatus = nil
    }
    
    func updateReturnKey(key: KeyInfo) {
        let i = keys.count - 1
        let j = keys[i].count - 1
        keys[i][j].keyLayer?.removeFromSuperlayer()
        keys[i][j].keyLayer = nil
        keys[i][j].imgLayer?.removeFromSuperlayer()
        keys[i][j].imgLayer = nil
        keys[i][j].textLayer?.removeFromSuperlayer()
        keys[i][j].textLayer = nil
        var tmpKey = key
        tmpKey.position = keys[i][j].position
        
        keys[i][j] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[i][j].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        if !tmpKey.image.isEmpty{
            let img =  UIImage.themeImg(tmpKey.image, origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        
        if !tmpKey.text.isEmpty{
            var fontSize : CGFloat = 20
            if tmpKey.fontSize != nil{
                fontSize = tmpKey.fontSize!
            }
            fontSize = fontSize * scale
            let txtSize = tmpKey.text.getSize(font: UIFont.paleRegular(size: fontSize))
            let txtLayer = CATextLayer()
            let txtRect = tmpKey.position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.frame = txtRect
            txtLayer.foregroundColor = tmpKey.textColor.cgColor
            txtLayer.string = tmpKey.text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = UIFont.paleRegular(size: fontSize)
            txtLayer.fontSize = fontSize
            keys[i][j].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
    }
    
    lazy var leftView:NineKeyLeftView = {
        var tmp = ["=","%","￥","-","x","÷","*","/","(",")","$","#"]
        let v = NineKeyLeftView(keys: tmp,imgs: [], keyHeight: keyHeight)
       return v
    }()

}



