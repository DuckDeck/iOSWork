//
//  ImageInfoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/1/8.
//

import Foundation
import PhotosUI
import UIKit

class ImageInfoViewController: BaseViewController, PHPickerViewControllerDelegate {
    var imgView: UIImageView!
    let tb = UITableView()
    let sc = UIScrollView()
    var arrImageInfo = [String]()
    var imagePickerController: PHPickerViewController!
    let lblInfo = UILabel()
    var tmpImg: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ImageIO"
        view.backgroundColor = UIColor.white
        let navBtn1 = UIBarButtonItem(title: "网络图片", style: .plain, target: self, action: #selector(chooseNetImage))
        let navBtn2 = UIBarButtonItem(title: "本地图片", style: .plain, target: self, action: #selector(chooseLocalImage))
        navigationItem.rightBarButtonItems = [navBtn1, navBtn2]
        
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 6
        imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self

//        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
//            if let ass = assert?.first as? PHAsset{
//                ass.getUrl { url in
//                    if url != nil{
//                        self?.getImgInfo(url: url!.absoluteString)
//                    }
//                }
//            }
//        }

        view.addSubview(sc)
        sc.backgroundColor = UIColor.Hex(hexString: "fafafa")
        sc.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleToFill
        imgView.layer.borderColor = UIColor.random.cgColor
        imgView.layer.borderWidth = 1
        sc.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(10)
            make.height.width.equalTo(ScreenWidth)
        }
        
        tb.delegate = self
        tb.dataSource = self
        tb.tableFooterView = UIView()
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        sc.addSubview(tb)
        tb.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(imgView.snp.bottom).offset(20)
            make.bottom.equalTo(0)
            make.width.equalTo(ScreenWidth)
        }
        
        let slider = UISlider()
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(valueChange(sender:)), for: .valueChanged)
        view.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        view.addSubview(lblInfo)
        lblInfo.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(slider.snp.bottom)
        }
        
        let btnSave = UIButton().title(title: "保存").color(color: UIColor.red).addTo(view: view)
        btnSave.addTarget(self, action: #selector(saveImg), for: .touchUpInside)
        btnSave.snp.makeConstraints { make in
            make.top.equalTo(lblInfo.snp.bottom)
            make.left.equalTo(20)
        }
     }
    
    @objc func valueChange(sender: UISlider) {
        print(sender.value)
        
        let data = tmpImg?.jpegData(compressionQuality: CGFloat(sender.value))
        let newImg = UIImage(data: data!)!
        lblInfo.text = "\(sender.value)--\(newImg.size)--\(newImg.memorySize)"
        imgView.image = newImg
    }
    
    @objc func saveImg() {
        imgView.image?.saveToAlbum()
    }
    
    @objc func chooseNetImage() {
        let vc = SnapkitTableViewController()
        let nav = UINavigationController(rootViewController: vc)
//        nav.view.backgroundColor = .clear
        nav.modalPresentationStyle = .overFullScreen
//        vc.dismissBlock = { url in
//            self.getImgInfo(url: url)
//        }
        present(nav, animated: true, completion: nil)
     }
    
    @objc func chooseLocalImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func getImgInfo(url: String) {
        let imgInfo = ImageSource(url: url) { img in
            Toast.showToast(msg: "占用内存大小\(img.memorySize)kb")
            print("占用内存大小\(img.memorySize)kb")
            self.imgView.image = img.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
            let height = ScreenWidth / (img.size.width / img.size.height)
            self.imgView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.tmpImg = self.imgView.image
        }
       
        delay(time: 1) {
            if let info = imgInfo.imageInfo {
                print(info.Width)
            }
        }
       }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 关闭选择器
       
        guard let result = results.first else {
            // 如果没有选择任何结果，则提前退出
            return
        }
                
        let itemProvider = result.itemProvider
                
        // 1. 确定要加载的类型标识符。使用 'public.image' 或其他具体的 UTType
        let imageType = UTType.image.identifier
                
        // 2. 检查 ItemProvider 是否可以加载文件表示
        if itemProvider.hasItemConformingToTypeIdentifier(imageType) {
            // 3. 异步加载文件 URL
            // 注意：这里获得的是系统为你创建的临时文件 URL
            itemProvider.loadFileRepresentation(forTypeIdentifier: imageType) { [weak self] url, error in
                guard let self = self else { return }
                        
                if let error = error {
                    print("加载文件表示失败: \(error)")
                    return
                }
                        
                guard let sourceURL = url else {
                    print("未获取到有效的临时文件 URL")
                    return
                }
                        
                // 4. ‼️ 关键步骤：将临时文件复制到沙盒目录
                // 系统会在方法返回后清理这个 URL 指向的临时文件，所以必须立即复制
                do {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let finalURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                            
                    // 确保目标位置没有旧文件
                    if FileManager.default.fileExists(atPath: finalURL.path) {
                        try FileManager.default.removeItem(at: finalURL)
                    }
                            
                    // 执行复制操作
                    try FileManager.default.copyItem(at: sourceURL, to: finalURL)
                    DispatchQueue.main.async {
                        self.getImgInfo(url: finalURL.absoluteString)
                    }
                    // 5. 回到主线程执行 ImageIO 操作 (因为它可能更新 UI，尽管 CGImageSource 本身可以在后台)
                    DispatchQueue.main.async {}
                            
                } catch {
                    print("复制文件失败: \(error)")
                }
            }
        }
     }
}

extension ImageInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImageInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrImageInfo[indexPath.row]
        return cell
    }
}
