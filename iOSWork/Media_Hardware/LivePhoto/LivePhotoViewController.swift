//
//  LivePhotoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/10/9.
//

class LivePhotoViewController: UIViewController,TZImagePickerControllerDelegate {
    var imgView: UIImageView!
    var arrImageInfo = [String]()
    var shadowPlayer:ShadowVideoPlayerView!

    var imagePickerController: TZImagePickerController!
    let lblInfo = UILabel()
    var tmpImg: UIImage?
    private let videoSize = CGSize(width: 640, height: 480)
    private let videoDuration: TimeInterval = 1.5 // 视频时长1.5秒
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
        imgView.contentMode = .scaleToFill
        imgView.layer.borderColor = UIColor.random.cgColor
        imgView.layer.borderWidth = 1
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(10)
            make.height.width.equalTo(ScreenWidth).multipliedBy(0.5)
        }
        
        
        
        let btnSave = UIButton().title(title: "保存").color(color: UIColor.red).addTo(view: view)
        btnSave.addTarget(self, action: #selector(saveImg), for: .touchUpInside)
        btnSave.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom)
            make.left.equalTo(20)
        }
    }
    

    
    @objc func saveImg() {
      
    }

    @objc func chooseLocalImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func createVideo(img:UIImage) {
        let videoUrl = FileManager.default.temporaryDirectory.appendingPathComponent("zoom_video.mp4")
    
//        shadowPlayer = ShadowVideoPlayerView(frame: CGRect(), url: videoUrl)
//        shadowPlayer.player.isAutoPlay = false
//        shadowPlayer.title = "Live Photo"
//        shadowPlayer.backgroundColor = UIColor.black
//        view.addSubview(shadowPlayer)
//        shadowPlayer.snp.makeConstraints { (m) in
//            m.left.equalTo(ScreenWidth / 2)
//            m.top.equalTo(imgView)
//            m.height.width.equalTo(ScreenWidth).multipliedBy(0.5)
//        }
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
