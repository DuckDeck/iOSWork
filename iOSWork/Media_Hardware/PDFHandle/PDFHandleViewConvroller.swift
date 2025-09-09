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

    var arrPdfContents = [PdfPageContent]()
    override func viewDidLoad() {
        super.viewDidLoad()

     
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "PDF", style: .plain, target: self, action: #selector(choosePDF))

        let layout = FlowLayout(columnCount: 1, columnMargin: 2) { [weak self] index -> Double in
            let imageCount = self!.arrPdfContents[index.row].images?.count ?? 0
            let rowCount = ceil(Double(imageCount) / 3.0)
            return rowCount * 100 + 150
        }

        vCol = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(PDFPageCell.self, forCellWithReuseIdentifier: "Cell")
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

        let infos = PDFImageExtractor.extractAllImages(from: url, pageIndex: 0) // 0 取出pdf所有页面的图片
        if case .failure(let failure) = infos {
            Toast.showToast(msg: failure.msg)
            return
        }
        guard case .success(let info) = infos else { return }
        self.arrPdfContents = info
    
       
        vCol.reloadData()

    }
}

extension PDFHandleViewConvroller: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPdfContents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PDFPageCell
        cell.setPdfPage(content: arrPdfContents[indexPath.row])
        return cell
    }
}

class PDFPageCell:UICollectionViewCell, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageItemCell", for: indexPath) as! ImageItemCell
        if let imgs = content?.images {
            cell.imgView.image = imgs[indexPath.row]
        }
        return cell
    }
    
    
    var content:PdfPageContent?
    let lblTitle = UILabel()
    func setPdfPage(content:PdfPageContent) {
        self.content = content
        lblTitle.text = "第\(content.pageIndex)页\n \(content.text)"
        nestedCollectionView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lblTitle.numberOfLines = 0
        lblTitle.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.lessThanOrEqualTo(150)
        }
        contentView.addSubview(nestedCollectionView)
        nestedCollectionView.dataSource = self
        nestedCollectionView.snp.makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(lblTitle.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 96, height: 96)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ImageItemCell.self, forCellWithReuseIdentifier: "ImageItemCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
}

class ImageItemCell:UICollectionViewCell {
    let imgView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
