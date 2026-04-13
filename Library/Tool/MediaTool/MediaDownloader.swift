//
//  MediaDownloader.swift
//  WeAblum
//
//  Created by Stan Hu on 2026/3/12.
//  Copyright © 2026 WeAblum. All rights reserved.
//

import Foundation
import Kingfisher
import Alamofire

enum MediaDownloadError: LocalizedError, Equatable {
    case emptyLocalPath(String)
    case invalidUrl(String)
    case fileNotExistOrWrong(String)
    case kfWebError(NSError)
    case other(String)
    case cancel
    
    var localizedDescription: String {
        switch self {
        case .emptyLocalPath(let string):
            return "路径为空"
        case .invalidUrl(let string):
            return "下载的url非法"
        case .fileNotExistOrWrong(let string):
            return "文件不存在或者错误"
        case .kfWebError(let nSError):
            return nSError.localizedDescription
        case .other(let str):
            return str
        case .cancel:
            return "取消下载"
        }
    }
}

enum MediaSource: Hashable, Equatable {
    case img(String)
    case video(String, String?) // 第二个参数是视频封面
    case livePhoto(String, String) // 动态图, 前面是imgurl，后面是videourl
    var isLivePhoto: Bool {
        if case .livePhoto = self {
            return true
        }
        return false
    }

    var isValid: Bool {
        switch self {
        case .img(let url):
            return url.hasPrefix("file") || url.hasPrefix("http") || url.hasPrefix("/private/var/mobile")
        case .video(let url, _):
            return url.hasPrefix("file") || url.hasPrefix("http")
        case .livePhoto(let imgUrl, let videoUrl):
            return (imgUrl.hasPrefix("file") || imgUrl.hasPrefix("http")) && (videoUrl.hasPrefix("file") || videoUrl.hasPrefix("http"))
        }
    }
    
    var fileUrl: String {
        switch self {
        case .img(let url):
            return FileManager.default.fileExists(atPath: url) ? url : ""
        case .video(let url, _):
            return FileManager.default.fileExists(atPath: url) ? url : ""
        case .livePhoto:
            return ""
        }
    }
}

struct DownloadConfig {
    var onlyShowLiveImage = false // 默认情况下LivePhoto只下载，不用于显示，如果需要显示，设置为true， 会同时获取UIImage和 沙盒url
}

// 目前只能用于笔记下载，不用于商品
class MediaDownQueue: Operation, @unchecked Sendable {
    var index = 0
    let source: MediaSource
    var config: DownloadConfig?
    let finish: (_ data: MediaData?, _ err: MediaDownloadError?) -> Void
    var mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? // 处理视频或者图片,完全解耦
    var task:Kingfisher.DownloadTask?
    private var _finished: Bool = false
    override private(set) var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    private var _isCancelled: Bool = false

    override private(set) var isCancelled: Bool {
        get { return _isCancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _isCancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    init(source: MediaSource, index: Int, config: DownloadConfig? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping (_ data: MediaData?, _ err: MediaDownloadError?) -> Void) {
        self.source = source
        self.index = index
        self.config = config
        self.finish = completed
        self.mediaHandler = mediaHandler
        // 调用父类Operation初始化
        super.init()
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        switch source {
        case .img(let url):
            download(imgUrl: url) { media, err in
                if let mediaHandler = self.mediaHandler, let media = media {
                    mediaHandler(media) { media in
                        self.setFinish(data: media, err: err)
                    }
                } else {
                    self.setFinish(data: media, err: err)
                }
            }
        case .video(let url, let cover):
            var videoMedia: MediaData?
            var imgCover: UIImage?
            let group = DispatchGroup()
            var error: MediaDownloadError?
            if let cover = cover, cover.hasPrefix("http") {
                group.enter()
                download(imgUrl: cover) { data, _ in
                    imgCover = data?.image
                    group.leave()
                }
            }
            group.enter()
            download(videoUrl: url) { media, err in
                videoMedia = media
                error = err
                group.leave()
            }
            group.notify(queue: .global()) {
                guard let videoMedia = videoMedia, error == nil else {
                    self.setFinish(data: nil, err: error)
                    return
                }
                if let mediaHandler = self.mediaHandler { // onlyShowLiveImage 为true不需要合成
                    mediaHandler(videoMedia) { _ in
                        self.setFinish(data: .video(path: videoMedia.videoPath ?? "", originUrl: url, cover: imgCover), err: nil)
                    }
                } else {
                    self.setFinish(data: .video(path: videoMedia.videoPath ?? "", originUrl: url, cover: imgCover), err: nil)
                }
            }
        case .livePhoto(let imgUrl, let videoUrl):
            let group = DispatchGroup()
            var liveImg: UIImage?
            var imgPath = ""
            var videoPath = ""
            var error: MediaDownloadError?
            var needDownloadVideo = true
            if let config = config, config.onlyShowLiveImage { // 只显示图片
                needDownloadVideo = false
            }
            if needDownloadVideo { // 这种情况不需要下载视频
                group.enter()
                download(videoUrl: videoUrl) { media, err in
                    if case .video(let url, _, _) = media {
                        videoPath = url
                    } else {
                        error = err
                    }
                    group.leave()
                }
            }
            
            group.enter()
            download(imgUrl: imgUrl) { data, err in
                error = err
                switch data {
                case .image(let img, let path, _):
                    liveImg = img
                    if let path = path, !path.isEmpty {
                        imgPath = path
                    } else {
                        // 如果保存UIImage失败，那么要不要错误处理。。。。。
                        error = .other("生成LivePhoto图片保存本地失败")
                    }
                default:
                    error = .other("生成LivePhoto图片类型错误")
                }
                group.leave()
            }
            group.notify(queue: .global()) {
                if error != nil {
                    self.setFinish(data: nil, err: error)
                    return
                }
                if let mediaHandler = self.mediaHandler, !(self.config?.onlyShowLiveImage ?? false) { // onlyShowLiveImage 为true不需要合成
                    mediaHandler(.livePhoto(img: liveImg, imgUrl: imgPath, videoUrl: videoPath)) { media in // 合成图片
                        self.setFinish(data: media, err: nil)
                    }
                } else {
                    self.setFinish(data: .livePhoto(img: liveImg, imgUrl: imgPath, videoUrl: videoPath), err: nil)
                }
            }
        }
    }
    
    func download(imgUrl: String, completed: @escaping ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)) {
        var url = imgUrl
        print("开始执行ImageDownQueue 第\(index)个，时间\(Date().timeIntervalSince1970)")
      //  swift_LLog("图文下载:==开始）\(url ?? "没有url")")
        
        if url.hasPrefix("/private/var/mobile") {
            if FileManager.default.fileExists(atPath: url), let data = FileManager.default.contents(atPath: url) {
                completed(MediaData(data: data, path: url, originUrl: url), nil)
            } else {
                completed(nil, .fileNotExistOrWrong(url))
            }
            return
        }
        
       
        DispatchQueue.global().async {
            var options: KingfisherOptionsInfo = [
                // 对应 .retryFailed: Kingfisher 使用重试策略
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(1))),
                
                // 对应 .queryMemoryData: Kingfisher 默认就会查询内存缓存
                // 如果你希望只从缓存取而不下载，可以使用 .onlyFromCache
                .loadDiskFileSynchronously, // 类似 SD 的某些同步行为（可选）
               
            ]
            guard let downloadURL = URL(string: url.removingPercentEncoding ?? "") else { return }
            self.task = KingfisherManager.shared.retrieveImage(with: downloadURL, options: options) { result in
                switch result {
                case .success(let value):
                    var needSave = false
                     let img = value.image
                    guard let imgData = value.data()  else {
                        completed(nil, .other("kf返回数据异常，无法转换成data"))
                        return
                    }
                    var isGif = imgData.isGif
                    if isGif || self.source.isLivePhoto {
                        needSave = true
                    }
                    if let config = self.config, config.onlyShowLiveImage {
                        needSave = false
                    }
                    var media: MediaData?
                    if needSave {
                        do {
                            let filePath = "\(NSTemporaryDirectory())/MediaHDCache/\(self.index)_HD_Tmp\(isGif ? ".gif" : ".png")"
                            try imgData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                            media = MediaData(data: imgData, path: filePath, originUrl: imgUrl)
                        } catch {
                          //  APMLog("高清上图---把高清数据写入文件中失败, 回传originImageData❌, 失败下标是\(self.index), 失败原因\(error.localizedDescription)")
                            media = MediaData(data: imgData, path: nil, originUrl: imgUrl)
                        }
                    } else {
                        media = MediaData(data: imgData, path: nil, originUrl: imgUrl)
                    }
                    completed(media, nil)
                    print("执行完成ImageDownQueue，第\(self.index)个，时间\(Date().timeIntervalSince1970)")
                case .failure(let err):
                    completed(nil, .kfWebError(err as NSError))
                    return
                }
            }
            
        }
    }
    
    func download(videoUrl: String,dir : URL? = nil, completed: @escaping ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)) {
        
        let download = HttpClient.session.download(videoUrl, to: { _, res in
            var d = dir
            if d == nil{
                d = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!.appendingPathComponent("download")
            }
            if !FileManager.default.fileExists(atPath: d!.path){
               try?  FileManager.default.createDirectory(at: d!, withIntermediateDirectories: true)
            }
            self.removeVideoFileWithPath(d!.path)
            var name = res.suggestedFilename!
            if !name.hasSuffix(".mp4") && !name.hasSuffix(".jpg")  && !name.hasSuffix(".jpeg") && !name.hasSuffix(".png") && !name.hasSuffix(".webp"){
                let mimeType = res.mimeType ?? ""
                if mimeType.contains("image"){
                    name = name + ".jpg"
                } else if mimeType.contains("mp4"){
                    name = name + ".mp4"
                }
            }
           
            let fileUrl = d!.appendingPathComponent(name)
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        })
        download.response(queue: DispatchQueue.main) { resData in
            if resData.error != nil {
                completed(nil, .kfWebError(resData.error! as NSError))
            } else {
                completed(.video(path: resData.fileURL!.path, originUrl: videoUrl, cover: nil), nil)
            }
        }
        
    }
    
    func removeVideoFileWithPath(_ path: String) {
        let fi = FileManager.default
        var isDir = ObjCBool(false)
        if fi.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                do {
                    let dirs = try fi.contentsOfDirectory(atPath: path)
                    for str in dirs {
                        var videoPath = path
                        videoPath.append(str)
                        if videoPath.contains(".mp4") {
                            do {
                                try fi.removeItem(atPath: videoPath)
                            } catch {}
                        }
                    }
                } catch {}
            }
        }
    }
    
    func setFinish(data: MediaData?, err: MediaDownloadError?) {
        if isCancelled {
            finish(nil, .cancel)
        } else {
            finish(data, err)
        }
        isFinished = true
    }
    
    override func cancel() {
        if isExecuting {
            task?.cancel()
            isFinished = true
            finish(nil, .cancel)
        } else {
            isCancelled = true
        }
    }
}

class MediaDownloader: NSObject {
    var observation: NSKeyValueObservation?
    
    func createMediaHDCache() {
        let filePath = NSTemporaryDirectory().appending("/MediaHDCache")
        
        var isDir: ObjCBool = true
        let fileExists = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
        
        // 如果文件夹不存在，则创建文件夹
        if !fileExists {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建文件夹失败: \(error.localizedDescription)")
            }
        }
    }
    
    func download(sources: [MediaSource], config: DownloadConfig? = nil, progress: ((_ count: Int) -> Void)? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping ((_ img: [MediaData]?, _ err: MediaDownloadError?) -> Void)) -> OperationQueue? {
        // 调用start执行队列的时候, 直接清空掉单例中的数组内容, 确保每次只操作一组
        var downloadFailCount = 0
        
        if let invalidUrl = sources.first(where: { !$0.isValid }) {
            completed(nil, .invalidUrl("存在无效的URL: \(invalidUrl)"))
            return nil
        }
        createMediaHDCache()
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = UIDevice.availableMemory < 1500 ? 5 : 9
        var isCancel = false // 是否取消
        var isOverTime = false // 是否超时
        var error: MediaDownloadError?
        var arrMedia = [MediaData](repeating: .image(img: nil, path: nil, originUrl: ""), count: sources.count)
        let t1 = Date().timeIntervalSince1970
        for item in sources.enumerated() {
            let q = MediaDownQueue(source: item.element, index: item.offset, config: config, mediaHandler: mediaHandler) { data, err in
                if let err = err {
                    if err.localizedDescription == "Request explicitly cancelled." {
                        isCancel = true
                    } else if err.localizedDescription.contains("请求超时") {
                        downloadFailCount += 1
                        isOverTime = true
                        error = err
                        oq.cancelAllOperations()
                    } else {
                        error = err
                        downloadFailCount += 1
                    }
                } else if let data = data {
                    arrMedia[item.offset] = data
                }
            }
            oq.addOperation(q)
        }
        observation = oq.observe(\.operationCount, options: [.new], changeHandler: { _, change in
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^当前队列数为\(change.newValue ?? 0)^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            guard let remainCount = change.newValue else {
                completed(nil, .other("newValue 无法获取"))
                return
            }
            DispatchQueue.main.async {
                if remainCount == 0 {
                    let time = Date().timeIntervalSince1970 - t1
                    print("下载所用时间\(time)秒")
                   // swift_LLog("下载图片-------下载所用时间\(time)秒，其中有\(downloadFailCount)张图片下载错误")
                    self.observation = nil
                    if isCancel {
                        completed(nil, .cancel)
                    } else {
                        if error != nil {
                            completed(nil, error)
                        } else {
                            completed(arrMedia, nil)
                        }
                    }
                }
                progress?(sources.count - remainCount)
            }
        })
        return oq
    }
    
    // 下载图片资源，并保证下载顺序,且不管url是否正常
    func download(imgs: [String], config: DownloadConfig? = nil, progress: ((_ count: Int) -> Void)? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping ((_ img: [MediaData?]?, _ err: MediaDownloadError?) -> Void)) -> OperationQueue? {
        // 调用start执行队列的时候, 直接清空掉单例中的数组内容, 确保每次只操作一组
        var downloadFailCount = 0
        
        
        createMediaHDCache()
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = UIDevice.availableMemory < 1500 ? 5 : 9
        var isCancel = false // 是否取消
        var isOverTime = false // 是否超时
        var error: MediaDownloadError?
        var arrMedia = [MediaData?](repeating: nil, count: imgs.count)
        let t1 = Date().timeIntervalSince1970
        for item in imgs.enumerated() {
            if !item.element.hasPrefix("file") && !item.element.hasPrefix("http") && !item.element.hasPrefix("/private/var/mobile") {
                continue
            }
            
            let q = MediaDownQueue(source: .img(item.element), index: item.offset, config: config, mediaHandler: mediaHandler) { data, err in
                if let err = err {
                    if err.localizedDescription == "Request explicitly cancelled." {
                        isCancel = true
                    } else if err.localizedDescription.contains("请求超时") {
                        downloadFailCount += 1
                        isOverTime = true
                        error = err
                        oq.cancelAllOperations()
                    } else {
                        error = err
                        downloadFailCount += 1
                    }
                } else if let data = data {
                    arrMedia[item.offset] = data
                }
            }
            oq.addOperation(q)
        }
        observation = oq.observe(\.operationCount, options: [.new], changeHandler: { _, change in
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^当前队列数为\(change.newValue ?? 0)^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            guard let remainCount = change.newValue else {
                completed(nil, .other("newValue 无法获取"))
                return
            }
            DispatchQueue.main.async {
                if remainCount == 0 {
                    let time = Date().timeIntervalSince1970 - t1
                    print("下载所用时间\(time)秒")
               //     swift_LLog("下载图片-------下载所用时间\(time)秒，其中有\(downloadFailCount)张图片下载错误")
                    self.observation = nil
                    if isCancel {
                        completed(nil, .cancel)
                    } else {
                        if error != nil {
                            completed(nil, error)
                        } else {
                            completed(arrMedia, nil)
                        }
                    }
                }
                progress?(imgs.count - remainCount)
            }
        })
        return oq
    }
    
    deinit {
        observation = nil
    }
}
