//
//  FullKeyboardView+Touch.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/11/20.
//

import Foundation
extension FullKeyboardView: UIGestureRecognizerDelegate {
    @objc func panGes(ges: UIPanGestureRecognizer) {
        print("panGes\(ges.state)")
        let point = ges.location(in: self)
        switch ges.state {
        case .began:
            panPoint = point
            isGestured = true
            panPosition = point
        case .ended:
            // 方向还没有处理
            if pressedKey != nil, pressedKey!.keyType.isNormal || pressedKey!.keyType == .del, panPoint != nil {
                let distance = panPoint!.y - point.y
                if abs(distance) < 10, abs(panPoint!.x - point.x) < 10 { // 如果触发了pan，这时可能这个距离特别短，那么可不可以认为是一次按键呢？对搜狗的试验可以认为是一次按键,那么这个距离设定为多少好呢？试试10看看效果
                    if let keyboard = superview as? Keyboard {
                        keyboard.keyPress(key: pressedKey!)
                    }
                }
                if distance > 30, point.x > pressedKey!.position.minX - distance * 0.6, point.x < pressedKey!.position.maxX + distance * 0.6 {
                    var key = pressedKey!
                    key.clickType = .tip
                    key.keyType = .normal(.character)
                    Shake.keyShake()
                    keyPress(key: key)
                    
                }
            }
            popKeyView.isHidden = true
            removePressEffect()
            pressedKey = nil
            panPoint = nil
            isGestured = false
            panPosition = nil
        case .cancelled, .failed:
            popKeyView.isHidden = true
            removePressEffect()
            panPoint = nil
            pressedKey = nil
            isGestured = false
            panPosition = nil
        case .changed:
            print("paning:\(point)")
            if panPosition == nil {
                panPosition = point
            }
            popKeyView.isHidden = true
            let yoffset = point.y - panPoint!.y
            let xOffset = point.x - panPoint!.x
            if point.x - panPosition!.x > 20, abs(yoffset / xOffset) < 0.8 {
                panPosition = point
                keyboardVC?.moveCursor(direction: true)
            } else if point.x - panPosition!.x < -20, abs(yoffset / xOffset) < 0.8 {
                panPosition = point
                keyboardVC?.moveCursor(direction: false)
            }
        default:
            break
        }
    }
      
    @objc func longPressGes(ges: UILongPressGestureRecognizer) {
        let point = ges.location(in: self)

        switch ges.state {
        case .began:
            isGestured = true
            if popChooseView != nil, !popChooseView!.isHidden {
                return
            }
            if pressedKey == nil {
                return
            }
            if pressedKey!.keyType.isReturnKey && pressedKey!.text == "发送" {
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
            
            // 分支说明，对于符号按键，如果存在有tip的情况，长按会优化输出tip，目前只有逗号和句号这一个按键，其他符号按键都没有tip
            if !pressedKey!.text.isEmpty, !pressedKey!.text.first!.isLetter, !pressedKey!.tip.isEmpty {
                let key = pressedKey!
                Shake.keyShake()
                popKeyView.lblKey.text = key.tip
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
                let width = CGFloat(txtCount * 36 + 8)
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
                popKeyView.isHidden = true
                previousPoint = point
                addPressEffect(fillColor: UIColor("a2a5ad") | UIColor("414245"))
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
                popKeyView.isHidden = true
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
                  
                popKeyView.isHidden = true
                removePressEffect()
                pressedKey = nil
            }
            isGestured = false
        case .failed:
            popChooseView?.removeFromSuperview()
            popChooseView = nil
            popKeyView.isHidden = true
            isGestured = false
            removePressEffect()
            pressedKey = nil
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if isGestured {
            return
        }
        guard let t = touches.first else { return }
        if t.phase == .began {
            let point = t.location(in: self)
            if pressedKey != nil { // 解释： 当用户几乎同时按下两个按键时，第二个按键的气泡会顶掉第一个，这时上字顺序是用户先松手的那个按键，这样会导致上字顺序错误，现在修改成当第二个气泡顶掉第一个时，也同时把第一个上字。这样肯定不会出现上字顺序错误和情况了
                keyPress(key: pressedKey!)
                pressedKey = nil
            }
            Shake.keyShake()
            let index = Int((point.y - keyVerGap / 2) / (keyHeight +  (keyTopMargin + keyVerGap) / 2))
            let range = ranges[index]
            for i in 0..<range.count {
                if point.x <= range[0] {
                    pressedKey = keys[index][0]
                    addPopKeyView(pressKey: &keys[index][0])
                    break
                } else if point.x > range[i], point.x <= range[i + 1] {
                    pressedKey = keys[index][i + 1]
                    addPopKeyView(pressKey: &keys[index][i + 1])
                    break
                }
            }
         
            addPressEffect()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGestured {
            return
        }
        popKeyView.isHidden = true
        if pressedKey != nil {
            keyPress(key: pressedKey!)
            removePressEffect()
            pressedKey = nil
          
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGestured{
            return
        }
        popKeyView.isHidden = true
        if pressedKey != nil{
            pressedKey = nil
           
        }
    }
    
    func addPopKeyView(pressKey: inout KeyInfo) {
        if pressKey.keyType.isNormal {
            let pos = convert(pressKey.position, to: superview)
            var location = PopKeyView.PopKeyViewLocation.center
            var popKeyPos: CGPoint!
            if pressKey.position.minX < 10 {
                popKeyPos = CGPoint(x: pos.midX + 19 * KBScale, y: pos.maxY)
                location = .left
            } else if pressKey.position.maxX > kSCREEN_WIDTH - 10 {
                popKeyPos = CGPoint(x: pos.midX - 19 * KBScale, y: pos.maxY)
                location = .right
            } else {
                popKeyPos = CGPoint(x: pos.midX, y: pos.maxY)
            }
            popKeyView.setKey(key: pressKey.text, location: location, popImage: pressKey.popViewImage)
            popKeyView.bottomCenter = popKeyPos
            popKeyView.isHidden = false
        }
    }

    // 添加按键效果
    func addPressEffect(fillColor: UIColor? = nil) {
        guard let key = pressedKey else { return }
        if key.keyType.isReturnKey && !key.isEnable {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
           
        if !key.keyType.isNormal || isGestured {
            if key.keyType == .del {
                key.imgLayer?.contents = UIImage.themeImg("icon_key_delete_press").cgImage
            }
            if key.keyType.isReturnKey || key.keyType == .backKeyboard {
                key.keyLayer?.fillColor = Colors.color3A9A52.cgColor
            } else if key.keyType.isSwitch || key.keyType == .del || key.keyType.isShift {
                key.keyLayer?.fillColor = (UIColor.white | Colors.color696B70).cgColor
            } else {
                key.keyLayer?.fillColor = (fillColor ?? cKeyBgPressColor).cgColor
            }
        }
        CATransaction.commit()
    }
       
    func removePressEffect() {
        guard let key = pressedKey else { return }
        if key.keyType.isReturnKey, !key.isEnable {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if key.keyType == .del {
            key.imgLayer?.contents = UIImage.themeImg("icon_key_delete").cgImage
        }
        key.keyLayer?.fillColor = key.fillColor.cgColor
        CATransaction.commit()
    }
}
