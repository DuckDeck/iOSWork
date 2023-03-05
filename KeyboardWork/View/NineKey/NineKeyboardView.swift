//
//  9KeyView.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/12.
//

import Foundation
import UIKit

protocol keyPressDelegate: NSObjectProtocol {
    func keyPress(key: KeyInfo)
    func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State)
}

class NineKeyboardView: Keyboard {
    var popChooseView: PopKeyChooseView?
    
    var pressedKey: KeyInfo?
    var panPoint: CGPoint?
    var previousPoint: CGPoint?
    var isGesture = false
    var panPosition: CGPoint?
    var panPath:UIBezierPath?
    var panLayer: CAShapeLayer?
    var hotAreaVerOffset : [CGFloat]!
    var keyTop : CGFloat = 0            //该行按键的上边
    var unitWidth20 : CGFloat = 0
    var unitWidth18 : CGFloat = 0
    var keyHeightBottom : CGFloat = 0
    var keyIndent:CGFloat{
        return keyHorGap / 2
    }
    var rowRanges = [CGFloat]()
    var ranges = [[CGFloat]]()
    var sensorKeyboardSource = ""
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(returnKey:KeyInfo?) {
        self.init(frame: .zero)
        self.tmpReturnKey = returnKey
        keyboardName = "中文9键键盘页"
        self.currentKeyBoardType = .chinese9
        backgroundColor = keyboardBgColor
        keyboardWidth = kSCREEN_WIDTH
        
        hotAreaVerOffset =  [0.5,0.6,0.7,1]
        
        createLayout()
        createKeys()
        createRange()
        createBoard()
        createGesture()
        if !UIDevice.isNotch{
            keyboardVC?.removeSwitchInputView()
            keyboardVC?.addSwitchInputView(pos: keys[3][1].position)
        }
    }
    
    func createLayout(){
        unitWidth20 = kSCREEN_WIDTH / 20
        unitWidth18 = kSCREEN_WIDTH / 18
        switch UIDevice.current.deviceDirection{
        case .PadVer:
            scale = 1.12
            keyTopMargin = 6
            keyHorGap = 10
            keyVerGap = 6
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PadHor:
            scale = 1.12
            keyTopMargin = 8
            keyHorGap = 11
            keyVerGap = 8
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 3 * keyVerGap) / 4
        case .PhoneHor:
            keyTopMargin = 5
            keyHorGap = 11
            keyVerGap = 5.5
            keyHeightBottom = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - 24) / 4
        case .PhoneVer:
            keyTopMargin = 7
            keyVerGap = 7
            keyHorGap = 6
            keyHeightBottom = stardKeyHeight
            scale = kSCREEN_WIDTH < kSepScreenWidth ? 1 : 1.075
        }
        
        keyHeight = (KeyboardInfo.boardHeight - keyTopMargin - globalKeyboardHeight.bottomMargin - keyHeightBottom) / 3 - keyVerGap
        
        keyTop = keyTopMargin
    }
    
    func createKeys(){
      
        var row2 = [KeyInfo]()
        var row3 = [KeyInfo]()
        var row4 = [KeyInfo]()
        var row5 = [KeyInfo]()
        let keyTexts = ["@/.","ABC","DEF","GHI","JKL","MNO","PQRS","TUV","WXYZ"]
        for item in keyTexts.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.tip = "\(item.offset + 1)"
            if  UIDevice.current.orientation.rawValue > 2{
                k.showTip = false
            }
            if item.offset == 0{
                k.keyType = .separate
                k.fontSize = 21
            }
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            let r = item.offset / 3
            let c = item.offset % 3
            k.position = CGRect(x: 3 * unitWidth18 + keyHorGap / 2 + unitWidth18 * 4  * CGFloat(c), y: keyTop + (keyHeight + keyVerGap) * CGFloat(r), width: unitWidth18 * 4 - keyHorGap, height: keyHeight)
            if r == 0{
                row2.append(k)
            } else if r == 1{
                row3.append(k)
            } else {
                row4.append(k)
            }
        }
        
        var delKey = KeyInfo()
        delKey.position = CGRect(x: row2.last!.position.maxX + keyHorGap, y: row2.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        delKey.text = "\u{232B}"
        delKey.fontSize = 21
        delKey.textColor = cKeyTextColor
        delKey.fillColor = cKeyBgColor2
        delKey.keyType = .del
        row2.append(delKey)
        
        var reInputKey = KeyInfo()
        reInputKey.position = CGRect(x: row3.last!.position.maxX + keyHorGap, y: row3.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        let type =  keyboardVC!.textDocumentProxy.returnKeyType
        reInputKey.text = type == .send ? "换行" : "重输"
        reInputKey.fontSize = 20
        reInputKey.textColor = cKeyTextColor
        reInputKey.fillColor = cKeyBgColor2
        reInputKey.keyType = type == .send ? .newLine : .reInput
        row3.append(reInputKey)
        
        var zeroKey = KeyInfo()
        zeroKey.position = CGRect(x: row4.last!.position.maxX + keyHorGap, y: row4.last!.position.minY, width: unitWidth18 * 3 - keyHorGap, height: keyHeight)
        zeroKey.text = "\u{7B11}"
        zeroKey.fontSize = 21
        zeroKey.textColor = cKeyTextColor
        zeroKey.keyType = .switchKeyboard(.emoji)
        zeroKey.fillColor = cKeyBgColor2
        row4.append(zeroKey)
        
        var widths : [CGFloat]!
        if UIDevice.isNotch{
            widths = [unitWidth18 * 3 - keyHorGap,unitWidth18 * 3 - keyHorGap,6 * unitWidth18 - keyHorGap,unitWidth20 * 2.5 - keyHorGap,unitWidth18 * 6 - unitWidth20 * 2.5 - keyHorGap]
        } else {
            widths = [unitWidth20 * 2.5 - keyHorGap ,unitWidth20 * 2.5 - keyHorGap ,kSCREEN_WIDTH - 7.5 * unitWidth20 - 6 * unitWidth18 - keyHorGap ,2.5 * unitWidth20 - keyHorGap,6 * unitWidth18 - 2.5 * unitWidth20 - keyHorGap]
        }
        
        var symbleKey = KeyInfo()
        symbleKey.text = "符"
        symbleKey.fontSize = 20
        symbleKey.textColor = cKeyTextColor
        symbleKey.fillColor = cKeyBgColor2
        symbleKey.position = CGRect(x: keyIndent, y: row4.first!.position.maxY + keyVerGap, width: widths[0], height: keyHeightBottom)
        symbleKey.keyType = .switchKeyboard(.symbleChiese)
        row5.append(symbleKey)
        var tmpKey = symbleKey
        if !UIDevice.isNotch{
            var switchKey = KeyInfo()
            switchKey.position = CGRect(x: symbleKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: widths[0], height: keyHeightBottom)
            row5.append(switchKey)
            tmpKey = switchKey
        }
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.fontSize = 18
        numKey.textColor = cKeyTextColor
        numKey.fillColor = cKeyBgColor2
        numKey.position = CGRect(x: tmpKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: widths[1], height: keyHeightBottom)
        numKey.keyType = .switchKeyboard(.number)
        row5.append(numKey)
        
        var spaceKey = KeyInfo()
        spaceKey.text = "\u{2423}"
        spaceKey.textColor = cKeyTextColor
        spaceKey.fillColor = cKeyBgColor
        spaceKey.tip = "0"
        spaceKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: widths[2], height: keyHeightBottom)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.text = "\u{592A}"
        switchKey.fontSize = 18
        switchKey.textColor = cKeyTextColor
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: widths[3], height: keyHeightBottom)
        switchKey.keyType = .switchKeyboard(.english)
        var subKey = SubKeyInfo()
        subKey.text = "\u{9633}"
        subKey.textColor = cKeyTextColor.withAlphaComponent(0.3)
        subKey.fontSize = 18
        switchKey.subKey = subKey
        row5.append(switchKey)
        
        var enterKey = tmpReturnKey ??  KeyInfo.returnKey()
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: widths[4], height: keyHeightBottom)
        row5.append(enterKey)
        
        keys.append(row2)
        keys.append(row3)
        keys.append(row4)
        keys.append(row5)
    }
    
    func createRange(){
        for row in keys.enumerated(){
            rowRanges.append(row.element.first!.position.maxY + hotAreaVerOffset[row.offset] * keyHorGap)
            var tmp = [CGFloat]()
            for item in row.element.enumerated(){
                if item.offset == row.element.count - 1{
                    tmp.append(item.element.position.maxX + keyIndent)
                } else {
                    tmp.append(item.element.position.maxX + keyVerGap / 2)
                }
            }
            ranges.append(tmp)
        }
    }
    
    override func createBoard(){
        let leftShadowLayer = CAShapeLayer()
        let leftShadowRect = CGRect(x: keyIndent, y: keys[2][0].position.maxY - 10, width: unitWidth18 * 3 - keyHorGap, height: 11)
        leftShadowLayer.fillColor = cKeyShadowColor.cgColor
        leftShadowLayer.path = UIBezierPath(roundedRect: leftShadowRect, cornerRadius: 5).cgPath
        layer.addSublayer(leftShadowLayer)
        
        addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalTo(keyIndent)
           
            make.top.equalTo(keys[0][0].position.minY)
            make.height.equalTo(keys[2][0].position.maxY - keys[0][0].position.minY)
            
            make.width.equalTo(unitWidth18 * 3 - keyHorGap)
        }
        
       
        
        for i in 0..<keys.count{
            for j in 0..<keys[i].count{
                let k = keys[i][j]
                let keyLayer = CAShapeLayer()
                keyLayer.fillColor = k.fillColor.cgColor
                let path = UIBezierPath(roundedRect: k.position, cornerRadius: 5)
                keyLayer.path = path.cgPath
                keys[i][j].keyLayer = keyLayer
                layer.addSublayer(keyLayer)
                
                // shadowlayer
                let shadowLayer = CAShapeLayer()
                let shadowRect = CGRect(x: k.position.origin.x, y: k.position.maxY - 10, width: k.position.width, height: 11)
                shadowLayer.fillColor = cKeyShadowColor.cgColor
                shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
                layer.insertSublayer(shadowLayer, below: keyLayer)
                
                // imageLayer
                
                if !k.image.isEmpty {
                    let img = UIImage.themeImg(k.image,origin: true)
                    let imgLayer = CALayer()
                    imgLayer.frame = k.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
                    imgLayer.contents = img.cgImage
                    keys[i][j].imgLayer = imgLayer
                    layer.addSublayer(imgLayer)
                }
                
                if !k.text.isEmpty {
                    let txtSize = k.text.getSize(font: UIFont.paleRegular(size: (k.fontSize ?? 18) * scale))
                    let txtLayer = CATextLayer()
                    var yOffset : CGFloat = 0
                    if !k.tip.isEmpty && k.showTip{
                        yOffset = 2.5
                    }
                    txtLayer.frame = k.position.centerRect(w: txtSize.width, h: txtSize.height).offsetBy(dx: 0, dy: yOffset)
                    txtLayer.foregroundColor = k.textColor.cgColor
                    txtLayer.string = k.text
                    txtLayer.contentsScale = UIScreen.main.scale
                    txtLayer.font = UIFont.paleRegular(size: (k.fontSize ?? 18) * scale)
                    txtLayer.fontSize = (k.fontSize ?? 18) * scale
                    keys[i][j].textLayer = txtLayer
                    layer.addSublayer(txtLayer)
                }
                if !k.tip.isEmpty, k.showTip {
                    let t = k.tipSize ?? 10
                    let tipSize = k.tip.getSize(font: UIFont.paleRegular(size: t))
                    let tipLayer = CATextLayer()
                    tipLayer.frame = k.position.centerRect(w: tipSize.width, h: tipSize.height).offsetBy(dx: 0, dy: -k.position.height * 0.3)
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
    
    func createGesture(){
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPress(key: KeyInfo) {
        print("你点了\(key.clickText)")
        delegate?.keyPress(key: key)
       
    }
    
    override func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {
        delegate?.keyLongPress(key: key, state: state)
    }
    
    func updateLeftText(texts: [String]?) {
        if texts != nil, texts!.count > 0 {
            leftView.keys = texts!
        } else {
            leftView.keys = ["，", "。", "？", "！", "...", "~", "'", "、", "_"]
        }
    }
    
    override func updateStatus(_ status: BoardStatus) {
        if status != boardStatus{
            updateReturnKey(key: KeyInfo.returnKey())
            if keyboardVC!.textDocumentProxy.returnKeyType == .send{
                updateReInput(key: ReInputKey)
            }
            updateSepKey()
            boardStatus = status
        }
    }
    
    override func update(returnKey:KeyInfo){
        self.updateReturnKey(key: returnKey)
    }
    
    // 可以把更新分词状态放这里
    func updateReInput(key: KeyInfo) {
        let i =  1  ,j=3
        keys[i][j].keyLayer?.removeFromSuperlayer()
        keys[i][j].keyLayer = nil
        keys[i][j].imgLayer?.removeFromSuperlayer()
        keys[i][j].imgLayer = nil
        var tmpKey = key
        tmpKey.position = keys[i][j].position
        
        keys[i][j] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[i][j].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        if !tmpKey.image.isEmpty {
            let img = UIImage.themeImg(tmpKey.image,origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        if !tmpKey.text.isEmpty{
            var fontSize : CGFloat = 20
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

    func updateSepKey(){
        let p =  0,q = 0
        var changeSep = false
        if globalHeader?.isHavePinYin ?? false {
            if keys[p][q].text != "分词" {
                keys[p][q].imgLayer?.removeFromSuperlayer()
                keys[p][q].imgLayer = nil
                keys[p][q].text = "分词"
                changeSep = true
            }
        } else {
            if keys[p][q].text == "分词" {
                keys[p][q].imgLayer?.removeFromSuperlayer()
                keys[p][q].imgLayer = nil
                keys[p][q].text = "@/."
                changeSep = true
            }
        }
        if changeSep {
            keys[p][q].textLayer?.removeFromSuperlayer()
            keys[p][q].textLayer = nil
            let txtSize = keys[p][q].text.getSize(font: UIFont.paleRegular(size: 21 * scale))
            let txtLayer = CATextLayer()
            txtLayer.frame = keys[p][q].position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.foregroundColor = keys[p][q].textColor.cgColor
            txtLayer.string = keys[p][q].text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = UIFont.paleRegular(size: 21 * scale)
            txtLayer.fontSize = 21 * scale
            keys[p][q].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
    }
    
    func updateReturnKey(key: KeyInfo) {
        let i = keys.count - 1
        let j = keys[i].count - 1
        keys[i][j].keyLayer?.removeFromSuperlayer()
        keys[i][j].keyLayer = nil
        keys[i][j].imgLayer?.removeFromSuperlayer()
        keys[i][j].imgLayer = nil
        keys[i][j].textLayer?.removeFromSuperlayer()
        keys[i][j].textLayer = nil
        var tmpKey = key
        tmpKey.position = keys[i][j].position
        
        keys[i][j] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[i][j].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        if !tmpKey.image.isEmpty{
            let img =  UIImage.themeImg(tmpKey.image, origin: true)
            let imgLayer = CALayer()
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * scale, h: img.size.height * scale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        if !tmpKey.text.isEmpty{
            var fontSize : CGFloat = 20
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
    
    
    lazy var leftView: NineKeyLeftView = {
        let v = NineKeyLeftView(keys: ["，", "。", "？", "！", "...", "~", "'", "、", "_"],imgs: [], keyHeight: keyHeight)
        return v
    }()
}

class NineKeyLeftView: UIView, UITableViewDataSource, UITableViewDelegate {
    var keyType: KeyInputType = .character
    var keys = [String]() {
        didSet {
            if keys.first!.first!.isLetter {
                keyType = .letter
            } else {
                keyType = .character
            }
            tb.reloadData()
        }
    }
    var imgs = [String]()
    var keyHeight : CGFloat = 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count + imgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < imgs.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImgCell", for: indexPath) as! LeftImageViewCell
            cell.imgView.image = UIImage(named: imgs[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NineCell", for: indexPath) as! LeftToolViewCell
            cell.lblText.text = keys[indexPath.row - imgs.count]
            if keys[indexPath.row - imgs.count] == "汇率"{
                cell.lblText.font = UIFont.paleRegular(size: 16 * KBScale)
            } else {
                cell.lblText.font = UIFont.paleRegular(size: 18 * KBScale)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var key = KeyInfo()
        if keys[indexPath.row] == "汇率"{
            key.keyType = .special("汇率")
        } else{
            key.keyType = .normal(keyType)
            key.text = keys[indexPath.row - imgs.count]
            key.index = indexPath.row
        }
        (superview as? Keyboard)?.keyPress(key: key)
        Shake.keyShake()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return keyHeight * 0.85
    }
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys: [String],imgs:[String], keyHeight:CGFloat) {
        self.init(frame: CGRect.zero)
        self.keys = keys
        self.imgs = imgs
        self.keyHeight = keyHeight
        addSubview(tb)
        tb.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        tb.layer.cornerRadius = 5
        tb.clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tb: UITableView = {
        let v = UITableView()
        v.tableFooterView = UIView()
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.separatorColor = Colors.color202F64.withAlphaComponent(0.08) | UIColor("3d3e42")
        v.separatorInset = .zero
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = cKeyBgColor2
        v.register(LeftToolViewCell.self, forCellReuseIdentifier: "NineCell")
        v.register(LeftImageViewCell.self, forCellReuseIdentifier: "ImgCell")
        return v
    }()
}





class LeftToolViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = cKeyBgColor2
        contentView.addSubview(lblText)
        lblText.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lblText: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.textColor = cKeyTextColor
        return v
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor("a2a5ad") | UIColor("414245")
        self.selectedBackgroundView = bgColorView
    }
}
class LeftImageViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = cKeyBgColor2
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor("a2a5ad") | UIColor("414245")
        self.selectedBackgroundView = bgColorView
    }
}
