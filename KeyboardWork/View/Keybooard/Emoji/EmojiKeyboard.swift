//
//  EmojiKeyboard.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/17.
//

import Foundation
class EmojiKeyboard:Keyboard{
    var emoji = [Character]()
    var index = 1
    let itemWidth =  (kSCREEN_WIDTH - 36) / 8
    let bottomIcons = ["返回","icon_keyboard_emoji_used",
                        "icon_keyboard_emoji_face",
                        "icon_keyboard_emoji_animal",
                        "icon_keyboard_emoji_cup",
                        "icon_keyboard_emoji_ball",
                        "icon_keyboard_emoji_car",
                        "icon_keyboard_emoji_light",
                        "icon_keyboard_emoji_symble",
                        "icon_keyboard_emoji_flag",
                        "icon_keyboard_emoji_delete"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bottomMenu)
        bottomMenu.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-6.5)
            make.height.equalTo(31)
        }
        
        
        
        for item in bottomIcons.enumerated(){
            let btn = UIButton()
            btn.tag = item.offset
            if item.offset == 0{
                btn.setTitleColor(Colors.color222222, for: .normal)
                btn.setTitle(item.element, for: .normal)
                btn.titleLabel?.font = UIFont.pingfangMedium(size: 15)
            } else if item.offset == 11{
                
                btn.setImage(UIImage(named: item.element), for: .normal)
            } else {
                btn.setImage(UIImage(named: item.element), for: .normal)
                btn.layer.cornerRadius = 8
            }
            btn.addTarget(self, action: #selector(menuClick(sender:)), for: .touchUpInside)
            bottomMenu.addArrangedSubview(btn)
            btn.snp.makeConstraints { make in
                if item.offset == 0 || item.offset == 19{
                    make.width.equalTo(44)
                    make.height.equalTo(31)
                } else {
                    make.width.height.equalTo(31)
                }
            }
        }
        
        bottomMenu.addArrangedSubview(UIView())
        
        self.emoji = getEmojis() ?? [Character]()

        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
    }
    
    func getEmojis()->[Character]?{
        var emojiPListFileName = "ISEmojiList_iOS10";
        if #available(iOS 11.0, *) { emojiPListFileName = "ISEmojiList_iOS11" }
        if #available(iOS 12.1, *) { emojiPListFileName = "ISEmojiList" }
        guard let filePath = Bundle.main.path(forResource: emojiPListFileName, ofType: "plist") else {
           return nil
        }
        
        guard let categories = NSArray(contentsOfFile: filePath) as? [[String:Any]] else {
            return nil
        }
        
        print(categories)
        
        let first = categories[index - 1]
        let emojis = (first["emojis"] as! Array<Any>).filter { item in
            return item is String
        }
        return emojis.map({ t in
            (t as! String).first!
        })
    }
    
    @objc func menuClick(sender:UIButton){
        if sender.tag == 0{
            globalKeyboard?.switchKeyboard(keyboardType: KeyboardInfo.KeyboardType)
        }else if sender.tag == 10{
            var key = KeyInfo()
            key.keyType = .del
            globalKeyboard?.keyPress(key: key)
        } else {
            if index == sender.tag - 1{
                return
            }
    
            bottomMenu.arrangedSubviews[index + 1].backgroundColor = UIColor.clear
            index = sender.tag - 1
            sender.backgroundColor = UIColor("dddddd")
            
            if index == 0{
                self.emoji = getUsedEmoji()
            } else {
                self.emoji = getEmojis() ?? [Character]()
            }
            
            collectionView.reloadData()
        }
    }
    
    func addUsedEmoji(e:Character){
        var tmp = Store<String>.innerValue(key: "emoji") ?? ""
        if tmp.count > 50{
            tmp.removeLast(tmp.count - 50)
        }
        var chs = [Character]()
        var index = -1
        for item in tmp.enumerated(){
            chs.append(item.element)
            if item.element == e{
                index = item.offset
            }
        }
        if index >= 0{
            chs.remove(at: index)
        }
        chs.insert(e, at: 0)
        tmp = String(chs)
        Store<String>.setInnerValue(key: "emoji", value: tmp)
    }
    
    func getUsedEmoji()->[Character]{
        let tmp = Store<String>.innerValue(key: "emoji") ?? ""
     
        var chs = [Character]()
        for item in tmp{
            chs.append(item)
        }
        return chs
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bottomMenu: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .equalSpacing
        return v
    }()
    
    
    lazy var collectionView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let v = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = UIColor("d1d5db")
        v.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        v.backgroundColor = UIColor.white
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.dataSource = self
        v.delegate = self
        
        v.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        return v
    }()
    
}

extension EmojiKeyboard:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.lbl.text = String(emoji[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: itemWidth, height: itemWidth);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = emoji[indexPath.row]
        addUsedEmoji(e: c)
        keyboardVC?.insert(text: String(c))
    }
}

class EmojiCell:UICollectionViewCell{
    let lbl = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(lbl)
        lbl.font = UIFont.systemFont(ofSize: 36)
        lbl.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
