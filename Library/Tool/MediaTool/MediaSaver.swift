//
//  MediaSave.swift
//  WeAblum
//
//  Created by Stan Hu on 2026/3/13.
//  Copyright © 2026 WeAblum. All rights reserved.
//

import Foundation
import UIKit
import Photos

enum MediaResult: LocalizedError, Equatable {
    case OK
    /// 相册相关问题
    case albumError(AlbumError)
    /// 媒体数据为空（图片/GIF/视频数据无效）
    case emptyMediaData
    /// 视频 URL 无效（非本地文件/文件不存在）
    case invalidVideoURL(String)
    /// 媒体保存操作失败（Photos 框架返回错误）
    case saveOperationFailed(String)
    /// 未知错误
    case other(String)
    // 用户可读的错误描述
    var errorDescription: String {
        switch self {
        case .OK:
            return "成功"
        case .albumError(let err):
            return err.errorDescription
        case .emptyMediaData:
            return "媒体数据为空（图片/GIF/视频无效）"
        case .invalidVideoURL(let url):
            return "视频 URL 无效或文件不存在：\(url)"
        case .saveOperationFailed(let msg):
            return "媒体保存失败：\(msg)"
        case .other(let msg):
            return "未知错误：\(msg)"
        }
    }
}

enum MediaData {
    case image(img: UIImage?, path: String?, originUrl: String),
         gif(data: Data?, path: String?, originUrl: String),
         livePhoto(img: UIImage?, imgUrl: String, videoUrl: String),
         video(path: String, originUrl: String, cover: UIImage?) // 视频，本地url地址,和封面
    // 辅助判断：当前类型是否为GIF
    var isGif: Bool {
        if case .gif(let data, _, _) = self {
            return data?.isGif ?? false
        }
        return false
    }
    
    init?(data: Data?, path: String? = nil, originUrl: String) {
        guard let data = data else {
            self = .gif(data: nil, path: path, originUrl: originUrl)
            return
        }
        if data.isGif {
            self = .gif(data: data, path: path, originUrl: originUrl)
        } else if let img = UIImage(data: data) {
            self = .image(img: img, path: path, originUrl: originUrl)
        } else {
            return nil
        }
    }
    
    init(videoPath: String, originUrl: String) {
        self = .video(path: videoPath, originUrl: originUrl, cover: nil)
    }
    
    var image: UIImage? {
        if case .image(let img, let path, let originUrl) = self {
            if let path = path, FileManager.default.fileExists(atPath: path) {
                return UIImage(contentsOfFile: path)
            } else if let img = img {
                return img
            }
        }
        return nil
    }
    
    var stillImage: UIImage? { // 获取静态image，gif和livephoto的静态图片, 视频获取封面
        switch self {
        case .image(let img, let path, _):
            if let path = path, FileManager.default.fileExists(atPath: path) {
                return UIImage(contentsOfFile: path)
            } else if let img = img {
                return img
            }
        case .gif(let data, let path, _):
            if let data = data {
                return UIImage(data: data)
            }
        case .livePhoto(let img, let imgUrl, let videoUrl):
            return img
        case .video(_, _, let cover):
            return cover
        }
        return nil
    }
    
    var videoPath: String? {
        if case .video(let path, let originUrl, _) = self {
            return path
        }
        return nil
    }
}

extension Array where Element == MediaData {
    // 显示下载的图片
    func showImgs(inView: UIView) {
        let view = UIView()
        var x: CGFloat = 0
        var y: CGFloat = 100
        let itemWidth = UIScreen.main.bounds.size.width / 4
        
        for item in self {
            let imgView = UIImageView(image: item.image)
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            view.addSubview(imgView)
            imgView.snp.makeConstraints { make in
                make.left.equalTo(x)
                make.top.equalTo(y)
                make.width.height.equalTo(itemWidth)
            }
            if x + itemWidth >= UIScreen.main.bounds.size.width {
                x = 0
                y += itemWidth
            } else {
                x += itemWidth
            }
        }
        let btnClose = UIButton()
        btnClose.setTitle("关闭", for: .normal)
        btnClose.setTitleColor(.red, for: .normal)
        btnClose.addClickEvent { btn in
            btn.superview?.removeFromSuperview()
        }
        view.addSubview(btnClose)
        btnClose.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        inView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    func saveToAlbum(albumName: String, completion: ((_ result: MediaResult) -> Void)? = nil) {
        // 空数组直接返回成功
        guard !isEmpty else {
            DispatchQueue.main.async {
                completion?(.OK)
            }
            return
        }
        // 1. 查找/创建目标相册
        var targetCollection: PHAssetCollection?
        var needDeleteFiles = [String]()
        var albumError: AlbumError?
        let name = albumName.isEmpty ? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "微购相册" : albumName
        let albumResult = PHAssetCollection.named(name)
        switch albumResult {
        case .failure(let error):
            albumError = error
        case .success(let collection):
            targetCollection = collection
        }
        // 相册创建失败 → 直接回调
        if let error = albumError {
            DispatchQueue.main.async {
                completion?(.albumError(error))
            }
            return
        }
                
        let time1 = Date()
        var baseTime = Date().timeIntervalSince1970
        let timeStep: TimeInterval = 0.001 // 1毫秒偏移，确保顺序
        print("\(Date())开始保存")
        PHPhotoLibrary.shared().performChanges({
            var assetPlaceholders: [PHObjectPlaceholder] = []
            // 处理当前批次的每一个媒体
            for media in self {
                baseTime += timeStep
                let currentDate = Date(timeIntervalSince1970: baseTime)
                switch media {
                case .image(let img, let path, let originUrl):
                    if let path = path, FileManager.default.fileExists(atPath: path) { // 优先使用path
                        let fileUrl = URL(fileURLWithPath: path)
                        let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl) // gif图像也可以用这个保存
                        needDeleteFiles.append(path)
                        creationRequest?.creationDate = currentDate // 统一设置
                        if let placeholder = creationRequest?.placeholderForCreatedAsset {
                            assetPlaceholders.append(placeholder)
                        } else {
                            // 异常 placeholder 失败
                        }
                    } else if let img = img {
                        if img.size.equalTo(.zero) {
                           // swift_LLog("保存media会失败-------图片为空\(originUrl)")
                        }
                        let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: img)
                        creationRequest.creationDate = currentDate
                        if let placeholder = creationRequest.placeholderForCreatedAsset {
                            assetPlaceholders.append(placeholder)
                        }
                    } else {
                        continue
                    }

                case .gif(let data, let path, let originUrl):
                    if let path = path, FileManager.default.fileExists(atPath: path) { // 优先使用path
                        let fileUrl = URL(fileURLWithPath: path)
                        let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl) // gif图像也可以用这个保存
                        needDeleteFiles.append(path)
                        creationRequest?.creationDate = currentDate
                        if let placeholder = creationRequest?.placeholderForCreatedAsset {
                            assetPlaceholders.append(placeholder)
                        } else {
                            // 异常 placeholder 失败
                        }
                    } else if let data = data {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.creationDate = currentDate
                        let options = PHAssetResourceCreationOptions()
                        options.uniformTypeIdentifier = "com.compuserve.gif"
                        creationRequest.addResource(with: .photo, data: data, options: options)
                        if let placeholder = creationRequest.placeholderForCreatedAsset {
                            assetPlaceholders.append(placeholder)
                        }
                    } else {
                       // swift_LLog("保存media会失败-------gif图片异常\(originUrl)")
                        continue
                    }
                
                case .video(let urlStr, let originUrl, _):
                    let fileUrl = URL(fileURLWithPath: urlStr)
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = false
                    creationRequest.addResource(with: .video, fileURL: fileUrl, options: options)
                    creationRequest.creationDate = currentDate
                    needDeleteFiles.append(urlStr)
                    if let placeholder = creationRequest.placeholderForCreatedAsset {
                        assetPlaceholders.append(placeholder)
                    }
                        
                case .livePhoto(_, let imgUrl, let videoUrl):
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: videoUrl), options: options)
                    creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: imgUrl), options: options)
                    creationRequest.creationDate = currentDate
                    needDeleteFiles.append(videoUrl)
                    needDeleteFiles.append(imgUrl)
                    if let placeholder = creationRequest.placeholderForCreatedAsset {
                        assetPlaceholders.append(placeholder)
                    }
                }
            }
                    
            guard let collection = targetCollection, !assetPlaceholders.isEmpty else {
                return
            }
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) {
                albumChangeRequest.addAssets(assetPlaceholders as NSArray)
            }
            print("\(Date())图片添加完成")
        }, completionHandler: { success, err in
            let time2 = Date().timeIntervalSince(time1) * 1000
            if let err = err {
              //  swift_LLog("保存media-------失败，原因\(err)")
            } else {
               // swift_LLog("保存media-------\(self.count)张保存成功,耗时\(time2)ms")
            }
            DispatchQueue.main.async {
                if success {
                    completion?(.OK)
                } else {
                    completion?(.saveOperationFailed(err?.localizedDescription ?? "保存相册失败"))
                }
            }
            DispatchQueue.global(qos: .background).async {
                for path in needDeleteFiles {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                        print("删除成功：\(path)")
                    } catch {
                        print("删除文件失败：\(error)")
                    }
                }
            }
        })
    }
}

enum AlbumError: LocalizedError, Equatable {
    /// 相册写入权限被拒绝/受限
    case permissionDenied
    /// 相册创建操作失败（performChangesAndWait 抛出异常）
    case createFailed(String)
    /// 创建相册后获取不到占位符（placeholder 为 nil）
    case placeholderNotFound
    /// 创建相册后无法获取新相册实例
    case collectionFetchFailed
    /// 未知错误
    case unknown(String)
    
    // 实现 LocalizedError，返回用户可读的错误描述
    var errorDescription: String {
        switch self {
        case .permissionDenied:
            return "相册写入权限被拒绝，请在设置中开启"
        case .createFailed(let msg):
            return "创建相册失败：\(msg)"
        case .placeholderNotFound:
            return "创建相册后未获取到占位符，无法定位新相册"
        case .collectionFetchFailed:
            return "创建相册后，无法获取新相册实例"
        case .unknown(let msg):
            return "未知错误：\(msg)"
        }
    }
}
