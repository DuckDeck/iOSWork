//
//  PanCollectionViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/4/14.
//

import UIKit

class PanCollectionViewController: UIViewController {
    var arrText = [String]()
    var lastSelectedCell = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "手势Collection"
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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PopCell.self, forCellWithReuseIdentifier: "PopCell")
        collection.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutLastRowHorizontalAlignmentKey": NSNumber.init(value:NSTextAlignment.left.rawValue), "UIFlowLayoutRowVerticalAlignmentKey": NSNumber.init(value:NSTextAlignment.center.rawValue)]));
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.white
        //collection.isUserInteractionEnabled = true
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
                print("选择了\(numberOfSelections)个元素")
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



