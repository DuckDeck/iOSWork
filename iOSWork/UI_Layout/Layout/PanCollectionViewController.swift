//
//  PanCollectionViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/4/14.
//

import UIKit

class PanCollectionViewController: UIViewController {
    var selectMode = false
    var arrText = [String]()

    var selectIndex = Set<Int>()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "手势Collection"
        arrText.append("确实，")
        arrText.append("HTP了")
        arrText.append("。。")
        arrText.append("功耗也上来了")
        arrText.append("我也是折腾过来的")
        arrText.append("，最初是")
        arrText.append("3400G做HTPC")
        arrText.append("，反复开关，或待机休眠")
        arrText.append("启动太慢，体验不好")
        arrText.append("后来")
        arrText.append("换了一放器")
        arrText.append("不playe么")
        arrText.append("HDR")
        arrText.append("效果很差，")
        arrText.append("屏幕一层纱")
        arrText.append("我对画面")
        arrText.append("要求并不高")
        arrText.append("可能是看惯了")
        arrText.append("3400G")
        arrText.append("反而很不适")
        arrText.append("这机的HTPC")
        arrText.append("这样")
        arrText.append("顺理成章")
        arrText.append("把软路由集成进了")
        arrText.append("其实。")
        arrText.append("后来")
        arrText.append("换了一个器")
        arrText.append("不怎么")
        arrText.append("HDR")
        arrText.append("效果很差，")
        arrText.append("屏幕像罩了一层纱")
        arrText.append("我对画面")
        arrText.append("要求并不高")
        arrText.append("可能是看惯了")
        arrText.append("3400G")
        arrText.append("反而很不适")
        arrText.append("这才换成不C")
        arrText.append("这样")
        arrText.append("顺理成")
        arrText.append("成进去了")
        arrText.append("其实痛C。。")
        arrText.append("换了一放器")
        arrText.append("不playe么")
        arrText.append("HDR")
        arrText.append("效差，")
        arrText.append("屏幕一层纱")
        arrText.append("我对画面")
        arrText.append("要求并高")
        arrText.append("可能是看惯了")
        arrText.append("3400G")
        arrText.append("反")
        arrText.append("这机的HTPC")
        arrText.append("这样")
        arrText.append("顺理成")
        arrText.append("成进去了")
        arrText.append("其实痛C。。")
        arrText.append("换了一放器")
        arrText.append("不playe么")
        arrText.append("HDR")
        arrText.append("效差，")
        arrText.append("屏幕一层纱")
        arrText.append("我对画面")
        arrText.append("要求并高")
        arrText.append("可能是看惯了")
        arrText.append("3400G")
        arrText.append("反")
        arrText.append("这机的HTPC")
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(200)
            make.height.equalTo(300)
        }
    }
    
    
    func selectWord(index:Int,isSelect:Bool)  {
        if isSelect {
            selectIndex.insert(index)
        }
        else{
            selectIndex.remove(index)
        }
      
    }
    
    lazy var collectionView: PanCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        let collection = PanCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(SelectWordCell.self, forCellWithReuseIdentifier: "SelectWordCell")
        collection.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutLastRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutRowVerticalAlignmentKey": NSNumber.init(value:NSTextAlignment.center.rawValue)]));
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        collection.canCancelContentTouches = false
        collection.allowsMultipleSelection = true
        return collection
    }()
    
 
 
}

extension PanCollectionViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemHeight = calculateStrwidth(withStr: arrText[indexPath.row], font: UIFont.systemFont(ofSize: 14))
        if itemHeight > collectionView.frame.size.width - 10 {
            itemHeight = collectionView.frame.size.width - 10
        } else {
            itemHeight = itemHeight + 20
        }
        return CGSize(width: itemHeight, height: 28)
    }
    
    func calculateStrwidth(withStr str: String?, font: UIFont?) -> CGFloat {
        var textRect: CGRect? = nil
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
        cell.lblWord.text = arrText[indexPath.row]
        cell.update(select: selectIndex.contains(indexPath.row))
        cell.clickBlock = {(index,isSelect) in
            self.selectWord(index: index, isSelect: isSelect)
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = !(cell?.isSelected ?? true)
    }
    
}


class SelectWordCell:PanCollectionCell{
    var index = 0
    var clickBlock:((_ index:Int,_ isSelect:Bool)->Void)?

    override var isSelect: Bool{
        didSet{
            clickBlock?(index,isSelect)
            update(select: isSelect)
        }
    }
    
    func update(select:Bool){
        if select{
            lblWord.layer.borderWidth = 0
            lblWord.backgroundColor = kColor49c167
            lblWord.textColor = UIColor.white
        } else {
            lblWord.layer.borderWidth = 0.5
            lblWord.backgroundColor = UIColor.white
            lblWord.textColor = kColor626266
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(lblWord)
        lblWord.snp.makeConstraints({ (make) in
            make.center.equalTo(contentView)
            make.width.equalTo(self).offset(-8)
            make.height.equalTo(28)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapGes(ges:UIGestureRecognizer){
        isSelect = !isSelect
    }
    
    lazy var lblWord: UILabel = {
        let v = UILabel()
        v.layer.cornerRadius = 3
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.gray.cgColor
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGes(ges:))))
        v.textColor = kColor626266
        v.textAlignment = .center
        v.font = UIFont.pingfangRegular(size: 14)
        return v
    }()
}




class PanCollectionView:UICollectionView{
    
    var selectMode = false
    var lastSelectedCell : IndexPath?
    var chooseMode = true //根据第一个选择的来决定是选择还是取消选择,true 是选择，false是取消选择
    var arrSelectedIndex = [IndexPath]()
    var firstSelectIndex : IndexPath?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        lastSelectedCell = nil
        firstSelectIndex = nil
        arrSelectedIndex.removeAll()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.randomElement()?.location(in: self){
            if let index = self.indexPathForItem(at: point){
                if lastSelectedCell == nil{
                    if (cellForItem(at: index) as? PanCollectionCell)?.isSelect ?? false{
                        chooseMode = false
                    } else {
                        chooseMode = true
                    }
                }
                if lastSelectedCell == nil || index != lastSelectedCell!{
                    //获取甩的cell
                    if lastSelectedCell != nil{
                        let small = min(index.row, lastSelectedCell!.row)
                        let big = max(index.row, lastSelectedCell!.row)
                        for i in small...big{
                            let path =  IndexPath(row: i, section: 0)
                            if !arrSelectedIndex.contains(path){
                                arrSelectedIndex.append(path)
                                (cellForItem(at: path) as? PanCollectionCell)?.isSelect = chooseMode
                            }
                        }
                        
                        let fSmall = min(index.row, firstSelectIndex!.row)
                        let fBig = max(index.row, firstSelectIndex!.row)

                        var ids = [Int]()
                        for i in arrSelectedIndex{
                            if fSmall > i.row || fBig < i.row{
                                ids.append(i.row)
                            }
                        }
                        
                        arrSelectedIndex.removeWith { e in
                            ids.contains(e.row)
                        }
                        for i in ids{
                            (cellForItem(at: IndexPath(row: i, section: 0)) as? PanCollectionCell)?.isSelect = !chooseMode
                        }
                        
                        if index.row > lastSelectedCell!.row{
                            if point.y - contentOffset.y > frame.size.height - 50{
                                if numberOfItems(inSection: 0) - index.row > 10{
                                    scrollToItem(at: IndexPath(row: index.row + 10, section: 0), at: .bottom, animated: true)
                                } else {
                                    scrollToItem(at: IndexPath(row: numberOfItems(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
                                }
                            }
                        }
                        if index.row < lastSelectedCell!.row{
                            if point.y - contentOffset.y < 50{
                                if index.row > 10{
                                    scrollToItem(at: IndexPath(row: index.row - 10, section: 0), at: .bottom, animated: true)
                                } else {
                                    scrollToItem(at: IndexPath(row:  0, section: 0), at: .bottom, animated: true)
                                }
                            }
                        }
                    }
                    lastSelectedCell = index
                    if firstSelectIndex == nil{
                        firstSelectIndex = index
                    }
                }
                
            }
        }

    }
}

class PanCollectionCell:UICollectionViewCell{
    var isSelect:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
//    override var isSelected: Bool  为什么要自定义一个，因为在滑动Cell时会自己调用isSelected，导致异常，所以要自己定义一个isSelect
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
