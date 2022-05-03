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
    var lastSelectedCell = IndexPath()

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
            make.top.equalTo(300)
            make.height.equalTo(400)
        }
    }
    
    lazy var collectionView: PanCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        let collection = PanCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PopCell.self, forCellWithReuseIdentifier: "PopCell")
        collection.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutLastRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutRowVerticalAlignmentKey": NSNumber.init(value:NSTextAlignment.center.rawValue)]));
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        collection.canCancelContentTouches = false
        collection.allowsMultipleSelection = true

        
        return collection
    }()
    
    func selectCell(_ indexPath: IndexPath, selected: Bool) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if cell.isSelected {
                collectionView.deselectItem(at: indexPath, animated: true)
                collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
            } else {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
            }
            if let numberOfSelections = collectionView.indexPathsForSelectedItems?.count {
                print("选择了\(numberOfSelections)个元素")
            }
        }
    }
 
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell
        cell.titleLabel?.text = arrText[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = !(cell?.isSelected ?? true)
    }
    
}
class PopCell: UICollectionViewCell {
    var setView: UIView?
    var titleLabel: UILabel?
    var index = 0
    var tapBlock:((_ index:Int)->Void)?
    var pressBlock:((_ index:Int,_ pos:CGRect)->Void)?

    override var isSelected: Bool{
        didSet{
            if isSelected{
                titleLabel?.textColor = UIColor.red
            } else {
                titleLabel!.textColor = UIColor.init(hexString: "888888")
            }
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
  
        setView = UIView()
        
        setView?.isUserInteractionEnabled = true
        setView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGes(ges:))))
        
        contentView.addSubview(setView!)
        titleLabel = UILabel()
        titleLabel!.layer.cornerRadius = 14
        titleLabel!.layer.masksToBounds = true
        titleLabel?.layer.borderWidth = 0.5
        titleLabel!.backgroundColor = UIColor.lightText
        titleLabel!.font = UIFont.systemFont(ofSize: 14)
        titleLabel!.textAlignment = .center
        titleLabel!.textColor = UIColor.init(hexString: "888888")
        setView!.addSubview(titleLabel!)
        
        setView?.snp.makeConstraints({ (make) in
            make.left.right.top.bottom.equalTo(self)
        })
        titleLabel?.snp.makeConstraints({ (make) in
            make.center.equalTo(setView!)
            make.width.equalTo(self).offset(-8)
            make.height.equalTo(28)
        })
    }
    
    @objc func tapGes(ges:UIGestureRecognizer){
        tapBlock?(index)
    }
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
                    if cellForItem(at: index)?.isSelected ?? false{
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
                                cellForItem(at: path)?.isSelected = chooseMode
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
                            cellForItem(at: IndexPath(row: i, section: 0))?.isSelected = !chooseMode
                        }
                        
                        if index.row > lastSelectedCell!.row{
                            if let lastIndex = indexPath(for: visibleCells.last!){
                                if lastIndex.row - index.row < 10{
                                    if numberOfItems(inSection: 0) - lastIndex.row > 10{
                                        scrollToItem(at: IndexPath(row: lastIndex.row + 10, section: 0), at: .bottom, animated: true)
                                    } else {
                                        scrollToItem(at: IndexPath(row: numberOfItems(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
                                    }
                                }
                            }
                        }
                        if index.row < lastSelectedCell!.row{
                            if let firstIndex = indexPath(for: visibleCells.first!){
                                if index.row - firstIndex.row < 10{
                                    if index.row > 10{
                                        scrollToItem(at: IndexPath(row: index.row - 10, section: 0), at: .bottom, animated: true)
                                    } else {
                                        scrollToItem(at: IndexPath(row:  0, section: 0), at: .bottom, animated: true)
                                    }
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
