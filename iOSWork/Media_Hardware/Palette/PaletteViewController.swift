//
//  PaletteViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/15.
//

import UIKit
import PhotosUI
class PaletteViewController: UIViewController {
    var imagePickerController:PHPickerViewController!
    let imgView = UIImageView()
    var recommandColor = ""
    var colorsHint:[UIColor]?
    let tb = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }

    
    func initView() {
        view.backgroundColor = UIColor.white
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self
        
        let btnChoose = UIBarButtonItem(title: "添加照片", style: .plain, target: self, action: #selector(addImage))
        navigationItem.rightBarButtonItem = btnChoose
        imgView.contentMode = .scaleAspectFill
        imgView.layer.borderWidth = 6
        imgView.layer.borderColor = UIColor.clear.cgColor
        imgView.clipsToBounds = true
        imgView.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(UIDevice.topAreaHeight)
            m.height.equalTo(ScreenWidth * 0.6)
        }
        
        tb.delegate = self
        tb.dataSource = self
        tb.tableFooterView = UIView()
        tb.rowHeight = 40
        tb.register(ColorHintCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.bottom.left.right.equalTo(0)
            m.top.equalTo(imgView.snp.bottom).offset(10)
        }
    }
    
    @objc func addImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func show(img:UIImage) {
        imgView.image = img
        guard let colors = ColorThief.getPalette(from: img, colorCount: 10) else {return}
        self.recommandColor = colors.first?.makePlatformNativeColor().hex ?? ""
        self.colorsHint = colors.compactMap{$0.makePlatformNativeColor()}
        imgView.layer.borderColor = colors.first?.makePlatformNativeColor().cgColor
        tb.reloadData()

    }

}

extension PaletteViewController:UITableViewDelegate,UITableViewDataSource, PHPickerViewControllerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorsHint?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ColorHintCell
        cell.lblColor.text = colorsHint![indexPath.row].hex
        cell.lblColor.backgroundColor = colorsHint![indexPath.row]
        return cell
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
                    self.show(img: image)
                }
            }
        }
    }
}

class ColorHintCell: UITableViewCell {
    let lblColor = UILabel()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblColor.txtAlignment(ali: .center).color(color: UIColor.white).addTo(view: contentView).snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
