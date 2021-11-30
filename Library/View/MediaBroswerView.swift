//
//  ImageBroswerView.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/29.
//

import Foundation
import UIKit
import Kingfisher
class MediaBroswerView:UIView{
    var mediaModel:[MediaModel]!{
        didSet{
            collectionView.reloadData()
        }
    }
    var currentIndex = 0
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView(){
        backgroundColor = UIColor.black
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(ScreenHeight - NavigationBarHeight - 50)
            make.top.equalTo(NavigationBarHeight)
            make.left.equalTo(0)
        }
        
        addSubview(btnBack)
        btnBack.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.width.height.equalTo(24)
            make.top.equalTo(64)
        }
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(btnBack)
        }
        
        addSubview(btnCheck)
        btnCheck.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(btnBack)
        }
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func backClick(){
        removeFromSuperview()
    }
    
    
    lazy var btnBack: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "public_btn_back_white_solid"), for: .normal)
        v.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        return v
    }()
    
    lazy var lblTitle: UILabel = {
        let v = UILabel()
        return v
    }()
    
    
    lazy var btnCheck: UIButton = {
        let v = UIButton()
        return v
    }()
    
    lazy var btnDownload: UIButton = {
        let v = UIButton()
        return v
    }()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0 //这个很重要，不然两个分页之间有空隙导致后面的页面偏见右
        let  v = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        v.register(ImageBroswerCell.self, forCellWithReuseIdentifier: "ImageCell")
        v.register(VideoBroswerCell.self, forCellWithReuseIdentifier: "VideoCell")
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = UIColor.black
        v.delegate = self
        v.dataSource = self
        v.isPagingEnabled = true
        return v
    }()
}
extension MediaBroswerView:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = mediaModel[indexPath.row]
        if media.type == .Image{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageBroswerCell
            cell.setModel(model: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoBroswerCell
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imgCell = cell as? ImageBrowserCell{
            if imgCell.sc.zoomScale != 1{
                imgCell.sc.zoomScale = 1
            }
        }
    }
  
    
}

class ImageBroswerCell:UICollectionViewCell,UIScrollViewDelegate{
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sc.frame = CGRect(x: 0, y: NavigationBarHeight, w: ScreenWidth, h: ScreenHeight - NavigationBarHeight - 50)
        contentView.addSubview(sc)
        

        sc.addSubview(img)
        img.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 10, height: ScreenWidth - 10)
        img.center = sc.center
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTap(ges:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        img.addGestureRecognizer(tap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(ges:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        img.addGestureRecognizer(doubleTap)

    }
    
    @objc func imgTap(ges:UIGestureRecognizer)  {
         
       }

    @objc func doubleTap(ges:UITapGestureRecognizer){
        if sc.zoomScale == 1{
            sc.setZoomScale(3.0, animated: true)
        } else if sc.zoomScale > 1{
            sc.setZoomScale(1.0, animated: true)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setModel(model:MediaModel){
        if model.imgData != nil{
            img.image = UIImage(data: model.imgData!)
        } else {
            img.setImg(url: model.url, completed: { [weak self] img in
                let center = self?.img.center ?? CGPoint.zero
                self?.img.size = CGSize(width: ScreenWidth - 10, height: (ScreenWidth - 10) / (img.size.width / img.size.height))
                self?.img.center = center
            }, placeHolder: nil)
        }
    }
    
    
    lazy var sc: UIScrollView = {
        let v = UIScrollView()
        v.maximumZoomScale = 6.0
        v.minimumZoomScale = 0.8
        v.delegate = self
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.green.cgColor

        return v
    }()
    
    lazy var img: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.red.cgColor
        return v
    }()
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = sc.bounds.size.width  > sc.contentSize.width ? (sc.bounds.size.width - sc.contentSize.width) * 0.5 : 0.0
        let offsetY = sc.bounds.size.height > sc.contentSize.height ? (sc.bounds.size.height - sc.contentSize.height) * 0.5 : 0.0
        img.center = CGPoint(x: sc.contentSize.width * 0.5 + offsetX, y: sc.contentSize.height * 0.5 + offsetY)
    }
}


class VideoBroswerCell:UICollectionViewCell{
    
}


enum MediaType: Int {
    case Text,
         Image,
         Video
}

enum SelectState:Int{
    case selected,  //选择
    unSelected,     //没有选择
    disableSelect,  //形式上的不能选择，可以点击但是不起作用，提示用户不能选择
    hideSelect      //没有选择按键
}

@objc class MediaModel: NSObject {
    var text = ""
    var videoPath = ""
    var videoCover = ""
    var url = ""
    var type: MediaType!
    var imgData: Data?
    var isSelect = SelectState.unSelected
    var index = 0 //分享详情有顺序
}
