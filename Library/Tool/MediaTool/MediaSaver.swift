//
//  MediaSave.swift
//  WeAblum
//
//  Created by Stan Hu on 2026/3/13.
//  Copyright © 2026 WeAblum. All rights reserved.
//

import Photos
import UIKit

/// 媒体保存到相册的结果类型
/// - 用于 `saveToAlbum` 等接口在完成回调中向上层传递成功/失败原因
enum MediaResult: LocalizedError, Equatable {
    /// 保存成功
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

/// 已下载或本地的媒体数据载体
/// - 抽象图片、GIF、LivePhoto、视频、PDF、ZIP，便于上层统一处理
enum MediaData {
    /// 普通图片（含可选的本地缓存路径与原始 URL）
    case image(img: UIImage?, path: String?, originUrl: String),
         /// GIF 图（保留原始 Data 以便保存为动图）
         gif(data: Data?, path: String?, originUrl: String),
         /// LivePhoto（图片 + 配对视频路径）
         livePhoto(img: UIImage?, imgUrl: String, videoUrl: String),
         /// 视频，包含本地路径、原始 URL 与封面图
         video(path: String, originUrl: String, cover: UIImage?),
         /// pdf文件，包含本地路径、原始 URL
         pdf(path: String, originUrl: String),
         /// zip文件，包含本地路径、原始 URL
         zip(path: String, originUrl: String)

    /// 是否为 GIF 类型（依据底层 Data 判断）
    var isGif: Bool {
        if case .gif(let data, let path, _) = self {
            if let data = data {
                return data.isGif
            }
            return path?.lowercased().hasSuffix(".gif") ?? false
        }
        return false
    }
    
    /// 通过原始二进制数据初始化
    /// - 自动识别 GIF / 普通图片，无法解析时返回 nil
    /// - Parameters:
    ///   - data: 原始数据（如下载到的 image data）
    ///   - path: 本地缓存路径（可选）
    ///   - originUrl: 原始 URL，用于日志与去重
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
    
    /// 通过本地视频路径初始化（默认无封面）
    init(videoPath: String, originUrl: String) {
        self = .video(path: videoPath, originUrl: originUrl, cover: nil)
    }
    
    /// 取出图片对象
    /// - 仅 `.image` 类型有效；优先从本地路径读取，回落到内存中的 UIImage
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
    
    /// 获取静态预览图
    /// - image：返回原图
    /// - gif：返回 GIF 第一帧
    /// - livePhoto：返回 LivePhoto 的封面图
    /// - video：返回视频封面
    var stillImage: UIImage? {
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
            } else if let path = path, FileManager.default.fileExists(atPath: path) {
                return UIImage(contentsOfFile: path)
            }
        case .livePhoto(let img, _, _):
            return img
        case .video(_, _, let cover):
            return cover
        case .pdf, .zip:
            return nil
        }
        return nil
    }
    
    /// 视频本地路径（仅 `.video` 类型有效）
    var videoPath: String? {
        if case .video(let path, _, _) = self {
            return path
        }
        return nil
    }

    /// 单文件媒体的本地路径。
    /// - LivePhoto 由图片和视频两个文件组成，不提供单一文件路径。
    var filePath: String? {
        switch self {
        case .image(_, let path, _), .gif(_, let path, _):
            return path
        case .video(let path, _, _), .pdf(let path, _), .zip(let path, _):
            return path
        case .livePhoto:
            return nil
        }
    }
    
    /// 获取media的原始url
    var originUrl: String? {
        switch self {
        case .image(_, _, let originUrl):
            return originUrl
        case .gif(_, _, let originUrl):
            return originUrl
        case .livePhoto(_, let imgUrl, _):
            return imgUrl
        case .video(_, let originUrl, _):
            return originUrl
        case .pdf(_, let originUrl), .zip(_, let originUrl):
            return originUrl
        }
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
    
    /// 调试获取哪张保存失败
    ///     /// - Parameters:
    ///   - albumName: 目标相册名（为空时取 BundleDisplayName 或默认 "微购相册"）
    ///   - index: media的index
    func debugSaveOneByOne(albumName: String, index: Int = 0) {
        guard index < self.count else {
            return
        }
        let media = self[index]
        let url = media.originUrl
        [media].saveToAlbum(albumName: albumName) { result in
            switch result {
            case .OK:
                break
            default:
                break
            }
            self.debugSaveOneByOne(albumName: albumName, index: index + 1)
        }
    }
    
    /// 将当前数组中的所有媒体一次性批量保存到指定相册
    /// - 流程：
    ///   1. 查找/创建目标相册（无权限/失败立即回调）
    ///   2. 在 `performChanges` 中按类型创建 PHAsset，统一加 1ms 步进的 creationDate 以保证保存顺序
    ///   3. 完成后将所有 PHAsset 加入相册，并删除本地临时文件
    /// - Parameters:
    ///   - albumName: 目标相册名（为空时取 BundleDisplayName 或默认 "微购相册"）
    ///   - completion: 主线程完成回调
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
                        if img.size.equalTo(.zero) {}
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

                case .pdf, .zip:
                    // 文档和压缩包不属于系统相册资源，由文件分享流程处理。
                    continue
                }
            }
                    
            guard let collection = targetCollection, !assetPlaceholders.isEmpty else {
                return
            }
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) {
                albumChangeRequest.addAssets(assetPlaceholders as NSArray)
            } else {}
            print("\(Date())图片添加完成")
        }, completionHandler: { success, err in
            let time2 = Date().timeIntervalSince(time1) * 1000
            if let err = err {
            } else {}
            DispatchQueue.main.async {
                if success {
                    completion?(.OK)
                } else {
                    completion?(.saveOperationFailed(err?.localizedDescription ?? "保存相册失败"))
                }
            }
            let deleteTemporaryFiles = {
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
            }
            #if WGTEST
            if err == nil {
                deleteTemporaryFiles()
            }
            #else
            deleteTemporaryFiles()
            #endif
        })
    }
}

/// 自定义相册操作错误类型
/// - 区分权限、创建失败、占位符缺失等多种场景，便于上层精准提示
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
