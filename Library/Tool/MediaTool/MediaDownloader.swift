//
//  MediaDownloader.swift
//  iOSWork
//
//  Created by Stan Hu on 2026/3/14.
//
/*
import Foundation
import Kingfisher
enum MediaDownloadError: LocalizedError {
    case emptyLocalPath(String)
    case invalidUrl(String)
    case sdWebError(NSError)
    case other(String)
    case cancel
}

// 目前只能用于笔记下载，不用于商品
class MediaDownQueue: Operation {
    var index = 0
    var url = ""
    var videoUrl = ""
    var finish: ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)?
    var mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? // 处理视频或者图片,完全解耦
    var request: DownloadTask?
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

    convenience init(url: String, videoUrl: String, index: Int, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)) {
        self.init()
        self.url = url
        self.videoUrl = videoUrl
        self.index = index
        self.mediaHandler = mediaHandler
        self.finish = completed
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        if !url.isEmpty {
            downloadImg()
        } else if !videoUrl.isEmpty {
            downloadVideo()
        } else {
            finish?(nil, nil)
            isFinished = true
        }
    }
    
    func downloadImg() {
        print("开始执行ImageDownQueue 第\(index)个，时间\(Date().timeIntervalSince1970)")
   
//        KingfisherManager.shared.retrieveImage(with: url,options: <#T##KingfisherOptionsInfo?#>) { result in
//            
//        }
//
        KingfisherManager.shared.retrieveImage(with: url) { res in
            
        }
        
       // DispatchQueue.global().async {
           
//            self.request = SDWebImageManager.shared.loadImage(with: URL(string: self.url.removingPercentEncoding!), options: options, progress: nil) { img, originImageData, err, _, _, _ in
//                print("下载完成ImageDownQueue，第\(self.index)个，时间\(Date().timeIntervalSince1970)")
//                guard let img = img, let imgData = originImageData else {
//                    self.setFinish(data: nil, err: err == nil ? .other("SDWebImageManager下载出现错误") : .sdWebError(err! as NSError))
//                    return
//                }
//                
////                    let tmpImage = WGShareModuleBaseTool.wgShare_rotate(img.imageOrientation, image: img)
////                    self.setFinish(data: imgData.isGif ? MediaData(data: imgData) : MediaData(img: tmpImage), err: nil)
//                
//                print("执行完成ImageDownQueue，第\(self.index)个，时间\(Date().timeIntervalSince1970)")
//            }
      //  }
    }
    
    func downloadVideo() {
        Downloader.download(url: videoUrl) { path, err in
            guard let path = path, err == nil else {
                self.setFinish(data: nil, err: .other(err?.localizedDescription ?? "\(self.videoUrl)下载出现错误"))
                return
            }
            let media = MediaData(videoPath: path)
            if let handler = self.mediaHandler {
                handler(media) { [weak self] processedMedia in
                    self?.setFinish(data: processedMedia, err: nil)
                }
            } else {
                self.setFinish(data: media, err: nil)
            }
        }
    }
    
    func setFinish(data: MediaData?, err: MediaDownloadError?) {
        if isCancelled {
            finish?(nil, .cancel)
        } else {
            finish?(data, err)
        }
        isFinished = true
    }
    
    override func cancel() {
        if isExecuting {
            request?.cancel()
            isFinished = true
            finish?(nil, .cancel)
        } else {
            isCancelled = true
        }
    }
}

class MediaDownloader: NSObject {
    var observation: NSKeyValueObservation?
    
    func download(imgUrls: [String], videoUrls: [String]?, progress: ((_ count: Int) -> Void)? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping ((_ img: [MediaData?]?, _ err: MediaDownloadError?) -> Void)) -> OperationQueue? {
        // 调用start执行队列的时候, 直接清空掉单例中的数组内容, 确保每次只操作一组
        var downloadFailCount = 0
        let urls = imgUrls + (videoUrls ?? [])
        if let invalidUrl = urls.first(where: { !isValidUrl($0) }) {
            completed(nil, .invalidUrl("存在无效的URL: \(invalidUrl)"))
            return nil
        }
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = UIDevice.availableMemory < 1500 ? 5 : 9
        var isCancel = false // 是否取消
        var isOverTime = false // 是否超时
        var error: MediaDownloadError?
        var arrImgs = [MediaData?](repeating: nil, count: urls.count)
        let t1 = Date().timeIntervalSince1970
        for item in urls.enumerated() {
            let imgUrl = item.offset < imgUrls.count ? item.element : ""
            let videoUrl = item.offset >= imgUrls.count ? item.element : ""
            let q = MediaDownQueue(url: imgUrl, videoUrl: videoUrl, index: item.offset, mediaHandler: mediaHandler) { data, err in
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
                    arrImgs[item.offset] = data
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
            if remainCount == 0 {
                let time = Date().timeIntervalSince1970 - t1
                print("下载所用时间\(time)秒")
                self.observation = nil
                if isCancel {
                    completed(nil, .cancel)
                } else {
                    if error != nil {
                        completed(nil, error)
                    } else {
                        completed(arrImgs, nil)
                    }
                }
            }
            progress?(urls.count - remainCount)
        })
        return oq
    }
    
    // 辅助方法：检查URL是否有效
    private func isValidUrl(_ url: String) -> Bool {
        // 检查是否为空
        guard !url.isEmpty else { return false }
        
        // 检查是否是有效的文件路径
        return url.hasPrefix("file") || url.hasPrefix("http")
    }
    
    @discardableResult
    func downloadDictImg(urls: [String]?, completed: @escaping ((_ imgs: [String: MediaData]?, _ err: MediaDownloadError?) -> Void)) -> OperationQueue? {
        guard let urls = urls else {
            completed(nil, .invalidUrl("存在空的url"))
            return nil
        }
        
        // 检查URL是否有效
        if let invalidUrl = urls.first(where: { !isValidUrl($0) }) {
            completed(nil, .invalidUrl("存在无效的URL: \(invalidUrl)"))
            return nil
        }
        
        return download(imgUrls: urls, videoUrls: nil, progress: nil) { img, err in
            if let imgs = img {
                var dictImgs = [String: MediaData]()
                for item in imgs.enumerated() where item.element != nil {
                    dictImgs[urls[item.offset]] = item.element
                }
                completed(dictImgs, nil)
            } else {
                completed(nil, err)
            }
        }
    }
    
    deinit {
        observation = nil
    }
}

class MediaBridge: NSObject {
    @objc func mediaDownload(imgs: [UIImage]) {
        let medias = imgs.map { MediaData(img: $0) }.compactMap { $0 }
        medias.saveToAlbum(albumName: "") { _ in
         }
     }
}
*/
