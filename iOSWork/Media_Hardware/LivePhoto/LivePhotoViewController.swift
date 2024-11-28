//
//  LivePhotoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/10/9.
//

import AVFoundation

class LivePhotoViewController: UIViewController,TZImagePickerControllerDelegate {
    var imgView: UIImageView!
    var arrImageInfo = [String]()
    var shadowPlayer:ShadowVideoPlayerView!

    var imagePickerController: TZImagePickerController!
    let lblInfo = UILabel()
    var tmpImg: UIImage?
    var videoURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ImageIO"
        view.backgroundColor = UIColor.white
        let navBtn = UIBarButtonItem(title: "选择图片", style: .plain, target: self, action: #selector(chooseLocalImage))
        navigationItem.rightBarButtonItems = [navBtn]
        
        imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            guard let img = images?.first else { return  }
            self?.createVideo(img: img)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.layer.borderColor = UIColor.random.cgColor
        imgView.layer.borderWidth = 1
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
            make.width.equalTo(ScreenWidth - 80)
            make.height.equalTo(250)
        }
        
        
        
        let btnSave = UIButton().title(title: "保存").color(color: UIColor.red).addTo(view: view)
        btnSave.addTarget(self, action: #selector(saveImg), for: .touchUpInside)
        btnSave.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(100)
        }
    }
    

    
    @objc func saveImg() {
        guard let videoURL = videoURL else { return  }
        LivePhoto.generate(from: nil, videoURL: videoURL) { _ in
            
        } completion: { photo, resouce in
            if let source = resouce {
                LivePhoto.saveToLibrary(source) { finish in
                    if finish {
                        Toast.showToast(msg: "保存成功")
                    }
                }
            }
           
        }

    }

    @objc func chooseLocalImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func createVideo(img:UIImage) {
        imgView.image = img
        VideoCreate().generateVideo(image: img, duration: 3, size: img.size) {  videoUrl in
            if let u = videoUrl {
                self.playVideo(url: u)
            }
        }
    }
  
    func playVideo(url:URL) {
        videoURL = url
        shadowPlayer = ShadowVideoPlayerView(frame: CGRect(), url: url)
        shadowPlayer.player.isAutoPlay = false
        shadowPlayer.title = "Live Photo"
        shadowPlayer.backgroundColor = UIColor.black
        view.addSubview(shadowPlayer)
        shadowPlayer.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.top.equalTo(imgView.snp.bottom)
            m.width.equalTo(ScreenWidth)
            m.height.equalTo(ScreenWidth).multipliedBy(0.6)
        }
    }

   

   
}

extension UIImage {
    func imageScaled(to size: CGSize) -> UIImage? {
        let drawingRect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // 绘制图片到新的上下文中，实现缩放
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        self.draw(in: drawingRect)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}
