//
//  NumberKeyboardView+Touch.swift
//  WGKeyboard
//
//  Created by Stan Hu on 2022/11/16.
//  Copyright © 2022 WeAblum. All rights reserved.
//

import UIKit
extension NumberKeyboardView {
    
    @objc func longPressGes(ges: UILongPressGestureRecognizer) {
        switch ges.state {
        case .began:
            isGesture = true
            if pressedKey == nil {
                return
            }
            if pressedKey!.keyType == .del {
                keyLongPress(key: pressedKey!, state: ges.state)
                Shake.keyShake()
            } else if pressedKey!.keyType.isReturnKey && pressedKey!.text == "发送" {
                Shake.keyShake()
                var k = KeyInfo()
                k.keyType = .newLine
                keyPress(key: k)
            }

        case .ended, .cancelled:
            if pressedKey != nil {
                if  pressedKey!.keyType == .del{
                    keyLongPress(key: pressedKey!, state: ges.state)
                } else {
                    keyPress(key: pressedKey!)
                }
            }
            isGesture = false
            removeEffect()
            pressedKey = nil
        case .failed:
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
        
        if pressedKey != nil {
            keyPress(key: pressedKey!)
            removeEffect()
            pressedKey = nil
        }
        Shake.keyShake()
        var tmpKeys = [KeyInfo]()
        for item in touches{
            let point = item.location(in: self)
            var row = 0
            for i in 0..<rowRanges.count {
                if point.y <= rowRanges[0] {
                    break
                } else if point.y <= rowRanges[i + 1], point.y > rowRanges[i] {
                    row = i + 1
                    break
                }
            }
            if row >=  0  && row <=  2 && point.x <= 3 * unitWidth18{
                return
            }
            var col = 0
            for j in 0..<ranges[row].count {
                if point.x < ranges[row][0] {
                    break
                } else if point.x > ranges[row][j], point.x <= ranges[row][j + 1] {
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
        if isGesture {
            return
        }
        guard let t = touches.first else { return }
        let point = t.location(in: self)
        let xDistance = abs(panPoint!.x - point.x)
        if xDistance > 45{
            isSwipe = true
        }
        //判定有没有触发左右滑动手势,数字键没有拼音
        if isSwipe{
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
            if pressedKey!.keyType != .del{
                keyPress(key: pressedKey!)
            }
        }
        print("touchesEnded 移除layer")
        pressedKey = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwipe = false
    }
    
    func addLayerEffect() { //数字键盘不方便判断是不是点了最右边的那排，那排是深色的
        guard let key = pressedKey else {return}
        if key.keyType == .returnKey(.disable) {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if key.fillColor == cKeyBgColor2 {
            key.keyLayer?.fillColor = (UIColor.white | Colors.color696B70).cgColor
        } else if key.fillColor == Colors.color49C167{
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
