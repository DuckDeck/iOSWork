//
//  NumKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit

class NumKeyboardView: Keyboard {
    var nineKeysInfo:[KeyInfo]!
    var rightKeyInfo:[KeyInfo]!
    var bottomKeyInfo:[KeyInfo]!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.currentKeyBoardType = .number
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
            make.top.equalTo( 3)
            make.width.equalTo(56.0 * xScale + 7)
            make.bottom.equalTo(bottomView.snp.top)
        }
        centerView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right)
            make.top.equalTo( 3)
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
    
    override func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State){
        delegate?.keyLongPress(key: key, state: state)
    }
    
    override func updateReturnKey(key: KeyInfo) {
        bottomView.updateReturnKey(newKey: key)
    }
    

    
    lazy var leftView:NumberKeyLeftView = {
       let v = NumberKeyLeftView(keys: ["=","+","-","x","÷","*","/","%","(",")","￥","$","#"])
       return v
    }()
    
    lazy var centerView: NumberKeyCenterView = {
        
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        let itemWidth = 77 * xScale
        let itemheight : CGFloat = 47
        var sepKey = KeyInfo()
        sepKey.position = CGRect(x: 3, y: 5, width: itemWidth, height: itemheight)
        sepKey.text = "1"
        sepKey.fillColor = UIColor.white
        sepKey.keyType = .normal(.character)
        sepKey.textColor = kColor222222
        
        var aKey = KeyInfo()
        aKey.position = CGRect(x: sepKey.position.maxX + 6, y: 5, width: itemWidth, height: itemheight)
        aKey.text = "2"
        aKey.fillColor = UIColor.white
        aKey.keyType = .normal(.character)
        aKey.textColor = kColor222222
        
        var dKey = KeyInfo()
        dKey.position = CGRect(x: aKey.position.maxX + 6, y: 5, width: itemWidth, height: itemheight)
        dKey.text = "3"
        dKey.fillColor = UIColor.white
        dKey.keyType = .normal(.character)
        dKey.textColor = kColor222222
        
        var gKey = KeyInfo()
        gKey.position = CGRect(x: 3, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        gKey.text = "4"
        gKey.fillColor = UIColor.white
        gKey.keyType = .normal(.character)
        gKey.textColor = kColor222222
        
        var jKey = KeyInfo()
        jKey.position = CGRect(x: gKey.position.maxX + 6, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        jKey.text = "5"
        jKey.fillColor = UIColor.white
        jKey.keyType = .normal(.character)
        jKey.textColor = kColor222222
        
        var mKey = KeyInfo()
        mKey.position = CGRect(x: jKey.position.maxX + 6, y: sepKey.position.maxY + 6, width: itemWidth, height: itemheight)
        mKey.text = "6"
        mKey.fillColor = UIColor.white
        mKey.keyType = .normal(.character)
        mKey.textColor = kColor222222
        
        var pKey = KeyInfo()
        pKey.position = CGRect(x: 3, y: gKey.position.maxY + 6, width: itemWidth, height: itemheight)
        pKey.text = "7"
        pKey.fillColor = UIColor.white
        pKey.keyType = .normal(.character)
        pKey.textColor = kColor222222
        
        var tKey = KeyInfo()
        tKey.position = CGRect(x: pKey.position.maxX + 6, y: gKey.position.maxY + 6, width: itemWidth, height: itemheight)
        tKey.text = "8"
        tKey.fillColor = UIColor.white
        tKey.keyType = .normal(.character)
        tKey.textColor = kColor222222
        
        var wKey = KeyInfo()
        wKey.position = CGRect(x: tKey.position.maxX + 6, y: gKey.position.maxY + 6, width: itemWidth, height: itemheight)
        wKey.text = "9"
        wKey.fillColor = UIColor.white
        wKey.keyType = .normal(.character)
        wKey.textColor = kColor222222
        
        let v = NumberKeyCenterView(keys: [sepKey,aKey,dKey,gKey,jKey,mKey,pKey,tKey,wKey])
        return v
    }()
    
    lazy var bottomView:NumberKeyBottomView = {
        let xScale = (kSCREEN_WIDTH - 38) / 337.0
//        var emojiKey = KeyInfo()
//        emojiKey.image = "icon_keyboard_emoji"
//        emojiKey.fillColor = kColorb3b7bC
//        emojiKey.position = CGRect(x: 4, y: 3, width: 38 * xScale, height: 47)
//        emojiKey.keyType = .switchKeyboard(.emoji)
        var symbleKey = KeyInfo()
        symbleKey.text = "符"
        symbleKey.textColor = kColor222222
        symbleKey.fillColor = kColorb3b7bC
        symbleKey.position = CGRect(x: 4, y: 3, width: 56 * xScale, height: 47)
        symbleKey.keyType = .switchKeyboard(.symbleChiese)
        
        var backKey = KeyInfo()
        backKey.text = "返回"
        backKey.textColor = kColor222222
        backKey.fillColor = kColorb3b7bC
        backKey.position = CGRect(x: symbleKey.position.maxX + 6, y: 3, width: 56 * xScale, height: 47)
        backKey.keyType = .backKeyboard
        
        var zeroKey = KeyInfo()
        zeroKey.text = "0"
        zeroKey.textColor = kColor222222
        zeroKey.fillColor = UIColor.white
        zeroKey.position = CGRect(x: backKey.position.maxX + 6, y: 3, width: 77 * xScale, height: 47)
        zeroKey.keyType = .normal(.character)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_space_black"
        spaceKey.fillColor = UIColor.white
        spaceKey.position = CGRect(x: zeroKey.position.maxX + 6, y: 3, width: 98 * xScale, height: 47)
        spaceKey.keyType = .space
        
        
        var enterKey = returnKey
        enterKey.position = CGRect(x: spaceKey.position.maxX + 6, y: 3, width: 56 * xScale, height: 47)
        let v = NumberKeyBottomView(keys: [symbleKey,backKey,zeroKey,spaceKey,enterKey])
        return v
    }()
    
    lazy var rightView: NumberKeyRightView = {
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        var delKey = KeyInfo()
        delKey.position = CGRect(x: 3, y: 5, width: 56 * xScale, height: 47)
        delKey.image = "icon_delete_white"
        delKey.fillColor = kColorb3b7bC
        delKey.keyType = .del
        
        var pointKey = KeyInfo()
        pointKey.position = CGRect(x: 3, y: delKey.position.maxY + 6, width: 56 * xScale, height: 47)
        pointKey.text = "."
        pointKey.fillColor = kColorb3b7bC
        pointKey.textColor = kColor222222
        pointKey.keyType = .normal(.character)
        
        var atKey = KeyInfo()
        atKey.position = CGRect(x: 3, y: pointKey.position.maxY + 6, width: 56 * xScale, height: 47)
        atKey.text = "@"
        atKey.fillColor = kColorb3b7bC
        atKey.textColor = kColor222222
        atKey.keyType = .normal(.character)
        let v = NumberKeyRightView(keys: [delKey,pointKey,atKey])
        return v
    }()
}

class NumberKeyLeftView:UIView, UITableViewDataSource,UITableViewDelegate{
    
    var keyType:KeyType = .symble
    var keys = [String]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as! LeftToolViewCell
        cell.lblText.text = keys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let keyboard = superview as? NumKeyboardView{
            var key = KeyInfo()
            key.keyType = .normal(.character)
            key.text = keys[indexPath.row]
            keyboard.keyPress(key: key)
            Shake.keyShake()
        }
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[String]) {
        self.init(frame: CGRect.zero)
        let xScale = (kSCREEN_WIDTH - 32) / 343.0
        let shadowLayer = CAShapeLayer()
        let shadowRect = CGRect(x: 4, y: 150, width: 56.0 * xScale, height: 9)
        shadowLayer.fillColor = kColor898a8d.cgColor
        shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
        layer.addSublayer(shadowLayer)
        
        self.keys = keys
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
        v.backgroundColor = kColorb3b7bC
        v.register(LeftToolViewCell.self, forCellReuseIdentifier: "NumberCell")
        return v
    }()
}


class NumberKeyCenterView:UIView,UIGestureRecognizerDelegate{
    var keys:[KeyInfo]!
    var pressedKey = [Int]()
    var panPoint:CGPoint?
    var pressLayer:CAShapeLayer?
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys:[KeyInfo]) {
        self.init(frame: .zero)
        self.keys = keys
        isMultipleTouchEnabled = true
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
                lbl.font = UIFont(name: "PingFangSC-Regular", size: 22)
                let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                let txtLayer = CATextLayer()
                txtLayer.frame = item.element.position.centerRect(w: txtSize.width, h: txtSize.height)
                txtLayer.foregroundColor = item.element.textColor.cgColor
                txtLayer.string = item.element.text
                txtLayer.contentsScale = UIScreen.main.scale
                txtLayer.font = CGFont.init("PingFangSC-Regular" as CFString)
                txtLayer.fontSize = 22
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
    
   
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        if panPoint != nil{
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
        if panPoint != nil{
            return
        }
        if !pressedKey.isEmpty{
            var index = -1
            let point = touches.first!.location(in: self)
            if let keyboard = superview as? NumKeyboardView{
                
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
        if panPoint != nil{
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

class NumberKeyRightView:UIView,UIGestureRecognizerDelegate{
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
            if let keyboard = superview as? NumKeyboardView{
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

class NumberKeyBottomView:UIView{
    
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
        keys[index].imgLayer?.removeFromSuperlayer()
        var tmpKey = newKey
        tmpKey.position = keys.last!.position
        
        keys[index] = tmpKey
        
        let keyLayer = CAShapeLayer()
        keyLayer.fillColor = tmpKey.fillColor.cgColor
        let path = UIBezierPath(roundedRect: tmpKey.position, cornerRadius: 5)
        keyLayer.path = path.cgPath
        keys[index].keyLayer = keyLayer
        layer.addSublayer(keyLayer)
        
        //shadowlayer
        let shadowLayer = CAShapeLayer()
        let shadowRect = CGRect(x: tmpKey.position.origin.x, y: tmpKey.position.maxY - 10, width: tmpKey.position.width, height: 11)
        shadowLayer.fillColor = kColor898a8d.cgColor
        shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
        layer.insertSublayer(shadowLayer, below: keyLayer)
        
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
            txtLayer.frame = tmpKey.position.centerRect(w: txtSize.width, h: txtSize.height).offsetBy(dx: 0, dy: 3)
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
            if let keyboard = superview as? NumKeyboardView{
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
