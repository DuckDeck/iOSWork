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
        
        let url1 = URL(string: "http://stanhu.cc:9030/api/raw/Video/%E8%AE%A9%E4%BD%A0%E7%9A%84%E8%80%B3%E6%9C%B5%E6%80%80%E5%AD%95%EF%BC%81%E3%80%8AA%20Moment%20Apart%E3%80%8B%E6%9E%81%E9%99%90%E7%AB%9E%E9%80%9F%EF%BC%9A%E5%9C%B0%E5%B9%B3%E7%BA%BF4%E9%85%8D%E4%B9%90_P2_%E9%9F%B3%E8%B4%A8%E5%8A%A0%E5%BC%BA%E7%89%88.mp4?auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJsb2NhbGUiOiJ6aC1jbiIsInZpZXdNb2RlIjoibW9zYWljIiwic2hvd0hpZGRlbiI6ZmFsc2UsInBlcm0iOnsiYWRtaW4iOnRydWUsImV4ZWN1dGUiOnRydWUsImNyZWF0ZSI6dHJ1ZSwicmVuYW1lIjp0cnVlLCJtb2RpZnkiOnRydWUsImRlbGV0ZSI6dHJ1ZSwic2hhcmUiOnRydWUsImRvd25sb2FkIjp0cnVlfSwiY29tbWFuZHMiOltdLCJsb2NrUGFzc3dvcmQiOmZhbHNlLCJvdHAiOmZhbHNlLCJvdHBLZXkiOiJMNlpOSE1YREpRUDZGNk1LTU9SNEJSVEgzQVNLQU9aUyJ9LCJleHAiOjE2ODE0MzM4NTYsImlhdCI6MTY4MTM0NzQ1NiwiaXNzIjoiRmlsZSBCcm93c2VyICB2Mi45LjMvNGUzMWFkYTZcbkJ1aWx0IEZvciAgIDogbGludXgvYW1kNjRcbkdvIFZlcnNpb24gIDogZ28xLjE0LjJcblJlbGVhc2UgRGF0ZTogMjAyMDA0MzAtMTA0NiJ9.gaEIgTT6RDVNxBQb296XWJojxKlOtHQ4sXuEAf_46kg&inline=true")!
        let video1 = VideoModel(url: url1, fileName: "吐槽大会")
        arrFile.append(video1)
        let url2 = URL(string: "http://stanhu.cc:9030/api/raw/Video/%E5%B0%8F%E5%A7%90%E5%A7%90/%E8%95%BE%E5%A7%86cos%E5%9B%BE%E9%9B%86.mp4?auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJsb2NhbGUiOiJ6aC1jbiIsInZpZXdNb2RlIjoibW9zYWljIiwic2hvd0hpZGRlbiI6ZmFsc2UsInBlcm0iOnsiYWRtaW4iOnRydWUsImV4ZWN1dGUiOnRydWUsImNyZWF0ZSI6dHJ1ZSwicmVuYW1lIjp0cnVlLCJtb2RpZnkiOnRydWUsImRlbGV0ZSI6dHJ1ZSwic2hhcmUiOnRydWUsImRvd25sb2FkIjp0cnVlfSwiY29tbWFuZHMiOltdLCJsb2NrUGFzc3dvcmQiOmZhbHNlLCJvdHAiOmZhbHNlLCJvdHBLZXkiOiJMNlpOSE1YREpRUDZGNk1LTU9SNEJSVEgzQVNLQU9aUyJ9LCJleHAiOjE2ODE0MzM5NTAsImlhdCI6MTY4MTM0NzU1MCwiaXNzIjoiRmlsZSBCcm93c2VyICB2Mi45LjMvNGUzMWFkYTZcbkJ1aWx0IEZvciAgIDogbGludXgvYW1kNjRcbkdvIFZlcnNpb24gIDogZ28xLjE0LjJcblJlbGVhc2UgRGF0ZTogMjAyMDA0MzAtMTA0NiJ9._ASQ9hIKVJPrq2NEUxdeaSF8t7utN6tCs2l-n9VldYA&inline=true")!
        let video2 = VideoModel(url: url2,  fileName: "TAEYEON")
        arrFile.append(video2)
       
        let video3 = VideoModel(url: URL(string: "http://stanhu.cc:9030/api/raw/Video/%E8%B0%83%E8%AF%95%E4%BF%9D%E9%99%A9%E4%B8%9D.mp4?auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJsb2NhbGUiOiJ6aC1jbiIsInZpZXdNb2RlIjoibW9zYWljIiwic2hvd0hpZGRlbiI6ZmFsc2UsInBlcm0iOnsiYWRtaW4iOnRydWUsImV4ZWN1dGUiOnRydWUsImNyZWF0ZSI6dHJ1ZSwicmVuYW1lIjp0cnVlLCJtb2RpZnkiOnRydWUsImRlbGV0ZSI6dHJ1ZSwic2hhcmUiOnRydWUsImRvd25sb2FkIjp0cnVlfSwiY29tbWFuZHMiOltdLCJsb2NrUGFzc3dvcmQiOmZhbHNlLCJvdHAiOmZhbHNlLCJvdHBLZXkiOiJMNlpOSE1YREpRUDZGNk1LTU9SNEJSVEgzQVNLQU9aUyJ9LCJleHAiOjE2ODE0MzM5NTAsImlhdCI6MTY4MTM0NzU1MCwiaXNzIjoiRmlsZSBCcm93c2VyICB2Mi45LjMvNGUzMWFkYTZcbkJ1aWx0IEZvciAgIDogbGludXgvYW1kNjRcbkdvIFZlcnNpb24gIDogZ28xLjE0LjJcblJlbGVhc2UgRGF0ZTogMjAyMDA0MzAtMTA0NiJ9._ASQ9hIKVJPrq2NEUxdeaSF8t7utN6tCs2l-n9VldYA&inline=true"))
        arrFile.append(video3)
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
        present(vc, animated: true, completion: nil)
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
  
            self.img.image = Tool.thumbnailImageForVideo(url: m.url)
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

