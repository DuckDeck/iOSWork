//
//  VideoListViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/15.
//

import UIKit
import AVKit

class VideoListViewController: UIViewController {
    
    var vc : UICollectionView!
    var arrFile = [VideoModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        initData()
    }
    
    func initView()  {
        authAudio()
        authVideo()
        
        let btnRecord = UIBarButtonItem(title: "录视频", style: .plain, target: self, action: #selector(recordVideo))
        navigationItem.rightBarButtonItem = btnRecord
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: (ScreenWidth - 30) / 2, height: (ScreenWidth - 30) / 2)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vc = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        vc.backgroundColor = UIColor.white
        vc.register(VideoImageCell.self, forCellWithReuseIdentifier: "cell")
        vc.delegate = self
        vc.dataSource = self
        view.addSubview(vc)
        vc.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
    }
    
    func initData() {
        let files = VideoFileManager.getAllVideos()
        arrFile = files.map({ (url) -> VideoModel in
            return VideoModel(url: url,  fileName: url.lastPathComponent)
        })
        
        let url1 = URL(string: "http://lovelive.ink:9001/video/%5B%E5%90%90%E6%A7%BD%E5%A4%A7%E4%BC%9A%5D0707%E6%9C%9F%EF%BC%9A%E5%91%A8%E6%9D%B0%E8%A2%AB%E9%9B%AA%E5%A7%A8%E5%BD%93%E9%9D%A2%E5%90%90%E6%A7%BD_bd.mp4")!
        let video1 = VideoModel(url: url1, fileName: "吐槽大会")
        arrFile.append(video1)
        let url2 = URL(string: "http://lovelive.ink:9001/video/%E4%BA%9A%E7%89%B9%E5%85%B0%E8%92%82%E6%96%AF%E5%B0%91%E5%A5%B3.mp4")!
        let video2 = VideoModel(url: url2,  fileName: "TAEYEON")
        arrFile.append(video2)

       //不支持mkv
        vc.reloadData()
    }

    @objc func recordVideo() {
        let vc = VideoRecordViewController()
        vc.uploadVideoBlock = {(url:URL) in
            let m = VideoModel(url: url, fileName: url.lastPathComponent)
            self.arrFile.insert(m, at: 0)
            self.vc.reloadData()
        }
        vc.modalPresentationStyle = .fullScreen
        present(VideoRecordViewController(), animated: true) {
            print("123")
        }
    }
    
    
    
    func authVideo() {
        let status = Auth.isAuthCamera()
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Video)
        case .notDetermined:
            Auth.authCamera { (res) in
                if(res){
                    
                }
                else{
                    Toast.showToast(msg: "摄像头授权失败")
                }
            }
            
        default:
            break
        }
    }
    
    func authAudio() {
        let status = Auth.isAuthMicrophone()
        
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Audio)
        case .notDetermined:
            Auth.authMicrophone { (res) in
                if(res){
                    
                }
                else{
                    Toast.showToast(msg: "麦克风授权失败")
                }
            }
            
        default:
            break
        }
    }
}

extension VideoListViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFile.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoImageCell
        cell.img.image = UIImage(named: "10")
        cell.lblTitle.text = "Look"
        cell.model = arrFile[indexPath.row]
        cell.addLongPressGesture { (press) in
            UIAlertController.title(title: "你要删除该视频吗", message: "删除").action(title: "Cancel", handle: nil).action(title: "Confirm", handle: { (alert) in
                let file = self.arrFile.remove(at: indexPath.row)
                try? FileManager.default.removeItem(at: file.url)
                self.vc.reloadData()
            }).show()
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = arrFile[indexPath.row].url
        let vc = VideoPlayViewController()
        vc.url = url!
        vc.modalPresentationStyle = .fullScreen
        vc.deleteBlock = {(url:URL) in
            self.initData()
        }
        //搞一个错误的视频
//        let str = url!.absoluteString.replacingOccurrencesOfString(".", withString: "_")
//        let newUrl = URL(string: str)
//        vc.url = newUrl!
        present(vc, animated: true, completion: nil)
//        let avPlayer = AVPlayer(url: url!)
//        let vc = AVPlayerViewController()
//        vc.player = avPlayer
//        vc.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
//        vc.showsPlaybackControls = true
//        vc.view.frame = view.bounds
//        addChildViewController(vc)
//        view.addSubview(vc.view)
//        vc.player?.play()
        
    }
    
}

class VideoImageCell: UICollectionViewCell {
    let img = UIImageView()
    let lblTitle = UILabel()
    var model:VideoModel?{
        didSet{
            guard let m = model else {
                return
            }
            Tool.thumbnailImageForVideo(url: m.url, time: 0) { image in
                self.img.image = image
                
            }
            
            lblTitle.text = m.fileName
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(gray: 0.3)
        contentView.addSubview(img)
        img.contentMode = .scaleAspectFit
        img.snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(5)
            m.width.equalTo(frame.size.width - 10)
            m.height.equalTo(frame.size.height - 33)
        }
        
        lblTitle.txtAlignment(ali: .center).setFont(font: 15).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.bottom.equalTo(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct VideoModel {
    var url:URL!
    var fileName = ""
}

