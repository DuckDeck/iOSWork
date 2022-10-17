//
//  NumKeysView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit

class NumKeysView:UIView,UIGestureRecognizerDelegate{
    var keys:[KeyInfo]!
    var pressedKey:KeyInfo?
    var pressLayer:CAShapeLayer?
    var isShowShadow = true
    var isCalculatorReady = false
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(ges:)))
        isUserInteractionEnabled = true
        pan.delegate = self
        addGestureRecognizer(pan)
    }
    
      required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    func updateKeys(newKeys:[KeyInfo]){
        layer.sublayers?.forEach{$0.removeFromSuperlayer()}
        self.keys = newKeys
        for  item in keys.enumerated(){
            
            //key layer
            let keyLayer = CAShapeLayer()
            keyLayer.fillColor = item.element.fillColor.cgColor
            let path = UIBezierPath(roundedRect: item.element.position, cornerRadius: 5)
            keyLayer.path = path.cgPath
            keys[item.offset].keyLayer = keyLayer
            layer.addSublayer(keyLayer)
            
            //shadowlayer
            if isShowShadow{
                let shadowLayer = CAShapeLayer()
                let shadowRect = CGRect(x: item.element.position.origin.x, y: item.element.position.maxY - 10, width: item.element.position.width, height: 11)
                shadowLayer.fillColor = kColor898a8d.cgColor
                shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
                layer.insertSublayer(shadowLayer, below: keyLayer)
            }
        

            
            if !item.element.text.isEmpty{
                let lbl = UILabel()
                lbl.text = item.element.text
                lbl.font = UIFont(name: "PingFangSC-Regular", size: item.element.textSize ?? 18)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                txtLayer.frame = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = item.element.textSize ?? 18
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
            }
        }
    }
    
    @objc func panGes(ges:UIPanGestureRecognizer){
      
        switch ges.state{
        case .cancelled,.failed,.ended:
            if pressedKey != nil {
                pressLayer?.removeFromSuperlayer()
                pressLayer = nil
                pressedKey = nil
            }
        default:
            break
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.phase == .began{
         let point = touch.location(in: self)
            for item in positions.enumerated(){
                if item.element.large().contains(point){
                    pressedKey = keys[item.offset]
                    if pressLayer == nil{
                        pressLayer = CAShapeLayer()
                    } else {
                        pressLayer?.removeFromSuperlayer()
                    }
                    pressLayer?.fillColor = kColora9abb0.cgColor
                    let path = UIBezierPath(roundedRect: pressedKey!.position, cornerRadius: 5)
                    pressLayer?.path = path.cgPath
                    layer.insertSublayer(pressLayer!, above: pressedKey!.keyLayer)
                    break
                }
            }
        }
        else if touch.phase == .ended || touch.phase == .cancelled{
            if pressedKey != nil {
                pressLayer?.removeFromSuperlayer()
                pressLayer = nil
                pressedKey = nil
            }
        }
        return true
    }
    
    

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pressedKey != nil{
            if let keyboard = superview as? Keyboard{
                keyboard.keyPress(key: pressedKey!)
            }
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        if pressedKey != nil {
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey = nil
        }
    }
    
    
    var positions : [CGRect]{
        return keys.map { k in
            return k.position
        }
    }
}
