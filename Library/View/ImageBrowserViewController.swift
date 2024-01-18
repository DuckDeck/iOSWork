//
//  ImageBrowserViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/2.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

//这里就写个简单的

class ImageBrowserViewController: UIViewController {

    
    var arrImages:[String]?
    var vc : UICollectionView!
    let btnClose = UIButton()
    let btnDownload = UIButton()
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0 //这个很重要，不然两个分页之间有空隙导致后面的页面偏见右
        vc = UICollectionView(frame: CGRect(x: 0, y: UIDevice.topAreaHeight, width: ScreenWidth, height: ScreenHeight - UIDevice.topAreaHeight), collectionViewLayout: layout)
        vc.isPagingEnabled = true
        vc.register(ImageBrowserCell.self, forCellWithReuseIdentifier: "ImageBrowserCell")
        vc.delegate = self
        vc.dataSource = self
        view.addSubview(vc)
        
        btnClose.setTitle("关闭", for: .normal)
        btnClose.setTitleColor(UIColor.white, for: .normal)
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(btnClose)
        
        btnClose.snp.makeConstraints { (m) in
            m.right.equalTo(-20)
            m.bottom.equalTo(-50)
        }
        
        
        btnDownload.setTitle("下载", for: .normal)
        btnDownload.setTitleColor(UIColor.white, for: .normal)
        btnDownload.addTarget(self, action: #selector(download), for: .touchUpInside)
        view.addSubview(btnDownload)
        
        btnDownload.snp.makeConstraints { (m) in
            m.left.equalTo(20)
            m.bottom.equalTo(-50)
        }
        
    }
    
    
    @objc func download()  {
        guard let cell = vc.visibleCells.first as? ImageBrowserCell else{
            return
        }
        
        cell.img.image?.saveToAlbum()
        Toast.showToast(msg: "成功保存到相册")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vc.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .left, animated: false)
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("ImageBrowserViewController????")
    }
}

extension ImageBrowserViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = arrImages?.count{
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBrowserCell", for: indexPath) as! ImageBrowserCell
        let img = arrImages![indexPath.row]
        cell.setImg(url: img)
        cell.tapBlock = {[weak self](view:UIView) in
            self?.dismiss(animated: true, completion: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imgCell = cell as? ImageBrowserCell{
            if imgCell.sc.zoomScale != 1{
                imgCell.sc.zoomScale = 1
            }
        }
    }
}

class ImageBrowserCell: UICollectionViewCell,UIScrollViewDelegate {
    let sc = UIScrollView()
    let img = UIImageView()
    var tapBlock:((_ view:UIView)->Void)?
    
    func setImg(url:String){
        img.setImg(url: url, completed: { img in
            self.img.size = CGSize(width: ScreenWidth - 30, height: (ScreenWidth - 30) / (img.size.width / img.size.height))
        }, placeHolder: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(sc)
        sc.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 100)
        sc.center = contentView.center
        sc.backgroundColor = UIColor.clear
        sc.isUserInteractionEnabled = true
        sc.delegate = self
        sc.minimumZoomScale = 1
        sc.maximumZoomScale = 4
        sc.layer.borderColor = UIColor.yellow.cgColor
        sc.layer.borderWidth = 1
        sc.scrollsToTop = false
        sc.alwaysBounceVertical = false
        sc.canCancelContentTouches = true
        sc.delaysContentTouches = false
        sc.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        sc.isMultipleTouchEnabled = true
        sc.addSubview(img)
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTap(ges:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        img.addGestureRecognizer(tap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imgDoubleTap(ges:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        img.addGestureRecognizer(doubleTap)

        img.layer.borderColor = UIColor.red.cgColor
        img.layer.borderWidth = 1
        img.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 15, height: ScreenWidth - 15)
        img.center = sc.center
    }
    
    @objc func imgTap(ges:UIGestureRecognizer)  {
        if let view = ges.view{
            tapBlock?(view)
        }
    }
    
    @objc func imgDoubleTap(ges:UIGestureRecognizer)  {
        if sc.zoomScale > 1.5{
            sc.setZoomScale(1.0, animated: true)
        }
        else{
            sc.setZoomScale(3.0, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = sc.bounds.size.width  > sc.contentSize.width ? (sc.bounds.size.width - sc.contentSize.width) * 0.5 : 0.0
        let offsetY = sc.bounds.size.height > sc.contentSize.height ? (sc.bounds.size.height - sc.contentSize.height) * 0.5 : 0.0
        img.center = CGPoint(x: sc.contentSize.width * 0.5 + offsetX, y: sc.contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

