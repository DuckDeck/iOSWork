//
//  NineKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit

class NineKeyboardView: Keyboard {
    var popChooseView:PopKeyChooseView?
    var nineKeysInfo:[KeyInfo]!
    var rightKeyInfo:[KeyInfo]!
    var bottomKeyInfo:[KeyInfo]!
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        self.currentKeyBoardType = .chinese9
        backgroundColor = kColord1d5db
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        
     
        
        addSubview(leftView)
        addSubview(bottomView)
        addSubview(centerView)
        addSubview(rightView)
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(58)
        }
        
        leftView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(3)
            make.width.equalTo(56.0 * xScale + 7)
            make.bottom.equalTo(bottomView.snp.top)
        }
        centerView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right)
            make.top.equalTo(3)
            make.bottom.equalTo(bottomView.snp.top)
            make.right.equalTo(rightView.snp.left)
        }
        rightView.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.top.equalTo(3)
            make.bottom.equalTo(bottomView.snp.top)
            make.width.equalTo(56.0 * xScale + 7)
        }
    }
    
  
       
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPress(key:KeyInfo){
        print("你点了\(key.clickText)")
        delegate?.keyPress(key: key)
    }
    
    override func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {
        delegate?.keyLongPress(key: key, state: state)
    }
    
    func updateLeftText(texts:[String]?){
        if texts != nil && texts!.count > 0{
            leftView.keys = texts!
        } else {
            leftView.keys = ["，","。","？","！","...","~","'","、","_"]
        }
    }
    
    override func updateReturnKey(key: KeyInfo) {
        bottomView.updateReturnKey(newKey: key)
    }
    
    
    lazy var leftView:NineKeyLeftView = {
        let v = NineKeyLeftView(keys: ["，","。","？","！","...","~","'","、","_"])
        return v
    }()
    
    lazy var centerView: NineKeyCenterView = {
        
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        var sepKey = KeyInfo()
        let itemWidth = 77 * xScale
        let itemheight : CGFloat = 47
        sepKey.position = CGRect(x: 3, y: 5, width: itemWidth, height: itemheight )
        sepKey.text = "分词"
        sepKey.tip = "1"
        sepKey.keyType = .separate
        sepKey.fillColor = UIColor.white
        sepKey.textColor = kColor222222
        
        var aKey = KeyInfo()
        aKey.position = CGRect(x: sepKey.position.maxX + 6, y: 5, width: itemWidth, height: itemheight)
        aKey.text = "ABC"
        aKey.tip = "2"
        aKey.fillColor = UIColor.white
        aKey.textColor = kColor222222
        
        var dKey = KeyInfo()
        dKey.position = CGRect(x: aKey.position.maxX + 6, y: 5, width: itemWidth, height: itemheight)
        dKey.text = "DEF"
        dKey.tip = "3"
        dKey.fillColor = UIColor.white
        dKey.textColor = kColor222222
        
        var gKey = KeyInfo()
        gKey.position = CGRect(x: 3, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        gKey.text = "GHI"
        gKey.tip = "4"
        gKey.fillColor = UIColor.white
        gKey.textColor = kColor222222
        
        var jKey = KeyInfo()
        jKey.position = CGRect(x: gKey.position.maxX + 6, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        jKey.text = "JKL"
        jKey.tip = "5"
        jKey.fillColor = UIColor.white
        jKey.textColor = kColor222222
        
        var mKey = KeyInfo()
        mKey.position = CGRect(x: jKey.position.maxX + 6, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        mKey.text = "MNO"
        mKey.tip = "6"
        mKey.fillColor = UIColor.white
        mKey.textColor = kColor222222
        
        var pKey = KeyInfo()
        pKey.position = CGRect(x: 3, y: gKey.position.maxY + 6, width: itemWidth, height: itemheight)
        pKey.text = "PQRS"
        pKey.tip = "7"
        pKey.fillColor = UIColor.white
        pKey.textColor = kColor222222
        
        var tKey = KeyInfo()
        tKey.position = CGRect(x: pKey.position.maxX + 6, y: gKey.position.maxY + 6, width:itemWidth, height: itemheight)
        tKey.text = "TUV"
        tKey.tip = "8"
        tKey.fillColor = UIColor.white
        tKey.textColor = kColor222222
        
        var wKey = KeyInfo()
        wKey.position = CGRect(x: tKey.position.maxX + 6, y: gKey.position.maxY + 6, width: itemWidth, height: itemheight)
        wKey.text = "WXYZ"
        wKey.tip = "9"
        wKey.fillColor = UIColor.white
        wKey.textColor = kColor222222
        
        let v = NineKeyCenterView(keys: [sepKey,aKey,dKey,gKey,jKey,mKey,pKey,tKey,wKey])
        return v
    }()
    
    lazy var bottomView:NineKeyBottomView = {
        let xScale = (kSCREEN_WIDTH - 38) / 337.0
//        var emojiKey = KeyInfo()
//        emojiKey.image = "icon_keyboard_emoji"
//        emojiKey.fillColor = UIColor(hexString: "B3B7BC")
//        emojiKey.position = CGRect(x: 4, y: 4, width: 38 * xScale, height: 47)
//        emojiKey.keyType = .switchKeyboard(.emoji)
        var symbleKey = KeyInfo()
        symbleKey.text = "符"
        symbleKey.textColor = kColor222222
        symbleKey.fillColor = kColorb3b7bC
        symbleKey.position = CGRect(x: 4, y: 4, width: 56 * xScale, height: 47)
        symbleKey.keyType = .switchKeyboard(.symbleChiese)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.textColor = kColor222222
        numKey.fillColor = kColorb3b7bC
        numKey.position = CGRect(x: symbleKey.position.maxX + 6, y: 4, width: 56 * xScale, height: 47)
        numKey.keyType = .switchKeyboard(.number)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: numKey.position.maxX + 6, y: 4, width: 103 * xScale, height: 47)
        spaceKey.keyType = .space
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_switch_chinese"
        switchKey.fillColor = kColorb3b7bC
        switchKey.position = CGRect(x: spaceKey.position.maxX + 6, y: 4, width: 56 * xScale, height: 47)
        switchKey.keyType = .switchKeyboard(.english)
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + 6, y: 4, width: 72 * xScale, height: 47)
        let v = NineKeyBottomView(keys: [symbleKey,numKey,spaceKey,switchKey,enterKey])
        return v
    }()
    
    lazy var rightView: NineKeyRightView = {
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        var delKey = KeyInfo()
        delKey.position = CGRect(x: 3, y: 5, width: 56 * xScale, height: 47)
        delKey.image = "icon_delete_white"
        delKey.fillColor = kColorb3b7bC
        delKey.keyType = .del
        
        var reInputKey = KeyInfo()
        reInputKey.position = CGRect(x: 3, y: delKey.position.maxY + 6, width: 56 * xScale, height: 47)
        reInputKey.text = "重输"
        reInputKey.fillColor = kColorb3b7bC
        reInputKey.textColor = kColor222222
        reInputKey.keyType = .reInput
        
        var zeroKey = KeyInfo()
        zeroKey.position = CGRect(x: 3, y: reInputKey.position.maxY + 6, width: 56 * xScale, height: 47)
        zeroKey.text = "0"
        zeroKey.keyType = .normal(.character)
        zeroKey.fillColor = kColorb3b7bC
        zeroKey.textColor = kColor222222
        let v = NineKeyRightView(keys: [delKey,reInputKey,zeroKey])
        return v
    }()
}

class NineKeyLeftView:UIView, UITableViewDataSource,UITableViewDelegate{
    
    var keyType:KeyInputType = .character
    var keys = [String](){
        didSet{
            if keys.first!.first!.isLetter{
                keyType = .letter
            } else {
                keyType = .character
            }
            tb.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NineCell", for: indexPath) as! LeftToolViewCell
        cell.lblText.text = keys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let keyboard = superview as? NineKeyboardView{
            var key = KeyInfo()
            key.keyType = .normal(keyType)
            key.text = keys[indexPath.row]
            key.index = indexPath.row
            keyboard.keyPress(key: key)
            Shake.keyShake()
        }
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[String]) {
        self.init(frame: CGRect.zero)
        self.keys = keys
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        let shadowLayer = CAShapeLayer()
        let shadowRect = CGRect(x: 4, y: 150, width: 56.0 * xScale, height: 9)
        shadowLayer.fillColor = kColor898a8d.cgColor
        shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
        layer.addSublayer(shadowLayer)
        
        addSubview(tb)
        tb.snp.makeConstraints { make in
            make.left.equalTo(4)
            make.top.equalTo(5)
            make.right.equalTo(-3)
            make.bottom.equalTo(-3)
        }
        tb.layer.cornerRadius = 5
        tb.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tb: UITableView = {
        let v = UITableView()
        v.tableFooterView = UIView()
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.separatorInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        v.delegate = self
        v.dataSource = self
        v.rowHeight = 35
        v.separatorStyle = .none
        v.backgroundColor = UIColor(hexString: "B3B7BC")
        v.register(LeftToolViewCell.self, forCellReuseIdentifier: "NineCell")
        return v
    }()
    
}

class NineKeyCenterView:UIView,UIGestureRecognizerDelegate{
    
    var keys:[KeyInfo]!
    var pressedKey = [Int]()
    var panPoint:CGPoint?
    var previousPoint:CGPoint?
    var pressLayer:CAShapeLayer?
    var isGesture = false
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[KeyInfo]) {
        self.init(frame: .zero)
        self.keys = keys
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(ges:)))
        //        pan.delaysTouchesBegan = true
        
        pan.delegate = self
        addGestureRecognizer(pan)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
        updateKeys()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateKeys(){
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
            
            
            if !item.element.text.isEmpty{
                let lbl = UILabel()
                lbl.text = item.element.text
                lbl.font = UIFont(name: "PingFangSC-Regular", size: 18)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                txtLayer.frame = item.element.position.centerRect(w: txtSize.width, h: txtSize.height).offsetBy(dx: 0, dy: 3)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = 18
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
                
                let tipLayer = CATextLayer()
                tipLayer.frame = item.element.position.centerRect(w: 6, h: 12).offsetBy(dx: 0, dy: -16)
                tipLayer.foregroundColor = kColorbbbbbb.cgColor
                tipLayer.string = item.element.tip
                tipLayer.contentsScale = UIScreen.main.scale
                tipLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                tipLayer.fontSize = 10
                layer.addSublayer(tipLayer)
                
            }
        }
    }
    
    @objc func panGes(ges:UIPanGestureRecognizer){
        let point = ges.location(in: self)
        switch ges.state{
        case .began:
            panPoint = point
            isGesture = true
        case .ended:
            if !pressedKey.isEmpty && panPoint != nil{
                let distance = panPoint!.y - point.y
                let pressKey = keys[pressedKey.first!]
                if distance > 30 && point.x > pressKey.position.minX - distance * 0.6 && point.x < pressKey.position.maxX + distance * 0.6{
                    if let keyboard = superview as? Keyboard{
                        var key = pressKey
                        key.clickType = .tip
                        key.keyType = .normal(.character)
                        keyboard.keyPress(key: key)
                        Shake.keyShake()
                    }
                }
            }
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey.removeAll()
            panPoint = nil
            isGesture = false
        case .cancelled,.failed:
            isGesture = false
            panPoint = nil
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey.removeAll()
        default:
            break
        }
    }
    
    @objc func longPressGes(ges:UILongPressGestureRecognizer){
        let point = ges.location(in: self)
        
        switch ges.state{
        case .began:
            isGesture = true
            for item in positions.enumerated(){
                if item.element.large(w: 3, h: 3).contains(point){
                    let key = keys[item.offset]
                    let txt = key.tip == "1" ?  "1" : "\(key.text)\(key.tip)\(key.text.lowercased())"
                    let width : CGFloat = CGFloat(txt.count * 30 + 8)
                    let pos = convert(key.position, to: superview)
                    var x = pos.midX - width / 2.0
                    if x - 4 <= 0{
                        x = 4
                    }
                    if x + width + 4 >= kSCREEN_WIDTH{
                        x = kSCREEN_WIDTH - width - 4
                    }
                    let chooseView = PopKeyChooseView(frame: CGRect(x: x, y: pos.minY - 58, width: width, height: 52), keys: txt)
                    if let v = superview as? NineKeyboardView{
                        v.popChooseView = chooseView
                        v.addSubview(chooseView)
                    }
                    previousPoint = point
                    Shake.keyShake()
                }
            }
            
        case .changed:
            if previousPoint != nil{
                if point.x - previousPoint!.x > 20{
                    previousPoint = point
                    (superview as! NineKeyboardView).popChooseView?.selectIndex += 1
                } else if point.x - previousPoint!.x < -20{
                    previousPoint = point
                    (superview as! NineKeyboardView).popChooseView?.selectIndex -= 1
                }
            }
            print("changed\(ges.location(in: self))")
        case .ended,.cancelled:
            isGesture = false
            previousPoint = nil
            if let v = (superview as! NineKeyboardView).popChooseView{
                let str = v.keys.substring(from: v.selectIndex, length: 1)
                var key = KeyInfo()
                key.text = String(str)
                key.keyType = .normal(.character)
                (superview as! NineKeyboardView).keyPress(key: key)
                (superview as! NineKeyboardView).popChooseView?.removeFromSuperview()
                (superview as! NineKeyboardView).popChooseView = nil
            }
            if !pressedKey.isEmpty && previousPoint == nil{
                pressedKey.removeAll()
                pressLayer?.removeFromSuperlayer()
                pressLayer = nil
            }
        default:
            break
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        if isGesture{
            return
        }
        if let point = touches.first?.location(in: self){
            for item in positions.enumerated(){
                if item.element.large(w: 3, h: 3).contains(point){
                    pressedKey.append(item.offset)
                    let pressKey = keys[item.offset]
                    if pressLayer == nil{
                        pressLayer = CAShapeLayer()
                    } else {
                        pressLayer?.removeFromSuperlayer()
                    }
                    pressLayer?.fillColor = kColora9abb0.cgColor
                    let path = UIBezierPath(roundedRect: pressKey.position, cornerRadius: 5)
                    pressLayer?.path = path.cgPath
                    layer.insertSublayer(pressLayer!, above: pressKey.keyLayer)
                    break
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGesture{
            return
        }
        if !pressedKey.isEmpty{
            var index = -1
            let point = touches.first!.location(in: self)
            if let keyboard = superview as? NineKeyboardView{
                
                for item in pressedKey.enumerated(){
                    if keys[item.element].position.large(w: 3, h: 3).contains(point){
                        keyboard.keyPress(key: keys[item.element])
                        Shake.keyShake()
                        index = item.offset
                        break
                    }
                }
            }
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            if index >= 0{
                pressedKey.remove(at: index)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGesture{
            return
        }
        if !pressedKey.isEmpty{
            var index = -1
            let point = touches.first!.location(in: self)
                
            for item in pressedKey.enumerated(){
                if keys[item.element].position.large(w: 3, h: 3).contains(point){
                    index = item.offset
                    break
                }
            }
            
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            if index >= 0{
                pressedKey.remove(at: index)
            }
        }
    }
    
    
    var positions : [CGRect]{
        return keys.map { k in
            return k.position
        }
    }
}

class NineKeyRightView:UIView,UIGestureRecognizerDelegate{
    var keys:[KeyInfo]!
    var pressedKey:KeyInfo?
    var pressLayer:CAShapeLayer?
    var isGestured = false
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[KeyInfo]) {
        self.init(frame: .zero)
        self.keys = keys
        self.updateKeys()
        let press = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        press.minimumPressDuration = 0.4
        self.isUserInteractionEnabled = true
        press.delegate = self
        self.addGestureRecognizer(press)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateKeys(){
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
                lbl.font = UIFont(name: "PingFangSC-Regular", size: 18)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                txtLayer.frame = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = 18
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
            }
        }
    }
    
    @objc func longPressGes(ges:UILongPressGestureRecognizer){
        switch ges.state{
        case .began:
            isGestured = true
            if  pressedKey != nil {
                if pressedKey!.keyType == .del{
                    (superview as! Keyboard).keyLongPress(key: pressedKey!, state: ges.state)
                    Shake.keyShake()
                }
                return
            }
        case .ended,.cancelled:
            if pressedKey != nil {
                if pressedKey!.keyType == .del{
                    (superview as! Keyboard).keyLongPress(key: pressedKey!, state: ges.state)
                    pressedKey?.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_white").cgImage
                }
                pressLayer?.removeFromSuperlayer()
                pressLayer = nil
                pressedKey = nil
            }
            isGestured = false
        default:
            break
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.phase == .began{
            if isGestured{
                return true
            }
            let point = touch.location(in: self)
            for item in positions.enumerated(){
                if item.element.contains(point){
                    pressedKey = keys[item.offset]
                    if pressedKey!.keyType == .del{
                        pressedKey?.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_black").cgImage
                    }
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
        return true
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGestured{
            return
        }
        if pressedKey != nil{
            if pressedKey!.keyType == .del{
                pressedKey?.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_white").cgImage
            }
            if let keyboard = superview as? NineKeyboardView{
                keyboard.keyPress(key: pressedKey!)
                Shake.keyShake()
            }
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGestured{
            return
        }
        if pressedKey != nil{
            if pressedKey!.keyType == .del{
                pressedKey?.imgLayer?.contents = UIImage.yh_imageNamed("icon_delete_white").cgImage
            }
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

class NineKeyBottomView:UIView{
    
    var keys:[KeyInfo]!
    var pressedKey:KeyInfo?
    var pressLayer:CAShapeLayer?
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[KeyInfo]) {
        self.init(frame: .zero)
        self.keys = keys
        self.updateKeys()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
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
    
    
    func updateKeys(){
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
                lbl.font = UIFont(name: "PingFangSC-Regular", size: 18)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                txtLayer.frame = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = 18
                keys[item.offset].textLayer = txtLayer
                layer.addSublayer(txtLayer)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self){
            for item in positions.enumerated(){
                if item.element.contains(point){
                    pressedKey = keys[item.offset]
                    if pressedKey!.keyType.isReturnKey &&  !pressedKey!.isEnable{
                        return
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
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pressedKey != nil{
            if let keyboard = superview as? NineKeyboardView{
                if pressedKey!.keyType.isReturnKey &&  !pressedKey!.isEnable{
                    return
                }
                keyboard.keyPress(key: pressedKey!)
                Shake.keyShake()
            }
            pressLayer?.removeFromSuperlayer()
            pressLayer = nil
            pressedKey = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pressedKey != nil{
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

class LeftToolViewCell:UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(hexString: "B3B7BC")
        contentView.addSubview(lblText)
        lblText.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lblText: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.font = UIFont.systemFont(ofSize: 18)
        v.textColor = UIColor(hexString: "222222")
        return v
    }()
}
