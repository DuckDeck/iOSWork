//
//  FullkeyboardView.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/12.
//

import Foundation
import QuartzCore
import UIKit
class FullKeyboardView: Keyboard {
    var popChooseView: PopKeyChooseView?
    var isGestured = false
    var shiftStatus = KeyShiftType.normal
    var panPosition: CGPoint?
    var sensorKeyboardSource = "" // 前序键盘，用于神策统计
    // 按键相关变量
    // 单个按键宽度
    var keyTop: CGFloat = 0 // 该行按键的上边
    var unitWidth : CGFloat = 0 //单元宽度
    var keyIndent:CGFloat{
        return keyHorGap / 2
    }
    var keyShiftWidth : CGFloat{
        return 2.5 * unitWidth - keyHorGap
    }
    var popViewHeight: CGFloat = 0
    var popViewWidthRatio: CGFloat = 0
    var ranges = [[CGFloat]]()
    var rowRanges = [CGFloat]()
    var panPath: UIBezierPath?
    var panLayer: CAShapeLayer?
    var tmpLayers = [CALayer]()
    var pressedKey: KeyInfo?
    var panPoint: CGPoint?
    var previousPoint: CGPoint?
    var hotKeyIndexs = [(Int, Int)]() // 动态热的按键
    var interSectionArea = [(CGRect, [Int])]() // 位置和对应的按键
    // 上次点shift的时间
    var shiftClickTime: Double?
    // 键盘的shift返回normal状态时，返回哪个键盘
    var shiftKeyboartType: KeyboardType?
    // 记录左右是否是逗号和句号
    var isComma = false
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keyboardType: KeyboardType, returnKey: KeyInfo?) {
        self.init(frame: .zero)
        currentKeyBoardType = keyboardType
        tmpReturnKey = returnKey
        keyboardName = keyboardType.debugDescription
        keyboardWidth = kSCREEN_WIDTH
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
 
         
       
        
        createLayout()
        createKeys()
        createRange()
        createBoard()
        createGesture()
        if !UIDevice.isNotch && keyboardType.rawValue < 3{
            keyboardVC?.removeSwitchInputView()
            keyboardVC?.addSwitchInputView(pos: keys[3][1].position)
        }
    }
   
    func createLayout() {
        unitWidth = kSCREEN_WIDTH / 20
        let boardHeight = KeyboardInfo.boardHeight
//        let standardBoardHeight = KeyboardInfo.standardBoardHeight(showNum: isShowNum)
//        let ratio = boardHeight / standardBoardHeight
        switch UIDevice.current.deviceDirection {
        case .PadVer:
            scale = 1.12
            keyTopMargin = 6
            keyHorGap = 10
            keyVerGap = 6
            keyHeight = (boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PadHor:
            scale = 1.12
            keyTopMargin = 8
            keyHorGap = 14
            keyVerGap = 8
            keyHeight = (boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PhoneHor:
            keyTopMargin = 8
            keyHorGap = 7
            keyVerGap = 8
            popViewHeight = 80
            popViewWidthRatio = 1.45
            keyHeight = (boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PhoneVer:
            keyVerGap = 13
          
            keyTopMargin = 12
            keyHeight = (boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
            
            keyHorGap = kSCREEN_WIDTH < kSepScreenWidth ? 6 : 7
            popViewHeight = kSCREEN_WIDTH < kSepScreenWidth ? 95 : 105
            scale = kSCREEN_WIDTH < kSepScreenWidth ? 1 : 1.075
            popViewWidthRatio = 1.8
        }
        keyWidth = 2 * unitWidth - keyHorGap
        keyTop = keyTopMargin
    }
    
    func createKeys() {
        keys.removeAll()
    
        switch currentKeyBoardType{
        case .chinese26:
            setChinese26Data()
        case .symbleChiese:
            setChineseSymbleData()
        case .symbleChieseMore:
            setChineseSymbleMoreData()
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
    
    func createRange() {
        ranges.removeAll()
        rowRanges.removeAll()
        for row in keys.enumerated() {
            var tmp = [CGFloat]()
            for item in row.element.enumerated() {
                if item.offset == row.element.count - 1 {
                    tmp.append(kSCREEN_WIDTH)
                } else {
                    tmp.append(item.element.hotArea?.maxX ?? item.element.position.maxX + keyHorGap * 0.5)
                }
            }
            rowRanges.append(row.element[0].position.maxY +  keyVerGap)
            ranges.append(tmp)
        }
    }
 

    override func createBoard(){
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
                   imgLayer.frame = k.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
                   imgLayer.contents = img.cgImage
                   keys[i][j].imgLayer = imgLayer
                   layer.addSublayer(imgLayer)
               }
               
               if !k.text.isEmpty{
                   var fontSize : CGFloat = 21
                   if k.fontSize != nil{
                       fontSize = k.fontSize!
                   }
                   fontSize = fontSize * scale
                   let txtSize = k.text.getSize(font: UIFont.paleRegular(size: fontSize))
                   let txtLayer = CATextLayer()
                   let txtRect = k.position.centerRect(w: txtSize.width, h: txtSize.height)
                   var yOffset : CGFloat = 0
                   if k.keyType.isNormal {
                       if !k.tip.isEmpty && k.showTip{
                           yOffset = 2
                       }
                   }
                   txtLayer.frame = txtRect.offsetBy(dx: 0, dy: yOffset)
                   txtLayer.foregroundColor = k.textColor.cgColor
                   txtLayer.string = k.text
                   txtLayer.contentsScale = UIScreen.main.scale
                   txtLayer.font = UIFont.paleRegular(size: fontSize)
                   txtLayer.fontSize = fontSize
                   keys[i][j].textLayer = txtLayer
                   layer.addSublayer(txtLayer)
                   if !k.tip.isEmpty && k.showTip{
                       let t = k.tipSize ?? 10
                       let tipSize = k.tip.getSize(font: UIFont.paleRegular(size: t))
                       let tipLayer = CATextLayer()
                       tipLayer.frame = k.position.centerRect(w: tipSize.width, h: tipSize.height).offsetBy(dx: 0, dy: -keyHeight * 0.3)
                       tipLayer.foregroundColor = cKeyTipColor.cgColor
                       tipLayer.string = k.tip
                       tipLayer.contentsScale = UIScreen.main.scale
                       tipLayer.fontSize = t
                       tipLayer.font = UIFont.paleRegular(size: t) as CTFont
                       keys[i][j].tipLayer = tipLayer
                       layer.addSublayer(tipLayer)
                   }
                   if k.subKey != nil{
                       let fontSize = 18 * scale
                       let txtSize = k.subKey!.text.getSize(font: UIFont.paleRegular(size: fontSize))
                       let txtLayer = CATextLayer()
                       txtLayer.frame = k.position.centerRect(w: txtSize.width, h: txtSize.height)
                       txtLayer.foregroundColor = k.subKey!.textColor.cgColor
                       txtLayer.string = k.subKey!.text
                       txtLayer.contentsScale = UIScreen.main.scale
                       txtLayer.font = UIFont.paleRegular(size: fontSize)
                       txtLayer.fontSize = fontSize
                       layer.addSublayer(txtLayer)
                   }
               }
           }
       }
    }
    
    func createGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
    }
    
    func updateShift(shift: KeyShiftType) {
        shiftStatus = shift
        keyTop = keyTopMargin
        keys.removeAll()
        if self.shiftKeyboartType != nil && self.shiftKeyboartType! == .chinese26  && shift == .normal{
            setChinese26Data()
            shiftKeyboartType = nil
        } else {
            setEnglish26Data(shiftType: shift)
        }
        layer.sublayers = nil
        createBoard()
    }
    
    override func updateStatus(_ status: BoardStatus) {
        if boardStatus != status{
            updateReturnKey(newKey: KeyInfo.returnKey())
            boardStatus = status
        }
    }
    
    override func update(returnKey:KeyInfo){
        self.updateReturnKey(newKey: returnKey)
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
        
        if !tmpKey.image.isEmpty {
            let img = UIImage.themeImg(tmpKey.image, origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        if !tmpKey.text.isEmpty{
            var fontSize : CGFloat = 21
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keyPress(key: KeyInfo) {
        Zlog.info("你点了\(key.clickText)")
        // 点击上档键记录下当前键盘
        if key.keyType != .shift(.normal) {
            shiftKeyboartType = currentKeyBoardType
        }
        var isShiftLock = false
        if key.keyType.isShift {
            if shiftClickTime == nil {
                shiftClickTime = Date().timeIntervalSince1970
            } else {
                let diff = Date().timeIntervalSince1970 - shiftClickTime!
                if diff < 0.3 { // 认为是双击
                    shiftClickTime = nil
                    print("触发shift双击")
                    var k = key
                    k.keyType = .shift(.lock)
                    delegate?.keyPress(key: k)
                    isShiftLock = true
                } else {
                    shiftClickTime = Date().timeIntervalSince1970
                }
            }
        }
        if !isShiftLock {
            delegate?.keyPress(key: key)
        }
      
    }
    
    override func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {
        delegate?.keyLongPress(key: key, state: state)
    }

    lazy var popLayer: CALayer = { // 超级大坑，对于所以有子view来说 使用UIImage(named:)从资源库里获取图片默认取的是iOS系统主题对应的图片，和当前app或者view设定的overrideUserInterfaceStyle不一定相同，但是如果把这个图片以UIImageVIew的形式显示出来，
        // 那么会在显示出来的时定变成当前app或者view设定设定的主题色，如果以Layer和形式显示出来。就是获取到的颜色，和app或者view设定设定的主题不一至。
        let img = UIImage.themeImg(UIDevice.current.orientation.rawValue > 2 ? "icon_key_pop_hor" : "icon_key_pop_center").resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 5, right: 18), resizingMode: .stretch)
        let imgLayer = CALayer()
        imgLayer.contents = img.cgImage
        imgLayer.name = "popLayer"
        let txtLayer = CATextLayer()
        txtLayer.actions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
            "position": NSNull()
        ]
        txtLayer.foregroundColor = cKeyTextColor.cgColor
        txtLayer.contentsScale = UIScreen.main.scale
        imgLayer.addSublayer(txtLayer)
        return imgLayer
    }()
}
