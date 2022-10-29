//
//  FullRowKeysView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

class FullRowKeysView:UIView,UIGestureRecognizerDelegate{
    var keys:[KeyInfo]!
    var pressedKey : KeyInfo?
    var panPoint:CGPoint?
    var previousPoint:CGPoint?
    var tmpLayers = [CALayer]()
    var row = 0
    var range = [CGFloat]()
    var fullKeyboardView:FullKeyboardView{
        return superview as! FullKeyboardView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(ges:)))
        pan.maximumNumberOfTouches = 2
        pan.minimumNumberOfTouches = 1
        pan.delaysTouchesBegan = false
        pan.delegate = self
        addGestureRecognizer(pan)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
    }
    
  
    func updateReturnKey(newKey:KeyInfo){
        let index = keys.count - 1
        keys[index].keyLayer?.removeFromSuperlayer()
        keys[index].keyLayer = nil
        keys[index].imgLayer?.removeFromSuperlayer()
        keys[index].imgLayer = nil
        keys[index].textLayer?.removeFromSuperlayer()
        keys[index].textLayer = nil
        var tmpKey = newKey
        tmpKey.position = keys.last!.position
        
        keys[index] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[index].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        if !tmpKey.image.isEmpty{
            let img = UIImage.themeImg(tmpKey.image, origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
            imgLayer.contents = img.cgImage
            keys[index].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        
        if !tmpKey.text.isEmpty{
            let lbl = UILabel()
            lbl.text = tmpKey.text
            lbl.font = UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 18))
            let txtLayer = CATextLayer()
            txtLayer.frame = tmpKey.position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.foregroundColor = tmpKey.textColor.cgColor
            txtLayer.string = tmpKey.text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
            txtLayer.fontSize = 18 * KBScale
            keys[index].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
    }
    
    func updateKeys(newKeys:[KeyInfo]){
        self.keys = newKeys
        layer.sublayers?.forEach{$0.removeFromSuperlayer()}
        range.removeAll()
        for  item in keys.enumerated(){
            
            if row == 2{
                if item.offset == keys.count - 1{
                    range.append(kSCREEN_WIDTH)
                } else {
                    range.append(item.element.hotArea?.maxX ?? item.element.position.maxX + 2.5)
                }
            } else{
                if item.offset == keys.count - 1{
                    range.append(kSCREEN_WIDTH)
                } else {
                    range.append(item.element.position.maxX + 2.5)
                }
            }
            
            //key layer
            let keyLayer = CAShapeLayer()
            keyLayer.fillColor = item.element.fillColor.cgColor
            let path = UIBezierPath(roundedRect: item.element.position, cornerRadius: 5)
            keyLayer.path = path.cgPath
            keys[item.offset].keyLayer = keyLayer
            layer.addSublayer(keyLayer)
            
            //shadowlayer
            let shadowLayer = CAShapeLayer()
            let shadowRect = CGRect(x: item.element.position.origin.x, y: item.element.position.maxY - 10, width: item.element.position.width, height: 11)
            shadowLayer.fillColor = cKeyShadowColor.cgColor
            shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
            layer.insertSublayer(shadowLayer, below: keyLayer)

            //imageLayer
            
            if !item.element.image.isEmpty{
                let img =  UIImage.themeImg(item.element.image, origin: true)
                let imgLayer = CALayer()
                imgLayer.frame = item.element.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
                imgLayer.contents = img.cgImage
                keys[item.offset].imgLayer = imgLayer
                layer.addSublayer(imgLayer)
            }
            
            if !item.element.text.isEmpty{
                let txtSize = item.element.text.getSize(font: UIFont(name: "PingFangSC-Regular", size: (item.element.fontSize ?? 22) * KBScale)!)
                let txtLayer = CATextLayer()
                let txtRect = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
//                if !item.element.tip.isEmpty && item.element.showTip{
//                    txtLayer.frame = txtRect.offsetBy(dx: item.element.text.characherOffset, dy: 2)
//                } else{
//                    txtLayer.frame = txtRect.offsetBy(dx: item.element.text.characherOffset, dy: 0)
//                }
                txtLayer.frame = txtRect.offsetBy(dx: item.element.text.characherOffset, dy: 0)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                if item.element.text == ","{
                    txtLayer.font = UIFont.systemFont(ofSize: 22 * KBScale) as CTFont
                } else {
                    txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                }
                var fontSize : CGFloat = 22
                if item.element.fontSize == nil && fullKeyboardView.shiftStatus == .normal{
                    fontSize = 23
                }
                if item.element.fontSize != nil{
                    fontSize = item.element.fontSize!
                }
                txtLayer.fontSize = fontSize * KBScale
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
                
                if !item.element.tip.isEmpty && item.element.showTip{
                    let tipSize = item.element.tip.getSize(font: UIFont(name: "PingFangSC-Regular", size: (item.element.tipSize ?? 10) * KBScale)!)
                    let tipLayer = CATextLayer()
                    tipLayer.frame = item.element.position.centerRect(w: tipSize.width, h: tipSize.height).offsetBy(dx: item.element.text.characherOffset * 0.5, dy: -13)
                    tipLayer.foregroundColor = item.element.tip == "。" ? cKeyTextColor.cgColor  : cKeyTipColor.cgColor
                    tipLayer.string = item.element.tip
                    tipLayer.contentsScale = UIScreen.main.scale
                    tipLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                    tipLayer.fontSize = (item.element.tipSize ?? 10) * KBScale
                    keys[item.offset].tipLayer = tipLayer
                    layer.addSublayer(tipLayer)
                }
            }
        }
    }

    
    @objc func panGes(ges:UIPanGestureRecognizer){
        print("panGes\(ges.state)")
        let point = ges.location(in: self)
        switch ges.state{
        case .began:
            panPoint = point
            fullKeyboardView.isGestured = true
            fullKeyboardView.panPosition = point
        case .ended:
            //方向还没有处理
            if pressedKey != nil && (pressedKey!.keyType.isNormal || pressedKey!.keyType == .del) && panPoint != nil{
                let distance = panPoint!.y - point.y
                if abs(distance) < 10 && abs(panPoint!.x - point.x) < 10{ //如果触发了pan，这时可能这个距离特别短，那么可不可以认为是一次按键呢？对搜狗的试验可以认为是一次按键,那么这个距离设定为多少好呢？试试10看看效果
                    if let keyboard = superview as? Keyboard{
                        keyboard.keyPress(key: pressedKey!)
                    }
                }
                if distance > 30 && point.x > pressedKey!.position.minX - distance * 0.6 && point.x < pressedKey!.position.maxX + distance * 0.6{
                    if let keyboard = superview as? FullKeyboardView{
                        var key = pressedKey!
                        key.clickType = .tip
                        key.keyType = .normal(.character)
                        Shake.keyShake()
                        keyboard.keyPress(key: key)
                    }
                }
            }
            fullKeyboardView.popKeyView.isHidden = true
            removePressEffect()
            pressedKey = nil
            panPoint = nil
            fullKeyboardView.isGestured = false
            fullKeyboardView.panPosition = nil
        case .cancelled,.failed:
            fullKeyboardView.popKeyView.isHidden = true
            removePressEffect()
            panPoint = nil
            pressedKey = nil
            fullKeyboardView.isGestured = false
            fullKeyboardView.panPosition = nil
        case .changed:
            print("paning:\(point)")
            if fullKeyboardView.panPosition == nil{
                fullKeyboardView.panPosition = point
            }
            fullKeyboardView.popKeyView.isHidden = true
            let yoffset = point.y - panPoint!.y
            let xOffset =  point.x - panPoint!.x
            if point.x - fullKeyboardView.panPosition!.x > 20  && abs(yoffset / xOffset) < 0.8{
                fullKeyboardView.panPosition = point
                keyboardVC?.moveCursor(direction: true)
            } else if point.x - fullKeyboardView.panPosition!.x < -20  && abs(yoffset / xOffset) < 0.8{
                fullKeyboardView.panPosition = point
                keyboardVC?.moveCursor(direction: false)
            }
        default:
            break
        }
    }
    
    @objc func longPressGes(ges:UILongPressGestureRecognizer){
        let point = ges.location(in: self)

        switch ges.state{
        case .began:
            fullKeyboardView.isGestured = true
            if fullKeyboardView.popChooseView != nil &&  !(superview as! FullKeyboardView).popChooseView!.isHidden{
                return
            }
            if pressedKey == nil{
                return
            }
            if  pressedKey!.keyType.isReturnKey && pressedKey!.text == "发送"{
                Shake.keyShake()
                var k = KeyInfo()
                k.keyType = .newLine
                (superview as! FullKeyboardView).keyPress(key: k)
                return
            }
            if  !pressedKey!.keyType.isNormal && pressedKey!.keyType == .del{
                Shake.keyShake()
                (superview as! FullKeyboardView).keyLongPress(key: pressedKey!, state: ges.state)
                return
            }
          
            //分支说明，对于符号按键，如果存在有tip的情况，长按会优化输出tip，目前只有逗号和句号这一个按键，其他符号按键都没有tip
            if !pressedKey!.text.isEmpty && !pressedKey!.text.first!.isLetter && !pressedKey!.tip.isEmpty{
                let key = pressedKey!
                Shake.keyShake()
                fullKeyboardView.popKeyView.lblKey.text = key.tip
                return
            }
            
            //这种情况下不需要弹出多符号选择框
            if pressedKey!.tip.isEmpty && pressedKey!.tips == nil {
                return
            }
            
            if let key = pressedKey{
                var txt = [SymbleInfo]()
                if key.tips != nil{
                    txt = key.tips!
                } else if !key.tip.isEmpty {
                    txt = [SymbleInfo(text: key.text.uppercased(), angle: nil),SymbleInfo(text: key.tip, angle: nil),SymbleInfo(text: key.text.lowercased(), angle: nil)]
                }
                let txtCount = txt.count
                let width : CGFloat = CGFloat(txtCount * 36 + 8)
                let pos = convert(key.position, to: superview)
                var x = pos.midX - width / 2.0
                if x - 5 <= 0{
                    x = 5
                }
                if x + width + 5 >= kSCREEN_WIDTH{
                    x = kSCREEN_WIDTH - width - 5
                }
                let chooseView = PopKeyChooseView(frame: CGRect(x: x, y: pos.minY - 55 * KBScale, width: width, height: 50 * KBScale), keys: txt,defaultIndex: key.defaultSymbleIndex ?? -1)
                
                if let v = superview as? FullKeyboardView{
                    v.popChooseView = chooseView
                    v.addSubview(chooseView)
                    fullKeyboardView.popKeyView.isHidden = true
                }
                previousPoint = point
                addPressEffect(fillColor: UIColor(hexString: "a2a5ad")! | UIColor(hexString: "414245")!)
                Shake.keyShake()
            }
                    
             
            

        case .changed:
            if previousPoint != nil{
                if point.x - previousPoint!.x > 20{
                    previousPoint = point
                    (superview as! FullKeyboardView).popChooseView?.selectIndex += 1
                } else if point.x - previousPoint!.x < -20{
                    previousPoint = point
                    (superview as! FullKeyboardView).popChooseView?.selectIndex -= 1
                }
            }
            print("changed\(ges.location(in: self))")
        case .ended,.cancelled:
            previousPoint = nil
            if let v = (superview as! FullKeyboardView).popChooseView{
                var key = KeyInfo()
                key.text = v.selectedText
                key.canBack = pressedKey!.canBack
                key.keyType = .normal(.character)
                fullKeyboardView.keyPress(key: key)
                fullKeyboardView.popChooseView?.removeFromSuperview()
                fullKeyboardView.popChooseView = nil
                fullKeyboardView.popKeyView.isHidden = true
                removePressEffect()
                pressedKey = nil
            }
            if pressedKey != nil && previousPoint == nil{
                if pressedKey!.keyType == .del{
                    (superview as! FullKeyboardView).keyLongPress(key: pressedKey!, state: ges.state)
                } else if pressedKey!.keyType == .normal(.character){
                   var k = pressedKey!
                    if !k.tip.isEmpty{
                        k.clickType = .tip
                    }
                    (superview as! FullKeyboardView).keyPress(key: k)
                }
                
                fullKeyboardView.popKeyView.isHidden = true
                removePressEffect()
                pressedKey = nil
            }
            (superview as? FullKeyboardView)?.isGestured = false
        case .failed:
            fullKeyboardView.popChooseView?.removeFromSuperview()
            fullKeyboardView.popChooseView = nil
            fullKeyboardView.popKeyView.isHidden = true
            (superview as? FullKeyboardView)?.isGestured = false
            removePressEffect()
            pressedKey = nil
        default:
            break
        }
       
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if fullKeyboardView.isGestured{
            return
        }
        guard let t = touches.first else {return}
        if t.phase == .began{
            let point = t.location(in: self)
            if pressedKey != nil{                                   //解释： 当用户几乎同时按下两个按键时，第二个按键的气泡会顶掉第一个，这时上字顺序是用户先松手的那个按键，这样会导致上字顺序错误，现在修改成当第二个气泡顶掉第一个时，也同时把第一个上字。这样肯定不会出现上字顺序错误和情况了
                fullKeyboardView.keyPress(key: pressedKey!)
                pressedKey = nil
            }
            Shake.keyShake()
            for i in 0..<range.count{
                if point.x <= range[0]{
                    pressedKey = keys[0]
                    addPopKeyView(pressKey: &keys[0])
                    break
                } else if point.x > range[i]  && point.x <= range[i + 1]{
                    pressedKey = keys[i+1]
                    addPopKeyView(pressKey: &keys[i+1])
                    break
                }
            }
           
            addPressEffect()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fullKeyboardView.isGestured{
            return
        }
        if pressedKey != nil{
            if let keyboard = superview as? FullKeyboardView{
                keyboard.keyPress(key: pressedKey!)
            }
            removePressEffect()
            pressedKey = nil
            self.fullKeyboardView.popKeyView.isHidden = true
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fullKeyboardView.isGestured{
            return
        }
        if pressedKey != nil{
            pressedKey = nil
            fullKeyboardView.popKeyView.isHidden = true
            
        }
    }
    
    
    func addPopKeyView(pressKey:inout KeyInfo){
        if pressKey.keyType.isNormal{
            let pos = convert(pressKey.position, to: superview)
            var location = PopKeyView.PopKeyViewLocation.center
            var popKeyPos:CGPoint!
            if pressKey.position.minX < 10{
                popKeyPos = CGPoint(x: pos.midX + 19 * KBScale, y: pos.maxY)
                location = .left
            } else if pressKey.position.maxX > kSCREEN_WIDTH - 10{
                popKeyPos = CGPoint(x: pos.midX - 19 * KBScale, y: pos.maxY)
                location = .right
            } else {
                popKeyPos = CGPoint(x: pos.midX, y: pos.maxY)
            }
            fullKeyboardView.popKeyView.setKey(key: pressKey.text, location: location,popImage: pressKey.popViewImage)
//            fullKeyboardView.popKeyView.bottomCenter = popKeyPos
            fullKeyboardView.popKeyView.isHidden = false
        }
        
    }

    //添加按键效果
    func addPressEffect(fillColor:UIColor? = nil){
        guard let key = pressedKey else {return}
        if key.keyType.isReturnKey &&  !key.isEnable{
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if !key.keyType.isNormal || (superview as! FullKeyboardView).isGestured{
            if key.keyType == .del{
                key.imgLayer?.contents = UIImage.themeImg("icon_key_delete_press").cgImage
            }
            if key.keyType.isReturnKey || key.keyType == .backKeyboard{
                key.keyLayer?.fillColor = kColor3a9a52.cgColor
            } else if key.keyType.isSwitch || key.keyType == .del{
                key.keyLayer?.fillColor = (UIColor.white | UIColor(hexString: "696b70")!).cgColor
            } else {
                key.keyLayer?.fillColor = (fillColor ?? cKeyBgPressColor).cgColor
            }
        }
        CATransaction.commit()
    }
    
    
    
    func removePressEffect(){
        guard let key = pressedKey else {return}
        if key.keyType.isReturnKey &&  !key.isEnable{
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if key.keyType == .del{
            key.imgLayer?.contents = UIImage.themeImg("icon_key_delete").cgImage
        }
        key.keyLayer?.fillColor = key.fillColor.cgColor
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

