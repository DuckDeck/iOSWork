//
//  NineKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit



class NineKeyboardView: Keyboard {
    var popChooseView: PopKeyChooseView?
    
    var pressedKey: KeyInfo?
    var panPoint: CGPoint?
    var previousPoint: CGPoint?
    var isGesture = false
    var panPosition: CGPoint?

    
    var keyTop : CGFloat = 0            //该行按键的上边
    var keyIndent1 : CGFloat = 0        //缩进1
    var keyIndent2 : CGFloat = 0        //缩进2
    var keyUnitWidth : CGFloat = 0      //单元长度，按键长度是这个的比例
    var keyCenterHeight : CGFloat = 0   //中央按键的宽度
    
    var rowRanges = [CGFloat]()
    var ranges = [[CGFloat]]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboardName = "中文9键键盘页"
        self.currentKeyBoardType = .chinese9
        backgroundColor = UIColor(named: "keyboard_bg_color")!
        keyboardWidth = kSCREEN_WIDTH
        
        createLayout()
        createKeys()
        createRange()
        createBoard()
        createGesture()
        
        addSubview(popKeyView)
    }
    
    func createLayout(){
        if UIDevice.current.userInterfaceIdiom == .pad{         //pad参数
           keyWidth = (kSCREEN_WIDTH - 117.5) / 10
           keyHeight = 54
           keyTopMargin = 8
           keyHorGap = 8
           keyVerGap = 11.5
           keyIndent1 = 6
        } else {
            if UIDevice.orientation.rawValue > 2{              //横屏参数
                keyWidth = (kSCREEN_WIDTH - 71) / 10
                keyHeight = ((kSCREEN_HEIGHT * 0.6) - 90) * 0.2
                keyTopMargin = 8
                keyHorGap = 7
                keyVerGap = 7
                keyIndent1 = 4
            } else {                                           //竖屏参数
                keyWidth = (kSCREEN_WIDTH - 53) / 10
                keyHeight = kSCREEN_WIDTH > 400 ? 44 : 40
                keyTopMargin = 10
                keyHorGap = 5
                keyVerGap = 5
                keyIndent1 = 4
            }
        }
        keyUnitWidth = (kSCREEN_WIDTH - 2 * keyIndent1 - 4 * keyHorGap) / 13
        keyIndent2 = keyUnitWidth * 2 + keyIndent1 + keyHorGap
        keyCenterHeight = (globalKeyboardHeight.boardHeight - keyHeight * 2 - keyTopMargin - 4 - 4 * keyVerGap) / 3
        keyTop = keyTopMargin
    }
    
    func createKeys(){
        let f = ["1","2","3","4","5","6","7","8","9","0"]
        var numKeys = [KeyInfo]()
        for item in f.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            k.fontSize = 20
            k.position = CGRect(x: CGFloat(item.offset) * (keyWidth + keyHorGap) + keyIndent1, y: keyTop, width: keyWidth, height: keyHeight)
            k.keyType = .normal(.character)
            numKeys.append(k)
        }
        keyTop += keyHeight + keyVerGap
        keys.append(numKeys)
        
        var row2 = [KeyInfo]()
        var row3 = [KeyInfo]()
        var row4 = [KeyInfo]()
        var row5 = [KeyInfo]()
        let keyTexts = ["@/.","ABC","DEF","GHI","JKL","MNO","PQRS","TUV","WXYZ"]
        for item in keyTexts.enumerated(){
            var k = KeyInfo()
            k.text = item.element
            k.tip = "\(item.offset + 1)"
            if item.offset == 0{
                k.keyType = .separate
            }
            k.fillColor = cKeyBgColor
            k.textColor = cKeyTextColor
            let r = item.offset / 3
            let c = item.offset % 3
            k.position = CGRect(x: keyIndent2 + (keyUnitWidth * 3 + keyHorGap) * CGFloat(c), y: keyTop + (keyCenterHeight + keyVerGap) * CGFloat(r), width: keyUnitWidth * 3, height: keyCenterHeight)
            if r == 0{
                row2.append(k)
            } else if r == 1{
                row3.append(k)
            } else {
                row4.append(k)
            }
        }
        
        var delKey = KeyInfo()
        delKey.position = CGRect(x: row2.last!.position.maxX + keyHorGap, y: row2.last!.position.minY, width: keyUnitWidth * 2, height: keyCenterHeight)
        delKey.image = "icon_key_delete"
        delKey.fillColor = cKeyBgColor2
        delKey.keyType = .del
        row2.append(delKey)
        
        var reInputKey = KeyInfo()
        reInputKey.position = CGRect(x: row3.last!.position.maxX + keyHorGap, y: row3.last!.position.minY, width: keyUnitWidth * 2, height: keyCenterHeight)
        reInputKey.text = "换行"
        reInputKey.fillColor = cKeyBgColor2
        reInputKey.textColor = cKeyTextColor
        reInputKey.keyType = .newLine
        row3.append(reInputKey)
        
        var zeroKey = KeyInfo()
        zeroKey.position = CGRect(x: row4.last!.position.maxX + keyHorGap, y: row4.last!.position.minY, width: keyUnitWidth * 2, height: keyCenterHeight)
        zeroKey.image = "icon_key_emoji"
        zeroKey.keyType = .switchKeyboard(.emoji)
        zeroKey.fillColor = cKeyBgColor2
        row4.append(zeroKey)
        
        var symbleKey = KeyInfo()
        symbleKey.text = "符"
        symbleKey.textColor = cKeyTextColor
        symbleKey.fillColor = cKeyBgColor2
        symbleKey.position = CGRect(x: keyIndent1, y: row4.first!.position.maxY + keyVerGap, width: keyUnitWidth * 2, height: keyHeight)
        symbleKey.keyType = .switchKeyboard(.symbleChiese)
        row5.append(symbleKey)
        
        var numKey = KeyInfo()
        numKey.text = "123"
        numKey.textColor = cKeyTextColor
        numKey.fillColor = cKeyBgColor2
        numKey.position = CGRect(x: symbleKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: keyUnitWidth * 2, height: keyHeight)
        numKey.keyType = .switchKeyboard(.number)
        row5.append(numKey)
        
        var spaceKey = KeyInfo()
        spaceKey.image = "icon_key_space"
        spaceKey.fillColor = cKeyBgColor
        spaceKey.position = CGRect(x: numKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: keyUnitWidth * 5, height: keyHeight)
        spaceKey.keyType = .space
        row5.append(spaceKey)
        
        var switchKey = KeyInfo()
        switchKey.image = "icon_key_ch_en_switch"
        switchKey.fillColor = cKeyBgColor2
        switchKey.position = CGRect(x: spaceKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: keyUnitWidth * 2, height: keyHeight)
        switchKey.keyType = .switchKeyboard(.english)
        row5.append(switchKey)
        
        var enterKey = ReturnKey
        enterKey.position = CGRect(x: switchKey.position.maxX + keyHorGap, y: symbleKey.position.minY, width: keyUnitWidth * 2, height: keyHeight)
        row5.append(enterKey)
        
        keys.append(row2)
        keys.append(row3)
        keys.append(row4)
        keys.append(row5)
    }
    
    func createRange(){
        for row in keys{
            rowRanges.append(row.first!.position.maxY + keyVerGap / 2)
            var tmp = [CGFloat]()
            for item in row{
                tmp.append(item.position.maxX + keyVerGap / 2)
            }
            ranges.append(tmp)
        }
    }
    
    override func createBoard(){
        addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalTo(keyIndent1)
            make.top.equalTo(keyHeight + keyTopMargin + keyVerGap)
            make.width.equalTo(keyUnitWidth * 2)
            make.bottom.equalTo(-(4 + keyHeight + keyVerGap))
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
                    imgLayer.frame = k.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
                    imgLayer.contents = img.cgImage
                    keys[i][j].imgLayer = imgLayer
                    layer.addSublayer(imgLayer)
                }
                
                if !k.text.isEmpty {
                    let lbl = UILabel()
                    lbl.text = k.text
                    lbl.font = UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)
                    let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
                    let txtLayer = CATextLayer()
                    txtLayer.frame = k.position.centerRect(w: txtSize.width, h: txtSize.height)
                    txtLayer.foregroundColor = k.textColor.cgColor
                    txtLayer.string = k.text
                    txtLayer.contentsScale = UIScreen.main.scale
                    txtLayer.font = CGFont("PingFangSC-Regular" as CFString)
                    txtLayer.fontSize = 18 * KBScale
                    keys[i][j].textLayer = txtLayer
                    layer.addSublayer(txtLayer)
                }
            }
        }
    }
    
    func createGesture(){
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(ges:)))
        addGestureRecognizer(pan)
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
        if key.keyType.isNormal {
            SensorEvent(name: "srf_buttonpress", property: ["srf_button_name": "基础键盘字符按键点击"]).write()
        }
    }
    
    override func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {
        delegate?.keyLongPress(key: key, state: state)
    }
    
    // 可以把更新分词状态放这里
    func updateReInput(key: KeyInfo) {
//        rightView.updateReInputKey(newKey: key)
//        centerView.updateSeqWord()
        let i = 2,j=3
        keys[i][j].keyLayer?.removeFromSuperlayer()
        keys[i][j].keyLayer = nil
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
        
        if !tmpKey.text.isEmpty {
            let lbl = UILabel()
            lbl.text = tmpKey.text
            lbl.font = UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 18))
            let txtLayer = CATextLayer()
            txtLayer.frame = tmpKey.position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.foregroundColor = tmpKey.textColor.cgColor
            txtLayer.string = tmpKey.text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = CGFont("PingFangSC-Regular" as CFString)
            txtLayer.fontSize = 18 * KBScale
            keys[i][j].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
        
        let p = 1,q = 0
        var changeSep = false
        if globalheader?.isHavePinYin ?? false {
            if keys[p][q].text != "分词" {
                keys[p][q].textLayer?.removeFromSuperlayer()
                keys[p][q].textLayer = nil
                keys[p][q].text = "分词"
                changeSep = true
            }
        } else {
            if keys[p][q].text == "分词" {
                keys[p][q].textLayer?.removeFromSuperlayer()
                keys[p][q].textLayer = nil
                keys[p][q].text = "@/."
                changeSep = true
            }
        }
        if changeSep {
            let lbl = UILabel()
            lbl.text = keys[p][q].text
            lbl.font = UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
            let txtLayer = CATextLayer()
            txtLayer.frame = keys[p][q].position.centerRect(w: txtSize.width, h: txtSize.height)
            txtLayer.foregroundColor = keys[p][q].textColor.cgColor
            txtLayer.string = keys[p][q].text
            txtLayer.contentsScale = UIScreen.main.scale
            txtLayer.font = CGFont("PingFangSC-Regular" as CFString)
            txtLayer.fontSize = 18 * KBScale
            keys[p][q].textLayer = txtLayer
            layer.addSublayer(txtLayer)
        }
        
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
            boardStatus = status
            updateReturnKey(key: ReturnKey)
            updateReInput(key: ReInputKey)
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
            imgLayer.frame = tmpKey.position.centerRect(w: img.size.width * KBScale, h: img.size.height * KBScale)
            imgLayer.contents = img.cgImage
            keys[i][j].imgLayer = imgLayer
            layer.addSublayer(imgLayer)
        }
        
        if !tmpKey.text.isEmpty{
            let lbl = UILabel()
            lbl.text = tmpKey.text
            lbl.font = UIFont(name: "PingFangSC-Regular", size: 18 * KBScale)
            let txtSize = lbl.sizeThatFits(CGSize(width: 100, height: 26))
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
    
    lazy var popKeyView: PopKeyView = {
        var width = 79.5
        if kSCREEN_WIDTH == 414 {
            width = 80
        } else if kSCREEN_WIDTH == 428 {
            width = 80.5
        }
        let v = PopKeyView(frame: CGRect(x: 0, y: 0, width: width * KBScale, height: 95 * KBScale))
        v.isHidden = true
        return v
    }()
    

    
    lazy var leftView: NineKeyLeftView = {
        let v = NineKeyLeftView(keys: ["，", "。", "？", "！", "...", "~", "'", "、", "_"])
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
        if let keyboard = superview as? NineKeyboardView {
            var key = KeyInfo()
            key.keyType = .normal(keyType)
            key.text = keys[indexPath.row]
            key.index = indexPath.row
            keyboard.keyPress(key: key)
            Shake.keyShake()
        }
    }
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(keys: [String]) {
        self.init(frame: CGRect.zero)
        self.keys = keys
        let xScale = (kSCREEN_WIDTH - 28) / 347.0
        let shadowLayer = CAShapeLayer()
        let shadowRect = CGRect(x: 0, y: 145 * KBScale, width: 52.0 * xScale, height: 6 * KBScale)
        shadowLayer.fillColor = cKeyShadowColor.cgColor
        shadowLayer.path = UIBezierPath(roundedRect: shadowRect, cornerRadius: 5).cgPath
        layer.addSublayer(shadowLayer)
        
        addSubview(tb)
        tb.snp.makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(150 * KBScale)
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
        v.separatorInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        v.delegate = self
        v.dataSource = self
        v.rowHeight = 35
        v.separatorStyle = .none
        v.backgroundColor = cKeyBgColor2
        v.register(LeftToolViewCell.self, forCellReuseIdentifier: "NineCell")
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
        v.font = UIFont.systemFont(ofSize: 18 * KBScale)
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
