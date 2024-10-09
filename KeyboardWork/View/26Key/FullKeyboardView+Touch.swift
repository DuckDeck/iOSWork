//
//  FullKeyboardView+FillKey.swift
//  WGKeyboard
//
//  Created by Stan Hu on 2022/11/15.
//  Copyright © 2022 WeAblum. All rights reserved.
//

import Foundation
import UIKit
extension FullKeyboardView {
      @objc func longPressGes(ges: UILongPressGestureRecognizer) {
        let point = ges.location(in: self)

        switch ges.state {
        case .began:
            if popChooseView != nil, !popChooseView!.isHidden {
                return
            }
            if pressedKey == nil {
                return
            }
            isGestured = true
            if pressedKey!.keyType == .returnKey(.disable) || pressedKey!.keyType == .returnKey(.usable) {
                Shake.keyShake()
                var k = KeyInfo()
                k.keyType = .newLine
                keyPress(key: k)
                return
            }
            if !pressedKey!.keyType.isNormal && pressedKey!.keyType == .del {
                Shake.keyShake()
                keyLongPress(key: pressedKey!, state: ges.state)
                return
            }
            // 这种情况下不需要弹出多符号选择框
            if pressedKey!.tip.isEmpty, pressedKey!.tips == nil {
                return
            }
              
            if let key = pressedKey {
                var txt = [SymbleInfo]()
                if key.tips != nil {
                    txt = key.tips!
                } else if !key.tip.isEmpty {
                    txt = [SymbleInfo(text: key.text.uppercased(), angle: nil), SymbleInfo(text: key.tip, angle: nil), SymbleInfo(text: key.text.lowercased(), angle: nil)]
                }
                let txtCount = txt.count
                let width = CGFloat(txtCount * (kSCREEN_WIDTH <= 320 ? 30 : 36) + 8)
                let pos = convert(key.position, to: superview)
                var x = pos.midX - width / 2.0
                if x - 5 <= 0 {
                    x = 5
                }
                if x + width + 5 >= kSCREEN_WIDTH {
                    x = kSCREEN_WIDTH - width - 5
                }
                let chooseView = PopKeyChooseView(frame: CGRect(x: x, y: pos.minY - 55 * KBScale, width: width, height: 50 * KBScale), keys: txt, defaultIndex: key.defaultSymbleIndex ?? -1)
                popChooseView = chooseView
                addSubview(chooseView)
                popLayer.removeFromSuperlayer()
                previousPoint = point
                addPressEffect(fillColor: Colors.colorA2A5AD | Colors.color414347)
                Shake.keyShake()
            }
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
            previousPoint = nil
            if let v = popChooseView {
                var key = KeyInfo()
                key.text = v.selectedText
                key.canBack = pressedKey!.canBack
                key.keyType = .normal(.character)
                keyPress(key: key)
                popChooseView?.removeFromSuperview()
                popChooseView = nil
                popLayer.removeFromSuperlayer()
                removePressEffect()
                pressedKey = nil
            }
            if pressedKey != nil, previousPoint == nil {
                if pressedKey!.keyType == .del {
                    keyLongPress(key: pressedKey!, state: ges.state)
                } else if pressedKey!.keyType == .normal(.character) {
                    var k = pressedKey!
                    if !k.tip.isEmpty {
                        k.clickType = .tip
                    }
                    keyPress(key: k)
                }
                popLayer.removeFromSuperlayer()
                removePressEffect()
                pressedKey = nil
            }
            isGestured = false
        case .failed:
            popChooseView?.removeFromSuperview()
            popChooseView = nil
            popLayer.removeFromSuperlayer()
            isGestured = false
            removePressEffect()
            pressedKey = nil
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("触发了\(touches.count)个点")
        for item in touches{
            print("touchesBegan\(item.location(in: self))")
        }
        if isGestured {
            return
        }
        if pressedKey != nil { // 解释： 当用户几乎同时按下两个按键时，第二个按键的气泡会顶掉第一个，这时上字顺序是用户先松手的那个按键，这样会导致上字顺序错误，现在修改成当第二个气泡顶掉第一个时，也同时把第一个上字。这样肯定不会出现上字顺序错误和情况了
            keyPress(key: pressedKey!)
            popLayer.removeFromSuperlayer()
            removePressEffect()
            pressedKey = nil
        }
        Shake.keyShake()
        var tmpKeys = [KeyInfo]()
        for item in touches{
            let point = item.location(in: self)
            
            var row = 0
            var col = 0
            for i in 0..<rowRanges.count{
                if point.y <= rowRanges[0]{
                    break
                } else  if point.y <= rowRanges[i+1] && point.y > rowRanges[i]{
                    row = i + 1
                    break
                }
            }
            
            for j in 0..<ranges[row].count{
                if point.x <= ranges[row][0]{
                    break
                } else if point.x > ranges[row][j] && point.x <= ranges[row][j + 1]{
                    col = j + 1
                    break
                }
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
            panPoint = item.location(in: self)
        }
        
        while tmpKeys.count > 1{
            keyPress(key: tmpKeys.removeFirst())
        }
        if pressedKey == nil && tmpKeys.count > 0{
            pressedKey = tmpKeys.last!
        }
        addPopKeyView(pressKey: &keys[pressedKey!.location!.0][pressedKey!.location!.1])
        addPressEffect(fillColor: UIDevice.current.userInterfaceIdiom == .pad ? Colors.colorA2A5AD | Colors.color414347 : nil)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGestured || panPoint == nil {
            return
        }
        
        //判定逻辑，在头没有拼音的情况下，左右滑动超过40px ?? 算左右滑动光标，不到40px算点击该按键。有拼音的情况下，不管滑动多少距离，都算点击最开始点击的那个按键
        //上滑触发第二键值，向上滑动超过30px ?? 算触发第二键值（可以允许一定的左右偏差），不超过30px 算点击该按键，不受头部有没有拼音的影响
        guard let t = touches.first else { return }
        let point = t.location(in: self)
        //首先判定是不是向上
        let yDistance = panPoint!.y - point.y
        if pressedKey != nil, yDistance > 40, point.x > pressedKey!.position.minX - yDistance * 0.6, point.x < pressedKey!.position.maxX + yDistance * 0.6 { //判定向上
            if pressedKey!.keyType.isNormal{
                var key = pressedKey!
                key.clickType = .tip
                key.keyType = .normal(.character)
                Shake.keyShake()
                keyPress(key: key)
              
               
            }
            popLayer.removeFromSuperlayer()
            removePressEffect()
            pressedKey = nil
            return
        }
        let xDistance = abs(panPoint!.x - point.x)
        if xDistance > 45{
            isSwipe = true
        }
        //判定有没有触发左右滑动手势
        if isSwipe && !(globalHeader?.isHavePinYin ?? false){
            popLayer.removeFromSuperlayer()
            if panPosition == nil{
                panPosition = point
            }
            if point.x - panPosition!.x > 20 {
                print("触发右滑")
                panPosition = point
                keyboardVC?.moveCursor(direction: true)
            } else if point.x - panPosition!.x < -20{
                print("触发左滑")
                panPosition = point
                keyboardVC?.moveCursor(direction: false)
            }
            removePressEffect()
            pressedKey = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwipe = false
        if isGestured {
            return
        }
        popLayer.removeFromSuperlayer()
        if pressedKey == nil {
            return
        }
        if pressedKey!.keyType != .del && pressedKey!.keyType != .switchInput{
            keyPress(key: pressedKey!)
        }
        removePressEffect()
        pressedKey = nil
        panPosition = nil
       
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwipe = false
    }
    
    func addPopKeyView(pressKey: inout KeyInfo) {
        if UIDevice.current.userInterfaceIdiom == .pad{
            return
        }
        if pressKey.keyType.isNormal {
            let pos = convert(pressKey.position, to: superview)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let popViewWidth = popViewWidthRatio * pressKey.position.width
            popLayer.frame = CGRect(origin:  CGPoint(x: pos.midX - popViewWidth / 2, y: pos.maxY - popViewHeight), size: CGSize(width: popViewWidth, height: popViewHeight))
            let size = pressKey.text.getSize(font: UIFont.paleRegular(size: 36))
            let txtLayer = popLayer.sublayers!.first! as! CATextLayer
            txtLayer.font = CGFont.init("WegoKeyboard-Palios" as CFString)
            txtLayer.frame = CGRect(x: (popViewWidth - size.width) / 2, y: popViewHeight / 20, width: size.width, height: size.height)
            txtLayer.string = pressKey.text
            layer.addSublayer(popLayer)
            CATransaction.commit()
        }
    }

    // 添加按键效果
    func addPressEffect(fillColor: UIColor? = nil) {
        if pressedKey == nil
        {
            return
        }
        if pressedKey!.keyType.isReturnKey && !pressedKey!.isEnable {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
           
        if !pressedKey!.keyType.isNormal || isGestured || fillColor != nil{
            if pressedKey!.keyType == .del {
                pressedKey?.textLayer?.string = "\u{232C}"
            }
            if pressedKey!.fillColor == cKeyBgColor2 {
                pressedKey?.keyLayer?.fillColor = (UIColor.white | Colors.color696B70).cgColor
            } else if pressedKey!.fillColor == .green{
                pressedKey?.keyLayer?.fillColor = Colors.color92DAA4.cgColor
            }else {
                pressedKey?.keyLayer?.fillColor = (fillColor ?? cKeyBgPressColor).cgColor
            }
        }
        CATransaction.commit()
    }
       
    func removePressEffect() {
        if pressedKey == nil
        {
            return
        }
        if pressedKey!.keyType.isReturnKey, !pressedKey!.isEnable {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if pressedKey!.keyType == .del {
            pressedKey?.textLayer?.string = "\u{232B}"
        }
        pressedKey?.keyLayer?.fillColor = pressedKey!.fillColor.cgColor
        CATransaction.commit()
    }
}
