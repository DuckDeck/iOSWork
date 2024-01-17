//
//  VideoPlayViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/15.
//

import UIKit
import AVKit
class VideoPlayViewController: BaseViewController {

    var url:URL!
    let btnClose = UIButton()
    var dictDes = [String:String]()
    var shadowPlayer:ShadowVideoPlayerView!
    let btnDelete = UIButton()
    let btnCompress = UIButton()
    var deleteBlock:((_ url:URL)->Void)?
    var compressBlock:((_ url:URL)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "视频信息"
        btnClose.title(title: "关闭").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.2)
            m.bottom.equalTo(-50)
        }
        btnClose.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        if url == nil{
            Toast.showToast(msg: "没有url")
            return
        }
      
        
        shadowPlayer = ShadowVideoPlayerView(frame: CGRect(), url: url)
        shadowPlayer.player.isAutoPlay = false
        shadowPlayer.title = url.lastPathComponent
        shadowPlayer.backgroundColor = UIColor.black
        view.addSubview(shadowPlayer)
        shadowPlayer.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(UIDevice.topAreaHeight)
            m.height.equalTo(ScreenHeight * 0.7)
        }
        
        
        btnDelete.title(title: "删除").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.4)
            m.bottom.equalTo(-50)
        }
        btnDelete.addTarget(self, action: #selector(deleteFile), for: .touchUpInside)
      
        btnCompress.title(title: "压缩").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.6)
            m.bottom.equalTo(-50)
        }
        btnCompress.addTarget(self, action: #selector(compress), for: .touchUpInside)
        
//        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path){
//            let size = attr[FileAttributeKey.size] as! Int
//            dictDes["文件大小"] = "\(size / 1000000)M"
//            dictDes["创建日期"] = "\(attr[FileAttributeKey.creationDate]!)"
//        }
//        dictDes["扩展名"] = url.pathExtension
//        let info = shadowPlayer.getVideoInfo()
//        for item in info{
//            dictDes[item.0] = item.1
//        }
//        var tmp:UIView! = nil
//
//        for info in dictDes{
//            let lbl = UILabel().text(text: "\(info.key) : \(info.value)").color(color: UIColor.darkGray).addTo(view: view)
//            lbl.snp.makeConstraints { (m) in
//                m.left.equalTo(15)
//                if tmp == nil{
//                    m.top.equalTo(350)
//                }
//                else{
//                    m.top.equalTo(tmp.snp.bottom).offset(5)
//                }
//                m.height.equalTo(25)
//            }
//            tmp = lbl
//        }
      
        
    }

    
    @objc func closePage() {
        shadowPlayer?.stop()
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func compress() {
        shadowPlayer?.stop()
        let newFileName = url.absoluteString.split(".").first! + "compress.mp4"
        Toast.showLoading()
        let newUrl = URL(string: newFileName)!
        compressVideo(inputUrl: url, outputUrl: newUrl) { (export) in
            DispatchQueue.main.async {
                Toast.showToast(msg: "压缩完成")
                self.dismiss(animated: true) {
                    self.compressBlock?(newUrl)
                }
            }
        }
        
    }
    
    @objc func deleteFile() {
        
        UIAlertController.title(title: "删除该视频", message: nil).action(title: "取消", handle: nil).action(title: "确定", handle:{ (action:UIAlertAction) in
            self.shadowPlayer.stop()
            VideoFileManager.removeFile(url: self.url)
            self.dismiss(animated: true) {
                self.deleteBlock?(self.url)
            }
        }).showAlert(viewController: self)
    }


    func compressVideo(inputUrl:URL,outputUrl:URL,completed:@escaping ((_ export:AVAssetExportSession) ->Void))  {
        let avAsset = AVURLAsset(url: inputUrl, options: nil)
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) else{
            return
        }
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status{
            case .cancelled:
                print("AVAssetExportSessionStatusCancelled")
            case .unknown:
                print("AVAssetExportSessionStatusUnknown")
            case .waiting:
                print("AVAssetExportSessionStatusWaiting")
            case .exporting:
                print("AVAssetExportSessionStatusExporting")
            case .completed:
                 print("AVAssetExportSessionStatusCompleted")
                completed(exportSession)
            case .failed:
                print("AVAssetExportSessionStatusFailed")
            @unknown default:
                break
            }
        }
        
    }
}
