//
//  UploadImageViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2026/3/10.
//

import Foundation
import PhotosUI
import Alamofire
class UploadImageViewController: UIViewController,PHPickerViewControllerDelegate {
    var imagePickerController:PHPickerViewController!
    let img = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片上传下载"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下载", style: .plain, target: self, action: #selector(chooseImage))
        view.backgroundColor = UIColor.white

        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 3
        imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self

        
        img.contentMode = .scaleAspectFill
        img.layer.borderWidth = 6
        img.layer.borderColor = UIColor.clear.cgColor
        img.clipsToBounds = true
        img.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(UIDevice.topAreaHeight)
            m.height.equalTo(ScreenWidth * 0.6)
        }
        
        let btnUpload = UIButton().title(title: "上传图片").color(color: .lightGray).bgColor(color: .green.withAlphaComponent(0.2))
        view.addSubview(btnUpload)
        btnUpload.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-50)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
       
    }
    
    @objc func uploadImg() {
        
        
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 关闭选择器
        for result in results {
            if !result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                continue
            }
            // 使用 itemProvider 加载图片数据
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard let image = image as? UIImage else {return}
                DispatchQueue.main.async {
                    self.img.image = image
                }
            }
        }
    }
    
    @objc func chooseImage(){
        present(imagePickerController, animated: true, completion: nil)
    }
}
