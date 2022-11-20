//
//  FullKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

class FullKeyboardView:Keyboard{
    
    var popChooseView:PopKeyChooseView?
    var isGestured = false
    var shiftStatus = KeyShiftType.normal
    
    var panPosition : CGPoint?
    //按键相关变量
    // 单个按键宽度
    var keyTop : CGFloat = 0            //该行按键的上边
    var keyIndent1 : CGFloat = 0        //缩进1
    var keyIndent2 : CGFloat = 0        //缩进2
    var keyWidthShift : CGFloat = 0       //shift键宽度
    var keyInnerArea : CGFloat = 0      //通常是第三排键的区域宽度，因为这几个按键宽度不一
    
    var ranges = [[CGFloat]]()
    
    var tmpLayers = [CALayer]()
    var pressedKey : KeyInfo?
    var panPoint:CGPoint?
    var previousPoint:CGPoint?
    
    // 上次点shift的时间
    var shiftClickTime : Double? = nil
    //键盘的shift返回normal状态时，返回哪个键盘
    var shiftKeyboartType : KeyboardType? = nil
    // 记录左右是否是逗号和句号
    var isComma = false
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keyboardType:KeyboardType) {
        self.init(frame: .zero)
        self.currentKeyBoardType = keyboardType
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        keyboardWidth = kSCREEN_WIDTH
        
        createLayout()
        createKeys()
        createRange()
        createBoard()
        createGesture()
        addSubview(popKeyView)
    }
   
  
    
    func createLayout(){
        if UIDevice.current.userInterfaceIdiom == .pad{
           keyWidth = (kSCREEN_WIDTH - 117.5) / 10
           keyHeight = 54
           keyTopMargin = 8
           keyHorGap = 8
           keyVerGap = 11.5
           keyIndent1 = 6
        } else {
            if UIDevice.orientation.rawValue > 2{
                keyWidth = (kSCREEN_WIDTH - 71) / 10
                keyHeight = ((kSCREEN_HEIGHT * 0.6) - 90) * 0.2
                keyTopMargin = 8
                keyHorGap = 7
                keyVerGap = 7
                keyIndent1 = 4
            } else {
                keyWidth = (kSCREEN_WIDTH - 53) / 10
                keyHeight = kSCREEN_WIDTH > 400 ? 44 : 40
                keyTopMargin = 10
                keyHorGap = 5
                keyVerGap = 10
                keyIndent1 = 4
            }
        }
        keyIndent2 = (kSCREEN_WIDTH - 9 * keyWidth - 8 * keyHorGap) / 2
        keyWidthShift = (keyWidth * 2 + keyIndent2) / 2.0
        keyInnerArea = keyWidth * 7 + 30.0
        keyTop = keyTopMargin
    }
    
    func createKeys(){
        keys.removeAll()
        switch currentKeyBoardType{
        case .chinese,.chinese26:
            setChinese26Data()
        case .symbleChiese:
            setChineseSymbleData()
        case .symbleChieseMore:
            setChineseSymbleData()
        case .english:
            setEnglish26Data()
        case .symbleEnglish:
            setEnglishSymbleData()
        case .symbleEnglishMore:
            setEnglishSybmbleMoreData()
        default:
            break
        }
    }
    
    func createRange(){
        ranges.removeAll()
        for row in keys{
            var tmp = [CGFloat]()
            for item in row.enumerated(){
                if item.offset == row.count - 1{
                    tmp.append(kSCREEN_WIDTH)
                } else {
                    tmp.append(item.element.hotArea?.maxX ?? item.element.position.maxX + 2.5)
                }
            }
            ranges.append(tmp)
        }
    }

    override func createBoard(){
        layer.sublayers?.forEach{
            if $0.delegate == nil{
                $0.removeFromSuperlayer()
            }
        }
        for  i in 0..<keys.count{
            for j in 0..<keys[i].count{
               //key layer
               let k = keys[i][j]
               let keyLayer = CAShapeLayer()
               keyLayer.fillColor = k.fillColor.cgColor
               let path = UIBezierPath(roundedRect: k.position, cornerRadius: 5)
               keyLayer.path = path.cgPath
               keys[i][j].keyLayer = keyLayer
               layer.addSublayer(keyLayer)
               //shadowlayer
               let shadowLayer = CAShapeLayer()
               let shadowRect = CGRect(x: k.position.origin.x, y: k.position.maxY - 10, width: k.position.width, height: 11)
               shadowLayer.fillColor = cKeyShadowColor.cgColor
               shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
               layer.insertSublayer(shadowLayer, below: keyLayer)
                //imageLayer
               if !k.image.isEmpty{
                   let img =  UIImage.themeImg(k.image, origin: true)
                   let imgLayer = CALayer()
                   imgLayer.frame = k.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
                   imgLayer.contents = img.cgImage
                   keys[i][j].imgLayer = imgLayer
                   layer.addSublayer(imgLayer)
               }
               
               if !k.text.isEmpty{
                   let txtSize = k.text.getSize(font: UIFont(name: "PingFangSC-Regular", size: (k.fontSize ?? 22) * KBScale)!)
                   let txtLayer = CATextLayer()
                   let txtRect = k.position.centerRect(w: txtSize.width, h: txtSize.height)
                   txtLayer.frame = txtRect.offsetBy(dx: k.text.characherOffset, dy: 0)
                   txtLayer.foregroundColor = k.textColor.cgColor
                   txtLayer.string = k.text
                   txtLayer.contentsScale = UIScreen.main.scale
                   if k.text == ","{
                       txtLayer.font = UIFont.systemFont(ofSize: 22 * KBScale) as CTFont
                   } else {
                       txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                   }
                   var fontSize : CGFloat = 22
                   if k.fontSize == nil && shiftStatus == .normal{
                       fontSize = 23
                   }
                   if k.fontSize != nil{
                       fontSize = k.fontSize!
                   }
                   txtLayer.fontSize = fontSize * KBScale
                   keys[i][j].textLayer = txtLayer
                   layer.addSublayer(txtLayer)
                   if !k.tip.isEmpty && k.showTip{
                       let tipSize = k.tip.getSize(font: UIFont(name: "PingFangSC-Regular", size: (k.tipSize ?? 10) * KBScale)!)
                       let tipLayer = CATextLayer()
                       tipLayer.frame = k.position.centerRect(w: tipSize.width, h: tipSize.height).offsetBy(dx: k.text.characherOffset * 0.5, dy: -13)
                       tipLayer.foregroundColor = k.tip == "。" ? cKeyTextColor.cgColor  : cKeyTipColor.cgColor
                       tipLayer.string = k.tip
                       tipLayer.contentsScale = UIScreen.main.scale
                       tipLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                       tipLayer.fontSize = (k.tipSize ?? 10) * KBScale
                       keys[i][j].tipLayer = tipLayer
                       layer.addSublayer(tipLayer)
                   }
               }
           }
       }
        bringSubviewToFront(popKeyView)
    }
    
    func createGesture(){
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
    
    func updateShift(shift:KeyShiftType){
        self.shiftStatus = shift
        keyTop = keyTopMargin
        keys.removeAll()
        if self.shiftKeyboartType != nil && (self.shiftKeyboartType! == .chinese26 || self.shiftKeyboartType! == .chinese) && shift == .normal{
            setChinese26Data()
            self.shiftKeyboartType = nil
        } else {
            setEnglish26Data(shiftType: shift)
        }
     
        createBoard()
    }
    
    
    override func updateStatus(_ status: BoardStatus) {
        if boardStatus != status{
            boardStatus = status
            updateReturnKey(newKey: ReturnKey)
            
        }
    }
    
    func updateReturnKey(newKey:KeyInfo){
        let i = keys.count - 1
        let j = keys[i].count - 1
        keys[i][j].keyLayer?.removeFromSuperlayer()
        keys[i][j].keyLayer = nil
        keys[i][j].imgLayer?.removeFromSuperlayer()
        keys[i][j].imgLayer = nil
        keys[i][j].textLayer?.removeFromSuperlayer()
        keys[i][j].textLayer = nil
        var tmpKey = newKey
        tmpKey.position = keys[i][j].position
        
        keys[i][j] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[i][j].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        if !tmpKey.image.isEmpty{
            let img = UIImage.themeImg(tmpKey.image, origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
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
            keys[i][j].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
    }
    
    func updateComma(status:Bool){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if status{
            let index1 = 2
            for item in tmpLayers{
                item.removeFromSuperlayer()
            }
            tmpLayers.removeAll()
            keys[4][index1].textLayer?.isHidden = true
            keys[4][index1].tipLayer?.isHidden = true
            let text = "。"
            keys[4][index1].text = text
            keys[4][index1].tip = ""
            let txtSize1 = text.getSize(font: UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)!)
            let txtLayer1 = CATextLayer()
            txtLayer1.frame = keys[4][index1].position.centerRect(w: txtSize1.width, h: txtSize1.height).offsetBy(dx: text.characherOffset, dy: -4)
            txtLayer1.foregroundColor = keys[4][index1].textColor.cgColor
            txtLayer1.string = text
            txtLayer1.contentsScale = UIScreen.main.scale
            txtLayer1.font = CGFont.init("PingFangSC-Regular" as CFString)
            txtLayer1.fontSize = 18 * KBScale
            tmpLayers.append(txtLayer1)
            layer.addSublayer(txtLayer1)
            
            let index2 = 4
            keys[4][index2].imgLayer?.isHidden = true
           
            let text2 = "，"
            keys[4][index2].text = text2
            keys[4][index2].keyType = .normal(.character)
            keys[4][index2].keyLayer?.fillColor = cKeyBgColor.cgColor
            keys[4][index2].popViewImage = "icon_key_pop_comma"
            let txtSize2 = text2.getSize(font: UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)!)
            let txtLayer2 = CATextLayer()
            txtLayer2.frame = keys[4][index2].position.centerRect(w: txtSize2.width, h: txtSize2.height).offsetBy(dx: text2.characherOffset, dy: -4)
            txtLayer2.foregroundColor = cKeyTextColor.cgColor
            txtLayer2.string = text2
            txtLayer2.contentsScale = UIScreen.main.scale
            txtLayer2.font = CGFont.init("PingFangSC-Regular" as CFString)
            txtLayer2.fontSize = 18 * KBScale
            tmpLayers.append(txtLayer2)
            layer.addSublayer(txtLayer2)
            
            
        } else {
            keys[4][2].textLayer?.isHidden = false
            keys[4][2].tipLayer?.isHidden = false
            keys[4][2].text = "，"
            keys[4][2].tip = "。"
            keys[4][4].keyLayer?.fillColor = cKeyBgColor2.cgColor
            keys[4][4].imgLayer?.isHidden = false
            keys[4][4].text = ""
            keys[4][4].popViewImage = nil
            keys[4][4].keyType = .switchKeyboard(.english)
            for item in tmpLayers{
                item.removeFromSuperlayer()
            }
            tmpLayers.removeAll()
        }
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keyPress(key:KeyInfo){
        kbLog.info("你点了\(key.clickText)")
      
        //点击上档键记录下当前键盘
        if key.keyType != .shift(.normal){
            self.shiftKeyboartType = self.currentKeyBoardType
        }
        var isShiftLock = false
        if key.keyType.isShift{
            if shiftClickTime == nil{
                shiftClickTime = Date().timeIntervalSince1970
            } else {
                let diff = Date().timeIntervalSince1970 - shiftClickTime!
                if diff < 0.3{ //认为是双击
                    shiftClickTime = nil
                    print("触发shift双击")
                    var k = key
                    k.keyType = .shift(.lock)
                    delegate?.keyPress(key: k)
                    isShiftLock = true
                } else{
                    shiftClickTime = Date().timeIntervalSince1970
                }
            }
        }
        if !isShiftLock{
            delegate?.keyPress(key: key)
        }
    
    }
    
    override func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State){
        delegate?.keyLongPress(key: key, state: state)
    }
    
    lazy var popKeyView: PopKeyView = {
        var width = 79.5
        if kSCREEN_WIDTH == 414{
            width = 80
        } else if kSCREEN_WIDTH == 428{
            width = 80.5
        }
        let v = PopKeyView(frame: CGRect(x: 0, y: 0, width: width * KBScale, height: 95 * KBScale))
        v.isHidden = true
        return v
    }()
}

