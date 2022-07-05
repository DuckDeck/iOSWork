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
    var pressLayer:CAShapeLayer?
    var tmpOffset : CGFloat = 0
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
//        longPress.delaysTouchesBegan = false
//        longPress.delaysTouchesEnded = false
//        longPress.cancelsTouchesInView = false
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
            let img = UIImage.yh_imageNamed(tmpKey.image)!
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width, h: img.size.height)
            imgLayer.contents = img.cgImage
            keys[index].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        
        if !tmpKey.text.isEmpty{
            let lbl = UILabel()
            lbl.text = tmpKey.text
            lbl.font = UIFont(name: "PingFangSC-Regular", size: 18)
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 18))
            let txtLayer = CATextLayer()
            txtLayer.frame = tmpKey.position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.foregroundColor = tmpKey.textColor.cgColor
            txtLayer.string = tmpKey.text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
            txtLayer.fontSize = 18
            keys[index].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
    }
    
    func updateKeys(newKeys:[KeyInfo]){
        self.keys = newKeys
        layer.sublayers?.forEach{$0.removeFromSuperlayer()}
        for  item in keys.enumerated(){
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
            shadowLayer.fillColor = kColor898a8d.cgColor
            shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
            layer.insertSublayer(shadowLayer, below: keyLayer)

            //imageLayer
            
            if !item.element.image.isEmpty{
                let img = UIImage.yh_imageNamed(item.element.image)!
                let imgLayer = CALayer()
                imgLayer.frame = item.element.position.centerRect(w: img.size.width, h: img.size.height)
                imgLayer.contents = img.cgImage
                keys[item.offset].imgLayer = imgLayer
                layer.addSublayer(imgLayer)
            }
            
            if !item.element.text.isEmpty{
                let lbl = UILabel()
                lbl.text = item.element.text
                lbl.font = UIFont(name: "PingFangSC-Regular", size: item.element.textSize ?? 22)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                let txtRect = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
                if item.element.tip.isEmpty{
                    txtLayer.frame = txtRect.offsetBy(dx: item.element.text.characherOffset, dy: 0)
                } else{
                    txtLayer.frame = txtRect.offsetBy(dx: item.element.text.characherOffset, dy: 4)
                }
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = item.element.textSize ?? 22
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
                
                if !item.element.tip.isEmpty{
                    let lbl = UILabel()
                    lbl.text = item.element.tip
                    lbl.font = UIFont(name: "PingFangSC-Regular", size: 10)
                    let tipSize = lbl.sizeThatFits(CGSize(width: 20, height: 12))
                    let tipLayer = CATextLayer()
                    tipLayer.frame = item.element.position.centerRect(w: tipSize.width, h: tipSize.height).offsetBy(dx: item.element.text.characherOffset - 4, dy: -13)
                    tipLayer.foregroundColor = item.element.tip == "。" ? kColor222222.cgColor  : kColorbbbbbb.cgColor
                    tipLayer.string = item.element.tip
                    tipLayer.contentsScale = UIScreen.main.scale
                    tipLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                    tipLayer.fontSize = 10
                    layer.addSublayer(tipLayer)
                }
            }
        }
    }
    
    @objc func panGes(ges:UIPanGestureRecognizer){
        let point = ges.location(in: self)
        switch ges.state{
        case .began:
            panPoint = point
            (superview as? FullKeyboardView)?.isGestured = true
        case .ended:
            //方向还没有处理
            if pressedKey != nil && pressedKey!.keyType.isNormal && panPoint != nil{
                let pressKey = pressedKey!
                let distance = panPoint!.y - point.y
                if distance > 30 && point.x > pressKey.position.minX - distance * 0.6 && point.x < pressKey.position.maxX + distance * 0.6{
                    if let keyboard = superview as? FullKeyboardView{
                        var key = pressKey
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
            (superview as? FullKeyboardView)?.isGestured = false
        case .cancelled,.failed:
            fullKeyboardView.popKeyView.isHidden = true
            removePressEffect()
            panPoint = nil
            pressedKey = nil
            (superview as? FullKeyboardView)?.isGestured = false
        default:
            break
        }
    }
    
    @objc func longPressGes(ges:UILongPressGestureRecognizer){
        let point = ges.location(in: self)

        switch ges.state{
        case .began:
            
            (superview as? FullKeyboardView)?.isGestured = true
            if (superview as? FullKeyboardView)?.popChooseView != nil &&  !(superview as! FullKeyboardView).popChooseView!.isHidden{
                return
            }
            if  pressedKey != nil && pressedKey!.keyType.isNormal{
                if pressedKey!.keyType == .del{
                    Shake.keyShake()
                    (superview as! FullKeyboardView).keyLongPress(key: pressedKey!, state: ges.state)
                }
                return
            }
            if pressedKey == nil{
                return
            }
            if !pressedKey!.text.first!.isLetter{
                if !pressedKey!.tip.isEmpty{
                    let key = pressedKey!
                    Shake.keyShake()
                    fullKeyboardView.popKeyView.lblKey.text = key.tip
                }
                return
            }
            for item in positions.enumerated(){
                if item.element.large().contains(point){
                    let key = keys[item.offset]
                    let txt = "\(key.text.uppercased())\(key.tip)\(key.text.lowercased())"
                    let width : CGFloat = CGFloat(txt.count * 30 + 8)
                    let pos = convert(key.position, to: superview)
                    var x = pos.midX - width / 2.0
                    if x - 5 <= 0{
                        x = 5
                    }
                    if x + width + 5 >= kSCREEN_WIDTH{
                        x = kSCREEN_WIDTH - width - 5
                    }
                    let chooseView = PopKeyChooseView(frame: CGRect(x: x, y: pos.minY - 58, width: width, height: 52), keys: txt)
                    if let v = superview as? FullKeyboardView{
                        v.popChooseView = chooseView
                        v.addSubview(chooseView)
                        fullKeyboardView.popKeyView.isHidden = true
                    }
                    previousPoint = point
                    addPressEffect(key: key)
                    Shake.keyShake()
                }
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
                let str = v.keys.substring(from: v.selectIndex, length: 1)
                var key = KeyInfo()
                key.text = String(str)
                key.keyType = .normal(.character)
                (superview as! FullKeyboardView).keyPress(key: key)
                (superview as! FullKeyboardView).popChooseView?.isHidden = true
                (superview as! FullKeyboardView).popChooseView = nil
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
            fullKeyboardView.popKeyView.isHidden = true
            (superview as? FullKeyboardView)?.isGestured = false
            removePressEffect()
            pressedKey = nil
        default:
            break
        }
       
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("gestureRecognizer，开始接收到触摸事件,touch phase 是\(touch.phase)")
        if touch.phase == .began{
            let point = touch.location(in: self)
            if point.x > tmpOffset && point.x < kSCREEN_WIDTH - tmpOffset{
                return true
            }
            if (superview as! FullKeyboardView).isGestured{
                print("gestureRecognizer，有其他手势需要返回")
                return true
            }
            for item in positions.enumerated(){
                if item.element.large().contains(point){
                    if pressedKey != nil{
                        (superview as? FullKeyboardView)?.keyPress(key: pressedKey!)
                    }
                    pressedKey = keys[item.offset]
                    print("识别到\(keys[item.offset].text)")
                    addPopKeyView(pressKey: &keys[item.offset])
                    addPressEffect()
                    break
                }
            }

        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan,开始接收到触摸事件")
        guard let t = touches.first else {return}
        if t.phase == .began{
            let point = t.location(in: self)
            if point.x <= tmpOffset || point.x >= kSCREEN_WIDTH - tmpOffset{
                return
            }
            if (superview as! FullKeyboardView).isGestured{
                return
            }
            for item in positions.enumerated(){
                if item.element.large().contains(point){
                    if pressedKey != nil{
                        (superview as? FullKeyboardView)?.keyPress(key: pressedKey!)
                    }
                    pressedKey = keys[item.offset]
                    print("识别到\(keys[item.offset].text)")
                    addPopKeyView(pressKey: &keys[item.offset])
                    addPressEffect()
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (superview as! FullKeyboardView).isGestured{
            return
        }
        if pressedKey != nil{
            if let keyboard = superview as? FullKeyboardView{
                self.fullKeyboardView.popKeyView.isHidden = true
                keyboard.keyPress(key: pressedKey!)
                Shake.keyShake()
            }
            removePressEffect()
            pressedKey = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
   
        if (superview as! FullKeyboardView).isGestured{
            return
        }
        if pressedKey != nil{
            fullKeyboardView.popKeyView.isHidden = true
            removePressEffect()
            pressedKey = nil
        }
    }
    
    
    var positions : [CGRect]{
        return keys.map { k in
            return k.position
        }
    }
    
    
    func addPopKeyView(pressKey:inout KeyInfo){
        if pressKey.keyType.isNormal{
            let pos = convert(pressKey.position, to: superview)
            var location = PopKeyView.PopKeyViewLocation.center
            var popKeyPos:CGPoint!
            if pressKey.position.minX < 10{
                popKeyPos = CGPoint(x: pos.midX + 18, y: pos.minY - 8)
                location = .left
            } else if pressKey.position.maxX > kSCREEN_WIDTH - 10{
                popKeyPos = CGPoint(x: pos.midX - 18, y: pos.minY - 8)
                location = .right
            } else {
                popKeyPos = CGPoint(x: pos.midX, y: pos.minY - 8)
            }
            fullKeyboardView.popKeyView.setKey(key: pressKey.text, location: location,popImage: pressKey.popViewImage)
            fullKeyboardView.popKeyView.center = popKeyPos
            fullKeyboardView.popKeyView.isHidden = false
        }
        
    }

    //添加按键效果
    func addPressEffect(){
        if pressedKey == nil{
            return
        }
        if pressedKey!.keyType.isReturnKey &&  !pressedKey!.isEnable{
            return
        }
        if !pressedKey!.keyType.isNormal || (superview as! FullKeyboardView).isGestured{
            if pressedKey!.keyType == .del{
                pressedKey!.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_black").cgImage
            }
            if pressLayer == nil{
                pressLayer = CAShapeLayer()
            } else {
                pressLayer?.removeFromSuperlayer()
            }
            if pressedKey!.keyType == .returnKey(.usable){
                pressLayer?.fillColor = kColor3a9a52.cgColor
            } else {
                pressLayer?.fillColor = kColora6a6a6.cgColor
            }
            let path = UIBezierPath(roundedRect: pressedKey!.position, cornerRadius: 5)
            pressLayer?.path = path.cgPath
            layer.insertSublayer(pressLayer!, above: pressedKey!.keyLayer)
        }
    }
    
    func addPressEffect(key:KeyInfo){
        if pressLayer == nil{
            pressLayer = CAShapeLayer()
        } else {
            pressLayer?.removeFromSuperlayer()
        }
        pressLayer?.fillColor = kColora6a6a6.cgColor
        let path = UIBezierPath(roundedRect: key.position, cornerRadius: 5)
        pressLayer?.path = path.cgPath
        layer.insertSublayer(pressLayer!, above: key.keyLayer)
    }
    
    func removePressEffect(){
        if pressedKey == nil{
            return
        }
        if pressedKey!.keyType == .del{
            pressedKey!.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_white").cgImage
        }
        pressLayer?.removeFromSuperlayer()
        pressLayer = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
