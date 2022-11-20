//
//  NineKeyboardView+Touch.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/11/20.
//

import Foundation
extension NineKeyboardView{
    @objc func panGes(ges: UIPanGestureRecognizer) {
        let point = ges.location(in: self)
        switch ges.state {
        case .began:
            panPoint = point
            panPosition = point
            isGesture = true
        case .ended:
            if pressedKey != nil, panPoint != nil {
                let distance = panPoint!.y - point.y
                if abs(distance) < 10, abs(panPoint!.x - point.x) < 10 { // 如果触发了pan，这时可能这个距离特别短，那么可不可以认为是一次按键呢？对搜狗的试验可以认为是一次按键,那么这个距离设定为多少好呢？试试10看看效果
                    keyPress(key: pressedKey!)
                }
                if distance > 30, point.x > pressedKey!.position.minX - distance * 0.6, point.x < pressedKey!.position.maxX + distance * 0.6 {
                    var key = pressedKey!
                    key.clickType = .tip
                    key.keyType = .normal(.character)
                    keyPress(key: key)
                    Shake.keyShake()
                }
            }
            removeEffect()
            pressedKey = nil
            panPoint = nil
            isGesture = false
            panPosition = nil
        case .cancelled, .failed:
            isGesture = false
            panPoint = nil
            removeEffect()
            pressedKey = nil
            panPosition = nil
            removeEffect()
        case .changed:
            if panPosition == nil {
                panPosition = point
            }
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
            } else {
                symbles.append(contentsOf: Array(pressedKey!.text).map { c in
                    SymbleInfo(text: String(c), angle: nil)
                })
                symbles.append(SymbleInfo(text: pressedKey!.tip, angle: nil))
                symbles.append(contentsOf: Array(pressedKey!.text).map { c in
                    SymbleInfo(text: String(c).lowercased(), angle: nil)
                })
            }
            let width = CGFloat(symbles.count * 36 + 8)
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
        
        guard let point = touches.first?.location(in: self) else  { return}
        if pressedKey != nil {
            keyPress(key: pressedKey!)
            removeEffect()
        }
        var row = 0
        for i in 0..<rowRanges.count{
            if point.y < rowRanges[0]{
                break
            } else  if point.y < rowRanges[i+1] && point.y > rowRanges[i]{
                row = i + 1
                break
            }
        }
        var col = 0
        for j in 0..<ranges[row].count{
            if point.x < ranges[row][0]{
                break
            } else if point.x > ranges[row][j] && point.x < ranges[row][j + 1]{
                col = j + 1
                break
            }
        }
        pressedKey = keys[row][col]
        addLayerEffect()
        Shake.keyShake()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        if isGesture {
            return
        }
        removeEffect()
        if let k = pressedKey {
            keyPress(key: k)
        }
        print("touchesEnded 移除layer")
        pressedKey = nil
    }
    
    // 注意，如果不小心按快了，手指趋向于一个轻扫的手势，这个时侯会触发touchesCancelled，再可能会触发pan手势。导致丢字。但是也不一定都会触发pan手势。需要加上判断
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        if isGesture {
            return
        }
        removeEffect()
        if let k = pressedKey {
            keyPress(key: k)
        }
        print("touchesCancelled 移除layer")
        pressedKey = nil
    }
    
    func addLayerEffect() {
        guard let key = pressedKey else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if key.keyType == .returnKey(.disable) {
            return
        }
        if key.keyType.isReturnKey {
            key.keyLayer?.fillColor = Colors.color3A9A52.cgColor
        } else if key.keyType == .space || key.keyType.isNormal || key.keyType == .separate {
            key.keyLayer?.fillColor = cKeyBgPressColor.cgColor
        } else {
            key.keyLayer?.fillColor = (UIColor.white | Colors.color696B70).cgColor
        }
        if key.keyType == .del {
            pressedKey?.imgLayer?.contents = UIImage.themeImg("icon_key_delete_press").cgImage
        }
        CATransaction.commit()
    }
    
    func removeEffect() {
        guard let key = pressedKey else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if key.keyType == .del {
            pressedKey?.imgLayer?.contents = UIImage.themeImg("icon_key_delete").cgImage
        }
        key.keyLayer?.fillColor = key.fillColor.cgColor
        CATransaction.commit()
    }
}
