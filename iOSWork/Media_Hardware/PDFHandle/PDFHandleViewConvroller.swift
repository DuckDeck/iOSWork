//
//  PDFHandleViewConvroller.swift
//  iOSWork
//
//  Created by Stan Hu on 2025/8/27.
//

import CoreGraphics
import Foundation
import PDFKit

class PDFHandleViewConvroller: UIViewController, UIDocumentPickerDelegate {
    var vCol: UICollectionView!
    var heights = [Double]()
    var arrImages = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0 ..< 5000 {
            heights.append(300)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "PDF", style: .plain, target: self, action: #selector(choosePDF))
        
        let layout = FlowLayout(columnCount: 1, columnMargin: 2) { [weak self] index -> Double in
            return self!.heights[index.row]
        }

        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(ImageSetCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(vCol)
    }
    
    @objc func choosePDF() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: false)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // 如果需要选择多个文件，设为 true

        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 用户选择了文件，urls 数组包含了选择的文件的 URL
        guard let url = urls.first else { return }

        // 确保你对该 URL 有访问权限
        let isAccessing = url.startAccessingSecurityScopedResource()

        defer {
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let images = PDFImageExtractor.extractAllImages(from: url, pageIndex: -1)
        Toast.showToast(msg: "第二页获取到\(images.count)张图片")
        arrImages = images
        vCol.reloadData()
        Toast.showLoading(txt: "正在保存图")
        for item in arrImages.enumerated() {
            item.element.saveToAlbum(isTmp: true) { finish, err in
                
            }
            if item.offset == arrImages.count - 1 {
                Toast.dismissLoading()
            }
        }
        
      }
}

extension PDFHandleViewConvroller: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageSetCell
        cell.img.image = arrImages[indexPath.row]
        return cell
    }
}
