//
//  LivePhotoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/10/9.
//

import AVFoundation

class LivePhotoViewController: UIViewController, TZImagePickerControllerDelegate {
    var imgView: UIImageView!
    var arrImageInfo = [String]()
    var shadowPlayer: ShadowVideoPlayerView!

    var imagePickerController: TZImagePickerController!
    let lblInfo = UILabel()
    var tmpImg: UIImage?
    var videoURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ImageIO"
        view.backgroundColor = UIColor.white

        imagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = { [weak self] images, _, _ in
            guard let images = images, images.count > 0 else { return }
            if images.count == 1 {
                self?.createVideo(img: images[0])
            } else {
                self?.createVideos(imgs: images)
            }
        }

        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.layer.borderColor = UIColor.random.cgColor
        imgView.layer.borderWidth = 1
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(UIDevice.topAreaHeight)
            make.width.equalTo(ScreenWidth / 2)
            make.height.equalTo(300)
        }

        let btnChooseOne = UIButton().title(title: "选择一张").color(color: .green).addTo(view: view)
        btnChooseOne.addTarget(self, action: #selector(chooseOneImage), for: .touchUpInside)
        btnChooseOne.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(400)
        }

        let btnChooseMore = UIButton().title(title: "选择多张").color(color: .green).addTo(view: view)
        btnChooseMore.addTarget(self, action: #selector(chooseMoreImage), for: .touchUpInside)
        btnChooseMore.snp.makeConstraints { make in
            make.left.equalTo(150)
            make.top.equalTo(400)
        }

        let btnSave = UIButton().title(title: "保存到相册").color(color: UIColor.red).addTo(view: view)
        btnSave.addTarget(self, action: #selector(saveImg), for: .touchUpInside)
        btnSave.snp.makeConstraints { make in
            make.left.equalTo(250)
            make.top.equalTo(400)
        }
    }

    @objc func saveImg() {
        guard let videoURL = videoURL else { return }
        LivePhoto.generate(from: nil, videoURL: videoURL) { _ in

        } completion: { _, resouce in
            if let source = resouce {
                LivePhoto.saveToLibrary(source) { finish in
                    if finish {
                        Toast.showToast(msg: "保存成功")
                    }
                }
            }
        }
    }

    @objc func chooseOneImage() {
        imagePickerController.maxImagesCount = 1
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func chooseMoreImage() {
        imagePickerController.maxImagesCount = 5
        present(imagePickerController, animated: true, completion: nil)
    }

    func createVideo(img: UIImage) {
        imgView.image = img
        VideoCreate().generateVideo(images: [img], duration: 4, size: img.size) { videoUrl in
            if let u = videoUrl {
                self.playVideo(url: u)
            }
        }
    }

    func createVideos(imgs: [UIImage]) {
        imgView.image = imgs[0]
        VideoCreate().generateVideo(images: imgs, duration: 2, size: imgs[0].size) { videoUrl in
            if let u = videoUrl {
                self.playVideo(url: u)
            }
        }
    }

    func playVideo(url: URL) {
        videoURL = url
        shadowPlayer = ShadowVideoPlayerView(frame: CGRect(), url: url)
        shadowPlayer.player.isAutoPlay = false
        shadowPlayer.title = "Live Photo"
        shadowPlayer.backgroundColor = UIColor.black
        view.addSubview(shadowPlayer)
        shadowPlayer.snp.makeConstraints { m in
            m.left.equalTo(ScreenWidth / 2)
            m.top.equalTo(imgView)
            m.width.equalTo(ScreenWidth / 2)
            m.height.equalTo(300)
        }
    }
}

extension UIImage {
    func imageScaled(to size: CGSize) -> UIImage? {
        let drawingRect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // 绘制图片到新的上下文中，实现缩放
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        draw(in: drawingRect)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}
