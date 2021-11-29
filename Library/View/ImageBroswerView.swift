//
//  ImageBroswerView.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/29.
//

import Foundation
import UIKit
import Kingfisher
//class ImageBroswerView:UIView{
//    var mediaModel:[MediaModel]!
//    var currentIndex = 0
//    
//    
//    
//    fileprivate override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    convenience init(media:[MediaModel]) {
//        self.init(frame: UIScreen.main.bounds)
//        self.mediaModel = media
//        backgroundColor = UIColor.black
//        
//        addSubview(tb)
//        tb.snp.makeConstraints { make in
//            make.width.equalTo(ScreenHeight - 100)
//            make.height.equalTo(ScreenWidth)
//            make.center.equalTo(self)
//        }
//        
//        addSubview(btnBack)
//        btnBack.snp.makeConstraints { make in
//            make.left.equalTo(30)
//            make.width.height.equalTo(24)
//            make.top.equalTo(64)
//        }
//        
//        addSubview(lblTitle)
//        lblTitle.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.centerY.equalTo(btnBack)
//        }
//        
//        addSubview(btnCheck)
//        btnCheck.snp.makeConstraints { make in
//            make.right.equalTo(-20)
//            make.centerY.equalTo(btnBack)
//        }
//
//        
//        
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    @objc func backClick(){
//        removeFromSuperview()
//    }
//    
//    
//    lazy var btnBack: UIButton = {
//        let v = UIButton()
//        v.setImage(UIImage(named: "public_btn_back_white_solid"), for: .normal)
//        v.addTarget(self, action: #selector(backClick), for: .touchUpInside)
//        return v
//    }()
//    
//    lazy var lblTitle: UILabel = {
//        let v = UILabel()
//        return v
//    }()
//    
//    
//    lazy var btnCheck: UIButton = {
//        let v = UIButton()
//        return v
//    }()
//    
//    lazy var cv : UICollectionView = {
//        let  v = UICollectionView()
//        v.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
//        v.frame = self.bounds
//        v.bounces = false
//        v.scrollsToTop = true
//        v.separatorStyle = .none
//        v.showsVerticalScrollIndicator = false
//        v.delegate = self
//        v.dataSource = self
//        v.register(ImageBroswerCell.self, forCellReuseIdentifier: "ImageCell")
//        v.register(VideoBroswerCell.self, forCellReuseIdentifier: "VideoCell")
//        v.isPagingEnabled = true
//        return v
//    }()
//}
//extension ImageBroswerView:UITableViewDelegate,UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mediaModel.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let media = mediaModel[indexPath.row]
//        if media.type == .Image {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageBroswerCell
//            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//            cell.selectionStyle = .none
//            cell.setModel(model: media)
//            cell.sc.zoomScale = 1
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoBroswerCell
//            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//            cell.selectionStyle = .none
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.frame.size.width
//    }
//    
//  
//    
//}
//
//class ImageBroswerCell:UICollectionViewCell,UIScrollViewDelegate{
//  
//
//    
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(sc)
//        sc.snp.makeConstraints { make in
//            make.center.equalTo(contentView)
//            make.width.equalTo(ScreenWidth - 5)
//            make.height.equalTo(contentView)
//        }
//        
//        sc.addSubview(img)
//        img.snp.makeConstraints { make in
//            make.center.equalTo(sc)
//            make.height.width.equalTo(ScreenWidth - 5)
//            
//        }
//        img.isUserInteractionEnabled = true
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(ges:)))
//        doubleTap.numberOfTapsRequired = 2
//        img.addGestureRecognizer(doubleTap)
//    }
//    
//    @objc func doubleTap(ges:UITapGestureRecognizer){
//        if sc.zoomScale == 1{
//            sc.setZoomScale(2.0, animated: true)
//        } else if sc.zoomScale > 1{
//            sc.setZoomScale(1.0, animated: true)
//        }
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setModel(model:MediaModel){
//        if model.imgData != nil{
//            img.image = UIImage(data: model.imgData!)
//        } else {
//            img.setImg(url: model.url, completed: { [weak self] img in
////                self?.sc.snp.updateConstraints({ make in
////                    make.width.equalTo(img.size.width)
////                    make.height.equalTo(img.size.height)
////                })
//                self?.img.snp.updateConstraints({ make in
//                    make.height.equalTo((ScreenWidth - 5) / (img.size.width / img.size.height))
//                })
//            }, placeHolder: nil)
//        }
//    }
//    
//    
//    lazy var sc: UIScrollView = {
//        let v = UIScrollView()
//        v.maximumZoomScale = 6.0
//        v.minimumZoomScale = 0.8
//        v.delegate = self
//        v.showsVerticalScrollIndicator = false
//        v.showsHorizontalScrollIndicator = false
////        v.contentSize = CGSize(width: ScreenWidth, height: ScreenWidth)
//        v.layer.borderWidth = 1
//        v.layer.borderColor = UIColor.green.cgColor
//
//        return v
//    }()
//    
//    lazy var img: UIImageView = {
//        let v = UIImageView()
//        v.contentMode = .scaleAspectFit
//        v.layer.borderWidth = 1
//        v.layer.borderColor = UIColor.red.cgColor
//        return v
//    }()
//    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return img
//    }
//    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
////        let offsetX = sc.bounds.size.width  > sc.contentSize.width ? (sc.bounds.size.width - sc.contentSize.width) * 0.5 : 0.0
////        let offsetY = sc.bounds.size.height > sc.contentSize.height ? (sc.bounds.size.height - sc.contentSize.height) * 0.5 : 0.0
////        img.center = CGPoint(x: sc.contentSize.width * 0.5 + offsetX, y: sc.contentSize.height * 0.5 + offsetY)
//    }
//    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
////        CGFloat contentWidthAdd = self.scrollView.tz_width - CGRectGetMaxX(_cropRect);
////        CGFloat contentHeightAdd = (MIN(_imageContainerView.tz_height, self.tz_height) - self.cropRect.size.height) / 2;
////        CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
////        CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.tz_height) + contentHeightAdd;
////        _scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
////        _scrollView.alwaysBounceVertical = YES;
////        // 2.让scrollView新增滑动区域（裁剪框左上角的图片部分）
////        if (contentHeightAdd > 0 || contentWidthAdd > 0) {
////            _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
////        } else {
////            _scrollView.contentInset = UIEdgeInsetsZero;
////        }
//    }
//    
//}
//
//class VideoBroswerCell:UICollectionViewCell{
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
//
//
//
//
//
//enum MediaType: Int {
//    case Text,
//         Image,
//         Video
//}
//
//enum SelectState:Int{
//    case selected,  //选择
//    unSelected,     //没有选择
//    disableSelect,  //形式上的不能选择，可以点击但是不起作用，提示用户不能选择
//    hideSelect      //没有选择按键
//}
//
//@objc class MediaModel: NSObject {
//    var text = ""
//    var videoPath = ""
//    var videoCover = ""
//    var url = ""
//    var type: MediaType!
//    var imgData: Data?
//    var isSelect = SelectState.unSelected
//    var index = 0 //分享详情有顺序
//}
