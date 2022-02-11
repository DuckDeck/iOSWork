//
//  ImageInfoViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/1/8.
//

import Foundation
import UIKit
class ImageInfoViewController:BaseViewController{
    
    var imgView:UIImageView!
    let tb = UITableView()
    let sc = UIScrollView()
    var arrImageInfo = [String]()
    var imagePickerController:TZImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ImageIO"
        view.backgroundColor = UIColor.white
        let navBtn1 = UIBarButtonItem(title: "网络图片", style: .plain, target: self, action: #selector(chooseNetImage))
        let navBtn2 = UIBarButtonItem(title: "本地图片", style: .plain, target: self, action: #selector(chooseLocalImage))
        navigationItem.rightBarButtonItems = [navBtn1,navBtn2]
        
        imagePickerController = TZImagePickerController()
        imagePickerController.maxImagesCount = 5
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let ass = assert?.first as? PHAsset{
                ass.getUrl { url in
                    if url != nil{
                        self?.getImgInfo(url: url!.absoluteString)
                    }
                }
            }
        }

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
    }
    
    @objc func chooseNetImage(){
        let vc = SnapkitTableViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.dismissBlock = { url in
            self.getImgInfo(url: url)
        }
        present(vc, animated: true, completion: nil)
    
    }
    
    @objc func chooseLocalImage(){
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func getImgInfo(url:String){
        let imgInfo = ImageSource(url: url) { img in
            
            Toast.showToast(msg: "占用内存大小\(img.memorySize)kb")
            print("占用内存大小\(img.memorySize)kb")
            self.imgView.image = img.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
            let height = ScreenWidth / (img.size.width / img.size.height)
            self.imgView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
       
        delay(time: 1) {
            if let info = imgInfo.imageInfo{
                print(info.Width)
            }
        }
        
       
            

    }
    
}

extension ImageInfoViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImageInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrImageInfo[indexPath.row]
        return cell
    }
    
    
}
