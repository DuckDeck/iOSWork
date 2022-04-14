//
//  PopViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/4/7.
//

import Foundation
import UIKit
class PopViewController:UIViewController{
    
    let inputText = InputText()
    var arrText = [String]()
    var lastSelectedCell = IndexPath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        
        
        let contentView = UIView()
        let lbl = UILabel()
        lbl.text = "我要测试一下这个气泡"
        lbl.textColor = UIColor.white
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        contentView.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-22)
            make.top.bottom.equalTo(0)
            make.height.equalTo(30)
        }
        
        let popView = PopHintView(tranOffset: 0.5, direction: .top, contentView: contentView)
        view.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(120)
        }
        
        
        
        let btnAddText = UIButton()
        btnAddText.setTitle("添加文字", for: .normal)
        btnAddText.setTitleColor(UIColor.black, for: .normal)
        btnAddText.addTarget(self, action: #selector(addText), for: .touchUpInside)
        view.addSubview(btnAddText)
        btnAddText.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(160)
        }
        
        let btnRemoveText = UIButton()
        btnRemoveText.setTitleColor(UIColor.black, for: .normal)
        btnRemoveText.setTitle("删除文字", for: .normal)
        btnRemoveText.addTarget(self, action: #selector(removeText), for: .touchUpInside)
        view.addSubview(btnRemoveText)
        btnRemoveText.snp.makeConstraints { make in
            make.left.equalTo(200)
            make.top.equalTo(150)
        }
        
        
        view.addSubview(inputText)
        inputText.placeHolder = "标签名字支持任意字符或emoji"
        inputText.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        inputText.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.top.equalTo(200)
            make.height.equalTo(44)
        }
        
//       let btnHead = LayoutButton()
//        btnHead.addBorder()
//        btnHead.imageSize = CGSize(width: 12, height: 12)
//        btnHead.layoutStyle = .LeftImageRightTitle
//        btnHead.midSpacing = 2
//        btnHead.setTitle("我夺夺夺", for: .normal)
//        btnHead.setImage(UIImage(named: "5"), for: .normal)
//        btnHead.textLine = 1
//        btnHead.imageView?.layer.cornerRadius = 6
//
//        btnHead.setTitleColor(UIColor.red, for: .normal)
//        btnHead.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//        contentView.addSubview(btnHead)
//        btnHead.snp.makeConstraints { make in
//            make.left.equalTo(16)
//            make.top.equalTo(300)
//            make.height.equalTo(17)
//        }
//        delay(time: 0.5) {
//            btnHead.sizeFit()
//        }
        "确实，HTPC一下子把配置的要求拉上来了。。功耗也上来了。。我也是折腾过来的，最初是3400G做HTPC，反复开关，或待机休眠，启动太慢，体验不好；后来换了一个S905X3做播放器，不知是用的MXplayer不对还是怎么，HDR效果很差，屏幕像罩了一层纱，我对画面要求并不高，可能是看惯了3400G的画面，反而很不适，这才换成NUC11做永不关机的HTPC，这样顺理成章的把软路由集成进去了；其实痛点还是HTPC。。"
        arrText.append("确实，")
        arrText.append("HTPC一下子把配置的要求拉上来了")
        arrText.append("。。")
        arrText.append("功耗也上来了")
        arrText.append("我也是折腾过来的")
        arrText.append("，最初是")
        arrText.append("3400G做HTPC")
        arrText.append("，反复开关，或待机休眠")
        arrText.append("启动太慢，体验不好")
        arrText.append("后来")
        arrText.append("换了一个S905X3做播放器")
        arrText.append("不知是用的MXplayer不对还是怎么")
        arrText.append("HDR")
        arrText.append("效果很差，")
        arrText.append("屏幕像罩了一层纱")
        arrText.append("我对画面")
        arrText.append("要求并不高")
        arrText.append("可能是看惯了")
        arrText.append("3400G")
        arrText.append("反而很不适")
        arrText.append("这才换成NUC11做永不关机的HTPC")
        arrText.append("这样")
        arrText.append("顺理成章")
        arrText.append("把软路由集成进去了")
        arrText.append("其实痛点还是HTPC。。")
        
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(300)
            make.height.equalTo(400)
        }
        
        
    }
    
    @objc func addText(){
        inputText.insertText(text: "我来测试")
    }
    
    @objc func removeText(){
        _ = inputText.deleteText()
    }
    
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PopCell.self, forCellWithReuseIdentifier: "PopCell")
        collection.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutLastRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutRowVerticalAlignmentKey": NSNumber.init(value:NSTextAlignment.center.rawValue)]));
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        collection.isUserInteractionEnabled = true
        collection.canCancelContentTouches = false
        collection.allowsMultipleSelection = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
        panGesture.delegate = self
        collection.addGestureRecognizer(panGesture)
        
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
                title = "\(numberOfSelections) items selected"
            }
        }
    }
    
    @objc func didPan(panGesture: UIPanGestureRecognizer) {
   
        if panGesture.state == .began {
            collectionView.isUserInteractionEnabled = false
            collectionView.isScrollEnabled = false
        }
        else if panGesture.state == .changed {
            let location: CGPoint = panGesture.location(in: collectionView)
            if let indexPath: IndexPath = collectionView.indexPathForItem(at: location) {
                if indexPath != lastSelectedCell {
                    self.selectCell(indexPath, selected: true)
                    lastSelectedCell = indexPath
                }
            }
        } else if panGesture.state == .ended {
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
        }
        
    }
    

}

extension PopViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
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
//        titleLabel?.layer.borderColor = UIColor.init(hexString: "ebebeb")?.cgColor
        titleLabel!.backgroundColor = UIColor.lightText
        titleLabel!.font = UIFont.systemFont(ofSize: 14)
        titleLabel!.textAlignment = .center
        titleLabel!.textColor = UIColor.init(hexString: "888888")
        setView!.addSubview(titleLabel!)
        
        setView?.snp_makeConstraints({ (make) in
            make.left.right.top.bottom.equalTo(self)
        })
        titleLabel?.snp_makeConstraints({ (make) in
            make.center.equalTo(setView!)
            make.width.equalTo(self).offset(-8)
            make.height.equalTo(28)
        })
    }
    
    @objc func tapGes(ges:UIGestureRecognizer){
        tapBlock?(index)
    }
    
   
}
