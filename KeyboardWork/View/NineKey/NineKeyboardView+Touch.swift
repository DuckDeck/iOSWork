//
//  NineKeyboardView+KeyInfo.swift
//  WGKeyboard
//
//  Created by Stan Hu on 2022/11/16.
//  Copyright © 2022 WeAblum. All rights reserved.
//

import UIKit
extension NineKeyboardView{
    
    @objc func longPressGes(ges: UILongPressGestureRecognizer) {
        let point = ges.location(in: self)
        
        switch ges.state {
        case .began:
            isGesture = true
            if pressedKey == nil{
                return
            }
            if pressedKey!.keyType == .del{
                keyLongPress(key: pressedKey!, state: ges.state)
                Shake.keyShake()
                return
            }
            if pressedKey!.tip.isEmpty{
                return
            }
            var symbles = [SymbleInfo]()
            if pressedKey!.tip == "1" {
                symbles.append(SymbleInfo(text: "@", angle: nil))
                symbles.append(SymbleInfo(text: ".", angle: nil))
                symbles.append(SymbleInfo(text: "/", angle: nil))
                symbles.append(SymbleInfo(text: "1", angle: nil))
                symbles.append(SymbleInfo(text: ":", angle: nil))
                symbles.append(SymbleInfo(text: "_", angle: nil))
                symbles.append(SymbleInfo(text: "-", angle: nil))
            } else if  pressedKey!.tip != "0" {
                symbles.append(contentsOf: Array(pressedKey!.text).map { c in
                    SymbleInfo(text: String(c), angle: nil)
                })
                symbles.append(SymbleInfo(text: pressedKey!.tip, angle: nil))
                symbles.append(contentsOf: Array(pressedKey!.text).map { c in
                    SymbleInfo(text: String(c).lowercased(), angle: nil)
                })
            }
            if symbles.count <= 0{
                return
            }
            let width = CGFloat(symbles.count * (kSCREEN_WIDTH <= 320 ? 30 : 36) + 8)
            let pos = convert(pressedKey!.position, to: superview)
            var x = pos.midX - width / 2.0
            if x - 10 <= 0 {
                x = 10
            }
            if x + width + 10 >= kSCREEN_WIDTH {
                x = kSCREEN_WIDTH - width - 10
            }
            let popHeight = (150 * KBScale - 10) / 3.0
            let chooseView = PopKeyChooseView(frame: CGRect(x: x, y: pos.minY - popHeight - 7, width: width, height: popHeight + 4), keys: symbles)
            popChooseView = chooseView
            addSubview(chooseView)
            previousPoint = point
            Shake.keyShake()
                
        case .changed:
            if previousPoint != nil {
                if point.x - previousPoint!.x > 20 {
                    previousPoint = point
                    popChooseView?.selectIndex += 1
                } else if point.x - previousPoint!.x < -20 {
                    previousPoint = point
                    popChooseView?.selectIndex -= 1
                }
            }
            print("changed\(ges.location(in: self))")
        case .ended, .cancelled:
            isGesture = false
            if pressedKey != nil,pressedKey!.keyType == .del{
                keyLongPress(key: pressedKey!, state: ges.state)
            }
            previousPoint = nil
            if let v = popChooseView {
                var key = KeyInfo()
                key.text = v.selectedText
                key.keyType = .normal(.character)
                keyPress(key: key)
                popChooseView?.removeFromSuperview()
                popChooseView = nil
            }
            removeEffect()
            pressedKey = nil
            
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        if isGesture {
            return
        }
        Shake.keyShake()
        if pressedKey != nil {
            keyPress(key: pressedKey!)
            removeEffect()
            pressedKey = nil
        }
        var tmpKeys = [KeyInfo]()
        for item in touches{
            let point = item.location(in: self)
            var row = 0
            for i in 0..<rowRanges.count{
                if point.y <= rowRanges[0]{
                    break
                } else  if point.y <= rowRanges[i+1] && point.y > rowRanges[i]{
                    row = i + 1
                    break
                }
            }
            var col = 0
            if row >=  0  && row <=  2 && point.x <= 3 * unitWidth18{
                return
            }
            for j in 0..<ranges[row].count{
                if point.x < ranges[row][0]{
                    break
                } else if point.x > ranges[row][j] && point.x <= ranges[row][j + 1]{
                    col = j + 1
                    break
                }
            }
            if globalCache.keys.contains("showTrace"){
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let l = CALayer()
                let img =  UIImage(color: UIColor.red,size: CGSize(width: 2, height: 2))
                l.contents = img?.cgImage
                l.frame = CGRect(origin: CGPoint(x: point.x - 1, y: point.y - 1), size: CGSize(width: 2, height: 2))
                superview?.layer.addSublayer(l)
                touchLayers.append(l)
                CATransaction.commit()
            }
            
            if  keys[row][col].keyType == .del{
                pressedKey = keys[row][col]
                pressedKey?.location = (row,col)
                keyPress(key: pressedKey!)
            } else {
                var tmp = keys[row][col]
                tmp.location = (row,col)
                tmpKeys.append(tmp)
            }
            panPoint = point
        }
        while tmpKeys.count > 1{
            keyPress(key: tmpKeys.removeFirst())
        }
        if pressedKey == nil && tmpKeys.count > 0{
            pressedKey = tmpKeys.last!
        }
        addLayerEffect()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGesture || panPoint == nil {
            return
        }
        guard let t = touches.first else { return }
        let point = t.location(in: self)
        //首先判定是不是向上
        let yDistance = panPoint!.y - point.y
        if pressedKey != nil, yDistance > 40, point.x > pressedKey!.position.minX - yDistance * 0.6, point.x < pressedKey!.position.maxX + yDistance * 0.6 { //判定向上
            if !pressedKey!.tip.isEmpty{
                var key = pressedKey!
                key.clickType = .tip
                key.keyType = .normal(.character)
                Shake.keyShake()
                keyPress(key: key)
            }
            removeEffect()
            pressedKey = nil
            return
        }
        let xDistance = abs(panPoint!.x - point.x)
        if xDistance > 45{
           isSwipe = true
        }
        //判定有没有触发左右滑动手势
        if isSwipe && !(globalHeader?.isHavePinYin ?? false){
            removeEffect()
            if panPosition == nil{
                panPosition = point
            }
            if point.x - panPosition!.x > 20 {
                panPosition = point
                keyboardVC?.moveCursor(direction: true)
            } else if point.x - panPosition!.x < -20 {
                panPosition = point
                keyboardVC?.moveCursor(direction: false)
            }
            pressedKey = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        isSwipe = false
        if isGesture {
            return
        }
        removeEffect()
        if pressedKey != nil{
            if pressedKey!.keyType != .del && pressedKey!.keyType != .switchInput{
                keyPress(key: pressedKey!)
                if Int(pressedKey!.text) != nil && pressedKey!.keyType.isNormal{
                }
            }
        }
        print("touchesEnded 移除layer")
        pressedKey = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwipe = false
    }
    
    func addLayerEffect() {
        guard let key = pressedKey else {return}
        if key.keyType == .returnKey(.disable) {
            return
        }
        CATransaction.begin()                           //警告！！！！！！！调用 CATransaction.begin() 这个方法后必须要在layer改变的生命周期内调用CATransaction.commit() 不然会导致所有的layer 改变都不起效果，如果在里面return了，那么会所有view更新或者layer更新失效，非常莫名其妙的问题！！！！！！！！！！！！！
        CATransaction.setDisableActions(true)
        if key.fillColor == cKeyBgColor2 {
            key.keyLayer?.fillColor = (UIColor.white | Colors.color696B70).cgColor
        } else if key.fillColor == .green{
            key.keyLayer?.fillColor = Colors.color92DAA4.cgColor
        }else {
            key.keyLayer?.fillColor = cKeyBgPressColor.cgColor
        }
        if key.keyType == .del {
            pressedKey?.textLayer?.string = "\u{232C}"
        }
        CATransaction.commit()
    }
    
    func removeEffect() {
        guard let key = pressedKey else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if key.keyType == .del {
            pressedKey?.textLayer?.string = "\u{232B}"
        }
        key.keyLayer?.fillColor = key.fillColor.cgColor
        CATransaction.commit()
    }
}
