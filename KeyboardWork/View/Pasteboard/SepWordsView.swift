//
//  SepWordsView.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit

class SepWordsView: KeyboardNav {
    var words = [String]() {
        didSet {
            collectionView.reloadData()
            selectedWords = [String].init(repeating: "", count: words.count)
            keyboardVC?.previousPastedText = "" // 清空一下
        }
    }

    var word: String?
    var selectedWords = [String]()
    var selectIndex = Set<Int>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(44)
            make.bottom.equalTo(-40)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearWords() {
        for item in selectIndex {
            (collectionView.cellForItem(at: IndexPath(row: item, section: 0)) as? PanCollectionCell)?.isSelect = false
            selectedWords[item] = ""
        }
        selectIndex.removeAll()
    }
    
    func selectWord(index: Int, isSelect: Bool) {
        if isSelect {
            selectedWords.replaceSubrange(index...index, with: [words[index]])
            selectIndex.insert(index)
        } else {
            selectedWords.replaceSubrange(index...index, with: [""])
            selectIndex.remove(index)
        }
        NotificationCenter.default.post(name: .init("WGSendWord"), object: ["reset": selectedWords.joined()])
        if selectIndex.count > 0 {
          //  arrangeAction(actions: [.action("清空", false, nil)])
        } else {
          //  arrangeAction(actions: [])
        }
    }
    
//    override func actionClick(title: String) {
//        if title == "清空" {
//            clearWords()
//            NotificationCenter.default.post(name: .init("WGSendWord"), object: ["reset": selectedWords.joined()])
//        }
//        arrangeAction(actions: [])
//    }

//    override func send() {
//        super.send()
//        delay(time: 0.2) {
//            self.clearWords()
//            // self.nav.removeAction(act: .reset)
//        }
//    }
    
    lazy var collectionView: PanCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        let collection = PanCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(SelectWordCell.self, forCellWithReuseIdentifier: "SelectWordCell")
        collection.collectionViewLayout.perform(Selector(("_setRowAlignmentsOptions:")), with: NSDictionary(dictionary: ["UIFlowLayoutCommonRowHorizontalAlignmentKey": NSNumber(value: NSTextAlignment.left.rawValue), "UIFlowLayoutLastRowHorizontalAlignmentKey": NSNumber(value: NSTextAlignment.left.rawValue), "UIFlowLayoutRowVerticalAlignmentKey": NSNumber(value: NSTextAlignment.center.rawValue)]))
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        collection.canCancelContentTouches = false
        collection.allowsMultipleSelection = true
        return collection
    }()
}

extension SepWordsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = calculateStrwidth(withStr: words[indexPath.row], font: UIFont.systemFont(ofSize: 14))
        if width > collectionView.frame.size.width - 10 {
            width = collectionView.frame.size.width - 10
        } else {
            width = width + 10
        }
        return CGSize(width: width, height: 32)
    }
    
    func calculateStrwidth(withStr str: String?, font: UIFont?) -> CGFloat {
        var textRect: CGRect?
        if let font = font {
            textRect = str?.boundingRect(
                with: CGSize(width: CGFloat(MAXFLOAT), height: font.pointSize),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [
                    NSAttributedString.Key.font: font
                ],
                context: nil)
        }
        return ceil((textRect?.size.width)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectWordCell", for: indexPath) as! SelectWordCell
        cell.index = indexPath.row
        cell.lblWord.text = words[indexPath.row]
        cell.clickBlock = { [weak self] index, isselect in
            self?.selectWord(index: index, isSelect: isselect)
        }
//        cell.isSelected = selectIndex.contains(indexPath.row)
        cell.update(select: selectIndex.contains(indexPath.row))
        return cell
    }
}

class SelectWordCell: PanCollectionCell {
    var index = 0
    var clickBlock: ((_ index: Int, _ isSelect: Bool) -> Void)?

    override var isSelect: Bool {
        didSet {
            clickBlock?(index, isSelect)
            update(select: isSelect)
        }
    }
    
    func update(select: Bool) {
        if select {
            lblWord.layer.borderWidth = 0
            lblWord.backgroundColor = Colors.color49C167
            lblWord.textColor = UIColor.white
            lblWord.font = UIFont.pingfangMedium(size: 14)
        } else {
            lblWord.layer.borderWidth = 0.5
            lblWord.backgroundColor = UIColor.white
            lblWord.textColor = Colors.color626262
            lblWord.font = UIFont.pingfangRegular(size: 14)
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(lblWord)
        lblWord.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.width.equalTo(self).offset(-4)
            make.height.equalTo(24)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapGes(ges: UIGestureRecognizer) {
        isSelect = !isSelect
    }
    
    lazy var lblWord: UILabel = {
        let v = UILabel()
        v.layer.cornerRadius = 4
        v.layer.borderWidth = 0.5
        v.clipsToBounds = true
        v.layer.borderColor = UIColor(hexString: "202f64")!.withAlphaComponent(0.08).cgColor
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGes(ges:))))
        v.textColor = Colors.color626262
        v.textAlignment = .center
        v.font = UIFont.pingfangRegular(size: 14)
        return v
    }()
}
