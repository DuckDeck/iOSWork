//
//  XlogDecode.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/7/30.
//

import Foundation
import SSZipArchive

class XlogDecodeViewController: BaseViewController {
    let publicKey = "b11894e1a0540dc2df4e4a994fce26569095bad2c34e1f17376b257b4d1b4a4fec9081cf0cacb9e7f67003e9973f81264f253ee586ec65f3efca1ac22ae542d1"
    let privateKey = "352053949d33311161e936a96b8c3534019dd5f1af024054e5571b8f7f73b296"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(btnUnarch)
        view.addSubview(btnDecode)
        view.addSubview(btnShare)
        btnUnarch.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-100)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        btnDecode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        btnShare.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(-100)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    @objc func selectFile() {
        let file = FileBrowser(initialPath: FileParser.sharedInstance.documentsURL, allowEditing: true, showCancelButton: true)
        file.didSelectFile = { file in
            self.unArchFile(zipPath: file.filePath.path)
        }
        file.modalPresentationStyle = .fullScreen
        present(file, animated: true, completion: nil)
    }
    
    func unArchFile(zipPath: String) {
        if zipPath.isEmpty || !zipPath.hasSuffix("zip") {
            Toast.showToast(msg: "你没有选择压缩文件")
            return
        }
        
        let res = SSZipArchive.unzipFile(atPath: zipPath, toDestination: FileParser.sharedInstance.documentsURL.path.appending("/xlog"))
    }
    
    @objc func selectDecodeFile() {
        let file = FileBrowser(initialPath: FileParser.sharedInstance.documentsURL, allowEditing: true, showCancelButton: true)
        file.didSelectFile = { file in
            self.decodeXlog(logPath: file.filePath.path)
        }
        file.modalPresentationStyle = .fullScreen
        present(file, animated: true, completion: nil)
    }
    
    func decodeXlog(logPath: String) {
        if logPath.isEmpty || !logPath.hasSuffix("xlog") {
            Toast.showToast(msg: "xlog文件错误")
            return
        }
        let decoder = XlogDecoder()
        let outPath = FileParser.sharedInstance.documentsURL.path.appending("/decodeXlog")
        if !FileManager.default.fileExists(atPath: outPath) {
            try? FileManager.default.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }
        let res = decoder.decode(atPath: logPath, privateKey: privateKey, outPath: outPath.appending("/1.log"))
        Toast.showToast(msg: res ? "解码成功" : "解码失败")
    }
    
    @objc func selectShareLog() {
        let file = FileBrowser(initialPath: FileParser.sharedInstance.documentsURL, allowEditing: true, showCancelButton: true)
        file.didSelectFile = { file in
            self.shareLog(logPath: file.filePath.path)
        }
        file.modalPresentationStyle = .fullScreen
        present(file, animated: true, completion: nil)
    }
    
    func shareLog(logPath: String) {
        let items = [URL(fileURLWithPath: logPath)] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        activityVC.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
        UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { _, _, _, _ in
        }
    }
    
    lazy var btnUnarch: UIButton = {
        let v = UIButton()
        v.setTitle("解压文件", for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 15)
        v.setTitleColor(.blue, for: .normal)
        v.addTarget(self, action: #selector(selectFile), for: .touchUpInside)
        return v
    }()
    
    lazy var btnDecode: UIButton = {
        let v = UIButton()
        v.setTitle("解码Xlog", for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 15)
        v.setTitleColor(.blue, for: .normal)
        v.addTarget(self, action: #selector(selectDecodeFile), for: .touchUpInside)
        return v
    }()
  
    lazy var btnShare: UIButton = {
        let v = UIButton()
        v.setTitle("分享Xlog", for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 15)
        v.setTitleColor(.blue, for: .normal)
        v.addTarget(self, action: #selector(selectShareLog), for: .touchUpInside)
        return v
    }()
}
