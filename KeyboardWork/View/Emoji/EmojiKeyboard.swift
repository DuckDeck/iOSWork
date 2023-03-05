//
//  EmojiKeyboard.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/26.
//

import Foundation
import UIKit
class EmojiKeyboard: Keyboard {
    var emoji = [Character]()
    var index = 1
    var btnBackWidth : CGFloat = 0
    var stackLeftMargin : CGFloat = 0
    let bottomIcons = ["icon_keyboard_emoji_used",
                       "icon_keyboard_emoji_face",
                       "icon_keyboard_emoji_animal",
                       "icon_keyboard_emoji_cup",
                       "icon_keyboard_emoji_ball",
                       "icon_keyboard_emoji_car",
                       "icon_keyboard_emoji_light",
                       "icon_keyboard_emoji_symble",
                       "icon_keyboard_emoji_flag",]
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboardName = "emoji页"
        currentKeyBoardType = .emoji
        switch UIDevice.current.deviceDirection{
        case .PhoneHor,.PadVer:
            keyWidth =  (kSCREEN_WIDTH - 36) / 13
            btnBackWidth = 62
            stackLeftMargin = 115
        case .PadHor:
            keyWidth =  (kSCREEN_WIDTH - 36) / 13
            btnBackWidth = 84
            stackLeftMargin = 300
        case .PhoneVer:
            keyWidth =  (kSCREEN_WIDTH - 36) / 8
            btnBackWidth = 42 * KBScale
            stackLeftMargin = 42 * KBScale
        }
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-6)
            make.height.equalTo(32)
        }
        
        bottomView.addSubview(btnBack)
        btnBack.snp.makeConstraints { make in
            make.left.bottom.equalTo(0)
            make.height.equalTo(32)
            make.width.equalTo(btnBackWidth)
        }
        
        
        bottomView.addSubview(bottomMenu)
        bottomMenu.snp.makeConstraints { make in
            make.centerX.equalTo(bottomView)
            make.left.equalTo(stackLeftMargin)
            make.right.equalTo(-stackLeftMargin)
        }
        
        bottomView.addSubview(btnDelete)
        btnDelete.snp.makeConstraints { make in
            make.right.bottom.equalTo(0)
            make.height.equalTo(32)
            make.width.equalTo(btnBackWidth)
        }
        
       
        
        
        for item in bottomIcons.enumerated() {
            let btn = UIButton()
            btn.tag = item.offset
           
            if item.offset == index {
                btn.backgroundColor = Colors.colorE5E7EB | Colors.colorE5E7EB.withAlphaComponent(0.2)
            }
            btn.setImage(UIImage.tintImage(item.element, color: UIColor.white), for: .normal)
            btn.layer.cornerRadius = 8
            btn.addTarget(self, action: #selector(menuClick(sender:)), for: .touchUpInside)
            bottomMenu.addArrangedSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(32)
            }
        }
  
        self.emoji = getEmojis() ?? [Character]()
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
        addSubview(popKeyView)
    }
    
    @objc func longPressGes(ges: UIGestureRecognizer) {
        switch ges.state {
        case .began:
            var key = KeyInfo()
            key.keyType = .del
            globalKeyboard?.keyLongPress(key: key, state: .began)
        case .ended, .cancelled:
            var key = KeyInfo()
            key.keyType = .del
            globalKeyboard?.keyLongPress(key: key, state: ges.state)

        default:
            break
        }
    }
    
    func getEmojis() -> [Character]? {
        var emojiPListFileName = "ISEmojiList_iOS10"
        if #available(iOS 11.0, *) { emojiPListFileName = "ISEmojiList_iOS11" }
        if #available(iOS 12.1, *) { emojiPListFileName = "ISEmojiList" }
        guard let filePath = Bundle.main.path(forResource: emojiPListFileName, ofType: "plist") else {
            return nil
        }
        
        guard let categories = NSArray(contentsOfFile: filePath) as? [[String: Any]] else {
            return nil
        }
        
        print(categories)
        
        let first = categories[index - 1]
        let emojis = (first["emojis"] as! [Any]).filter { item in
            item is String
        }
        return emojis.map { t in
            (t as! String).first!
        }
    }
    
    @objc func menuClick(sender: UIButton) {
        bottomMenu.arrangedSubviews[index].backgroundColor = UIColor.clear
        index = sender.tag
        sender.backgroundColor = Colors.colorE5E7EB | Colors.colorE5E7EB.withAlphaComponent(0.2)
        if index == 0 {
            emoji = getUsedEmoji()
        } else {
            emoji = getEmojis() ?? [Character]()
        }
        collectionView.reloadData()
        Shake.keyShake()
    }
    
    @objc func back(){
        var k = KeyInfo()
        k.keyType = .backKeyboard
        globalKeyboard?.keyPress(key: k)
    }
    
    @objc func del(){
        var key = KeyInfo()
        key.keyType = .del
        globalKeyboard?.keyPress(key: key)
    }
    
    func addUsedEmoji(e: Character) {
        var tmp = Store<String>.innerValue(key: "emoji") ?? ""
        if tmp.count > 50 {
            tmp.removeLast(tmp.count - 50)
        }
        var chs = [Character]()
        var index = -1
        for item in tmp.enumerated() {
            chs.append(item.element)
            if item.element == e {
                index = item.offset
            }
        }
        if index >= 0 {
            chs.remove(at: index)
        }
        chs.insert(e, at: 0)
        tmp = String(chs)
        Store<String>.setInnerValue(key: "emoji", value: tmp)
    }
    
    func getUsedEmoji() -> [Character] {
        let tmp = Store<String>.innerValue(key: "emoji") ?? ""
     
        var chs = [Character]()
        for item in tmp {
            chs.append(item)
        }
        return chs
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bottomView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var bottomMenu: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .equalSpacing
        v.alignment = .center
        return v
    }()
    
    lazy var popKeyView: PopKeyView = {
        let v = PopKeyView(frame: CGRect(x: 0, y: 0, width: 78, height: 85))
        v.image = UIImage(named: "icon_key_pop_emoji")
        v.isHidden = true
        return v
    }()
    
    lazy var btnBack: UIButton = {
        let v = UIButton()
        v.setTitle("返回", for: .normal)
        v.setTitleColor(cKeyTextColor, for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 15)
        v.addTarget(self, action: #selector(back), for: .touchUpInside)
        return v
    }()

    lazy var btnDelete: UIButton = {
        let v = UIButton()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
        longPress.minimumPressDuration = 0.4
        v.addGestureRecognizer(longPress)
        v.setImage(UIImage.tintImage("icon_keyboard_emoji_delete", color: UIColor.white), for: .normal)
        v.addTarget(self, action: #selector(del), for: .touchUpInside)
        return v
    }()
    
    lazy var collectionView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = keyboardBgColor
        v.delaysContentTouches = false
        v.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        return v
    }()
    
    func showPopView(cell: EmojiCell, state: UIGestureRecognizer.State) {
        let emoji = cell.lbl.text!
        addUsedEmoji(e: emoji.first!)
        let pos = collectionView.convert(cell.frame, to: self)
        switch state {
        case .began:
            popKeyView.setKey(key: emoji, location: .center, fontsize: nil, keyTop: -2)
            popKeyView.center = pos.offsetBy(dx: 0, dy: -25).center
            popKeyView.isHidden = false
            Shake.keyShake()
        case .ended:
            globalKeyboard?.output(text: emoji)
            globalKeyboard?.keyboard?.updateStatus(.normal(true))
//            globalHeader?.showSearch()
            popKeyView.isHidden = true
        // popKeyView.isHidden = true
        case .cancelled:
            popKeyView.isHidden = true
        default:
            break
        }
    }
}

extension EmojiKeyboard: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.lbl.text = String(emoji[indexPath.row])
        cell.backgroundColor = UIColor("d1d5db")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: keyWidth, height: keyWidth)
    }
}

class EmojiCell: UICollectionViewCell {
    var touchBlock: ((_ state: UIGestureRecognizer.State) -> Void)?
        
    var emojiKeyboard: EmojiKeyboard? {
        return globalKeyboard?.keyboard as? EmojiKeyboard
    }
    
    let lbl = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(lbl)
        contentView.isUserInteractionEnabled = true
        lbl.backgroundColor = keyboardBgColor
        if kSCREEN_WIDTH <= 320{
            lbl.font = UIFont.systemFont(ofSize: 32 * (kSCREEN_WIDTH / 375))
        } else {
            lbl.font = UIFont.systemFont(ofSize: 32)
        }
        lbl.textAlignment = .center
        lbl.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emojiKeyboard?.showPopView(cell: self, state: .began)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        emojiKeyboard?.showPopView(cell: self, state: .ended)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        emojiKeyboard?.showPopView(cell: self, state: .cancelled)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
