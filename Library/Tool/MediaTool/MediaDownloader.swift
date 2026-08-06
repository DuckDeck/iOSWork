//
//  MediaDownloader.swift
//  WeAblum
//
//  Created by Stan Hu on 2026/3/12.
//  Copyright © 2026 WeAblum. All rights reserved.
//

import Foundation
import ImageIO
import MobileCoreServices
import Kingfisher
/// 媒体下载过程中可能产生的错误类型
/// - 用于 `MediaDownloader` 与 `MediaDownQueue` 在下载失败时回调给上层
enum MediaDownloadError: LocalizedError, Equatable {
    /// 本地路径为空（如 LivePhoto/视频本地资源未取到）
    case emptyLocalPath(String)
    /// 下载使用的 URL 不合法（既不是 file/http 也不是受支持的本地路径）
    case invalidUrl(String)
    /// 本地文件不存在或读取失败
    case fileNotExistOrWrong(String)
    /// Kingfisher 下载图片返回的底层错误
    case kfWebError(NSError)
    /// 其他未分类错误，附带错误描述
    case other(String)
    /// 任务被主动取消
    case cancel
    /// 服务端返回了暂不支持的 MIME 类型
    case unsupportedMimeType(String)
    /// HTTP 状态码不在成功范围内
    case httpStatus(Int)
    /// 文件创建、复制或移动失败
    case fileOperationFailed(String)
    
    /// 错误的本地化描述（用于日志/UI 提示）
    var localizedDescription: String {
        switch self {
        case .emptyLocalPath(let string):
            return "路径为空"
        case .invalidUrl(let url):
            return "下载的url非法_\(url)"
        case .fileNotExistOrWrong(let path):
            return "文件不存在或者错误_\(path)"
        case .kfWebError(let nSError):
            return nSError.localizedDescription
        case .other(let str):
            return str
        case .cancel:
            return "取消下载"
        case .unsupportedMimeType(let mimeType):
            return "不支持的文件类型_\(mimeType)"
        case .httpStatus(let statusCode):
            return "文件下载失败_HTTP \(statusCode)"
        case .fileOperationFailed(let message):
            return "文件处理失败_\(message)"
        }
    }
}

/// 待下载的媒体资源描述
/// - 用于在调用方组装下载任务时声明每一项资源的类型与所需 URL
enum MediaSource: Hashable, Equatable {
    /// 普通图片（含 GIF），参数为图片 URL
    case img(String)
    /// 视频，第一个参数是视频 URL，第二个参数是视频封面 URL（可选）
    case video(String, String?)
    /// 动态图（LivePhoto），第一个参数是图片 URL，第二个参数是视频 URL
    case livePhoto(String, String)

    /// 是否为 LivePhoto 类型
    var isLivePhoto: Bool {
        if case .livePhoto = self {
            return true
        }
        return false
    }

    /// URL 是否合法（必须是 file://、http(s)://，图片还允许 /private/var/mobile 路径）
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
    
    /// 若资源对应的本地文件已存在则返回其路径，否则返回空串
    /// - LivePhoto 由于由两个文件组成，这里直接返回空串
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

/// 统一文件下载支持的最终文件类型。
private enum MediaDownloadedFileType {
    case image(String)
    case gif
    case video(String)
    case pdf
    case zip

    init?(mimeType: String) {
        let mimeType = mimeType.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        switch mimeType {
        case "image/jpeg", "image/jpg":
            self = .image("jpg")
        case "image/png":
            self = .image("png")
        case "image/gif":
            self = .gif
        case "image/webp":
            self = .image("webp")
        case "image/heic", "image/heif":
            self = .image(mimeType == "image/heic" ? "heic" : "heif")
        case "image/bmp", "image/x-ms-bmp":
            self = .image("bmp")
        case "image/tiff":
            self = .image("tiff")
        case "video/mp4":
            self = .video("mp4")
        case "video/quicktime":
            self = .video("mov")
        case "video/x-m4v":
            self = .video("m4v")
        case "video/mpeg":
            self = .video("mpeg")
        case "video/webm":
            self = .video("webm")
        case "application/pdf", "application/x-pdf":
            self = .pdf
        case "application/zip", "application/x-zip", "application/x-zip-compressed":
            self = .zip
        default:
            guard let fileExtension = Self.preferredFileExtension(mimeType: mimeType) else {
                return nil
            }
            if mimeType.hasPrefix("image/") {
                self = .image(fileExtension)
            } else if mimeType.hasPrefix("video/") {
                self = .video(fileExtension)
            } else {
                return nil
            }
        }
    }

    private static func preferredFileExtension(mimeType: String) -> String? {
        guard let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue(),
              let fileExtension = UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension)?.takeRetainedValue() else {
            return nil
        }
        return fileExtension as String
    }

    var fileExtension: String {
        switch self {
        case .image(let fileExtension), .video(let fileExtension):
            return fileExtension
        case .gif:
            return "gif"
        case .pdf:
            return "pdf"
        case .zip:
            return "zip"
        }
    }

    func mediaData(path: String, originUrl: String) -> MediaData {
        switch self {
        case .image:
            return .image(img: nil, path: path, originUrl: originUrl)
        case .gif:
            return .gif(data: nil, path: path, originUrl: originUrl)
        case .video:
            return .video(path: path, originUrl: originUrl, cover: nil)
        case .pdf:
            return .pdf(path: path, originUrl: originUrl)
        case .zip:
            return .zip(path: path, originUrl: originUrl)
        }
    }
}

/// 单个统一文件下载任务。持有返回值即可在需要时调用 `cancel()`。
/// 下载任务使用 URLSession 的临时文件机制，后续可在此基础上接入 resumeData 断点续传。
@objc(WGMediaFileDownloadToken)
final class WGMediaFileDownloadToken: NSObject, URLSessionDownloadDelegate {
    typealias ProgressBlock = (Float) -> Void
    typealias SpeedBlock = (Int64) -> Void
    typealias CompletionBlock = (MediaData?, MediaDownloadError?) -> Void

    private enum State {
        case idle
        case running
        case committing
        case cancelling
        case finished
    }

    private static let fileCommitLock = NSLock()
    private let originUrl: String
    private let progressBlock: ProgressBlock?
    private let speedBlock: SpeedBlock?
    private var completionBlock: CompletionBlock?
    private let stateLock = NSLock()
    private let speedLock = NSLock()
    private var state: State = .idle
    private var session: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    private var localWorkItem: DispatchWorkItem?
    private var stagingUrl: URL?
    /// 保证调用方不持有 token 时，任务仍能执行到完成回调。
    private var selfRetainer: WGMediaFileDownloadToken?
    /// 当前版本取消时不生成该数据，避免保留下载分片；后续启用续传时可接入 downloadTask(withResumeData:)。
    private(set) var resumeData: Data?
    private var lastSpeedSample: (bytes: Int64, time: DispatchTime)?

    init(url: String, progress: ProgressBlock?, speed: SpeedBlock?, completed: @escaping CompletionBlock) {
        originUrl = url
        progressBlock = progress
        speedBlock = speed
        completionBlock = completed
        super.init()
    }

    func start() {
        stateLock.lock()
        guard state == .idle else {
            stateLock.unlock()
            return
        }
        state = .running
        selfRetainer = self
        stateLock.unlock()

        reportProgress(0)
        resetSpeedMeasurement()
        if originUrl.hasPrefix("file://"), let fileUrl = URL(string: originUrl), FileManager.default.fileExists(atPath: fileUrl.path) {
            startLocalFile(fileUrl)
        } else if FileManager.default.fileExists(atPath: originUrl) {
            startLocalFile(URL(fileURLWithPath: originUrl))
        } else if let url = URL(string: originUrl), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            startRemoteFile(url)
        } else {
            finish(data: nil, error: .invalidUrl(originUrl))
        }
    }

    /// 取消当前任务。成功取消后只回调 `.cancel`，并删除已写入的临时内容。
    @objc func cancel() {
        stateLock.lock()
        guard state == .idle || state == .running else {
            stateLock.unlock()
            return
        }
        state = .cancelling
        let task = downloadTask
        let workItem = localWorkItem
        stateLock.unlock()

        workItem?.cancel()
        if let task = task {
            // 当前不做断点续传，直接取消才能让 URLSession 清理它管理的临时分片。
            task.cancel()
            finish(data: nil, error: .cancel)
        } else if workItem == nil {
            finish(data: nil, error: .cancel)
        }
    }

    private func startRemoteFile(_ url: URL) {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        let task = session.downloadTask(with: url)

        stateLock.lock()
        guard state == .running else {
            stateLock.unlock()
            task.cancel()
            session.invalidateAndCancel()
            finish(data: nil, error: .cancel)
            return
        }
        self.session = session
        downloadTask = task
        stateLock.unlock()
        task.resume()
    }

    private func startLocalFile(_ fileUrl: URL) {
        scheduleLocalWork { [weak self] in
            guard let self = self else { return }
            guard FileManager.default.fileExists(atPath: fileUrl.path) else {
                self.finish(data: nil, error: .fileNotExistOrWrong(fileUrl.path))
                return
            }
            guard let mimeType = Self.mimeType(fileUrl: fileUrl), let type = MediaDownloadedFileType(mimeType: mimeType) else {
                self.finish(data: nil, error: .unsupportedMimeType(Self.mimeType(fileUrl: fileUrl) ?? "unknown"))
                return
            }
            self.copyLocalFile(fileUrl, type: type)
        }
    }

    private func scheduleLocalWork(_ block: @escaping () -> Void) {
        let workItem = DispatchWorkItem(block: block)
        stateLock.lock()
        guard state == .running else {
            stateLock.unlock()
            finish(data: nil, error: .cancel)
            return
        }
        localWorkItem = workItem
        stateLock.unlock()
        DispatchQueue.global(qos: .utility).async(execute: workItem)
    }

    private func writeLocalData(_ data: Data, type: MediaDownloadedFileType) {
        do {
            let stagingUrl = try makeStagingUrl()
            try data.write(to: stagingUrl, options: .atomic)
            if isCancellationRequested {
                finish(data: nil, error: .cancel)
                return
            }
            commit(stagingUrl: stagingUrl, type: type)
        } catch {
            finish(data: nil, error: .fileOperationFailed(error.localizedDescription))
        }
    }

    private func copyLocalFile(_ sourceUrl: URL, type: MediaDownloadedFileType) {
        do {
            let stagingUrl = try makeStagingUrl()
            FileManager.default.createFile(atPath: stagingUrl.path, contents: nil, attributes: nil)
            let input = try FileHandle(forReadingFrom: sourceUrl)
            let output = try FileHandle(forWritingTo: stagingUrl)
            defer {
                input.closeFile()
                output.closeFile()
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: sourceUrl.path)
            let totalBytes = (attributes[.size] as? NSNumber)?.int64Value ?? 0
            var writtenBytes: Int64 = 0
            while true {
                if isCancellationRequested {
                    finish(data: nil, error: .cancel)
                    return
                }
                let data = input.readData(ofLength: 1024 * 1024)
                if data.isEmpty { break }
                output.write(data)
                writtenBytes += Int64(data.count)
                if totalBytes > 0 {
                    reportProgress(Float(writtenBytes) / Float(totalBytes))
                }
                reportSpeed(totalBytesWritten: writtenBytes)
            }
            commit(stagingUrl: stagingUrl, type: type)
        } catch {
            finish(data: nil, error: .fileOperationFailed(error.localizedDescription))
        }
    }

    private func makeStagingUrl() throws -> URL {
        let directory = Self.downloadDirectory.appendingPathComponent(".partial", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let url = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("part")
        stateLock.lock()
        stagingUrl = url
        stateLock.unlock()
        return url
    }

    private func commit(stagingUrl: URL, type: MediaDownloadedFileType) {
        stateLock.lock()
        guard state == .running else {
            stateLock.unlock()
            finish(data: nil, error: .cancel)
            return
        }
        state = .committing
        stateLock.unlock()

        Self.fileCommitLock.lock()
        defer { Self.fileCommitLock.unlock() }
        do {
            try FileManager.default.createDirectory(at: Self.downloadDirectory, withIntermediateDirectories: true, attributes: nil)
            let finalUrl = Self.downloadDirectory.appendingPathComponent(finalFileName(fileExtension: type.fileExtension))
            if FileManager.default.fileExists(atPath: finalUrl.path) {
                try FileManager.default.removeItem(at: finalUrl)
            }
            try FileManager.default.moveItem(at: stagingUrl, to: finalUrl)
            reportProgress(1)
            finish(data: type.mediaData(path: finalUrl.path, originUrl: originUrl), error: nil)
        } catch {
            finish(data: nil, error: .fileOperationFailed(error.localizedDescription))
        }
    }

    private func finalFileName(fileExtension: String) -> String {
        let urlName = URL(string: originUrl)?.lastPathComponent.removingPercentEncoding
        var name = urlName.flatMap { $0.isEmpty ? nil : $0 } ?? "download"
        name = (name as NSString).deletingPathExtension
        name = name.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
        if name.isEmpty { name = "download" }
        return (name as NSString).appendingPathExtension(fileExtension) ?? "download.\(fileExtension)"
    }

    private var isCancellationRequested: Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return state == .cancelling || state == .finished
    }

    private func reportProgress(_ progress: Float) {
        guard let progressBlock = progressBlock else { return }
        let value = max(0, min(progress, 1))
        DispatchQueue.main.async { progressBlock(value) }
    }

    private func resetSpeedMeasurement() {
        speedLock.lock()
        lastSpeedSample = (0, .now())
        speedLock.unlock()
    }

    /// Reports an averaged transfer rate at most four times per second.
    private func reportSpeed(totalBytesWritten: Int64) {
        guard let speedBlock = speedBlock else { return }

        let now = DispatchTime.now()
        speedLock.lock()
        guard let lastSample = lastSpeedSample else {
            lastSpeedSample = (totalBytesWritten, now)
            speedLock.unlock()
            return
        }

        let elapsedNanoseconds = now.uptimeNanoseconds - lastSample.time.uptimeNanoseconds
        guard elapsedNanoseconds >= 250_000_000 else {
            speedLock.unlock()
            return
        }

        let transferredBytes = max(0, totalBytesWritten - lastSample.bytes)
        let bytesPerSecond = Int64(Double(transferredBytes) * 1_000_000_000 / Double(elapsedNanoseconds))
        lastSpeedSample = (totalBytesWritten, now)
        speedLock.unlock()

        DispatchQueue.main.async { speedBlock(bytesPerSecond) }
    }

    private func finish(data: MediaData?, error: MediaDownloadError?) {
        stateLock.lock()
        guard state != .finished else {
            stateLock.unlock()
            return
        }
        let cancelled = state == .cancelling
        state = .finished
        let completion = completionBlock
        completionBlock = nil
        let session = self.session
        self.session = nil
        downloadTask = nil
        localWorkItem = nil
        selfRetainer = nil
        let stagingUrl = self.stagingUrl
        self.stagingUrl = nil
        stateLock.unlock()

        if error != nil || cancelled, let stagingUrl = stagingUrl {
            try? FileManager.default.removeItem(at: stagingUrl)
        }
        session?.finishTasksAndInvalidate()
        let resultError: MediaDownloadError? = cancelled ? .cancel : error
        DispatchQueue.main.async {
            completion?(resultError == nil ? data : nil, resultError)
        }
    }

    private static let downloadDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("download", isDirectory: true)

    private static func mimeType(fileUrl: URL) -> String? {
        if let resourceValues = try? fileUrl.resourceValues(forKeys: [.typeIdentifierKey]),
           let type = resourceValues.typeIdentifier,
           let mimeType = UTTypeCopyPreferredTagWithClass(type as CFString, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        let ext = fileUrl.pathExtension.lowercased()
        guard !ext.isEmpty,
              let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue(),
              let mimeType = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)?.takeRetainedValue() else {
            return nil
        }
        return mimeType as String
    }

    private static func imageMimeType(data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source),
              let mimeType = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)?.takeRetainedValue() else {
            return nil
        }
        return mimeType as String
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            reportProgress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        }
        reportSpeed(totalBytesWritten: totalBytesWritten)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if isCancellationRequested {
            finish(data: nil, error: .cancel)
            return
        }
        if let response = downloadTask.response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
            finish(data: nil, error: .httpStatus(response.statusCode))
            return
        }
        let mimeType = downloadTask.response?.mimeType ?? ""
        guard let type = MediaDownloadedFileType(mimeType: mimeType) else {
            finish(data: nil, error: .unsupportedMimeType(mimeType.isEmpty ? "unknown" : mimeType))
            return
        }
        do {
            let stagingUrl = try makeStagingUrl()
            try FileManager.default.moveItem(at: location, to: stagingUrl)
            commit(stagingUrl: stagingUrl, type: type)
        } catch {
            finish(data: nil, error: .fileOperationFailed(error.localizedDescription))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        guard let error = error else { return }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            finish(data: nil, error: .cancel)
        } else {
            finish(data: nil, error: .other(error.localizedDescription))
        }
    }
}

/// 下载行为的可选配置
struct DownloadConfig {
    /// LivePhoto 是否仅用于显示（不需要合成最终 LivePhoto）
    /// - false（默认）：仅下载，不返回 UIImage，仅用于后续保存等场景
    /// - true：会同时下载并返回 UIImage 与本地沙盒 URL，用于直接展示
    var onlyShowLiveImage = false
    
    /// needHDDownload 是否高清下载，下载图片。livephoto 和 视频， 移除url里面的cmp_
    /// - false：不高清下载
    /// - true：（默认）高清下载
    var needHDDownload = true // 是否高清下载
}

/// 单条媒体下载任务（基于 NSOperation 实现，可加入 OperationQueue 并发执行）
/// - 重要：当前仅用于笔记下载场景，不用于商品下载
/// - 支持图片、视频（含封面）、LivePhoto 三种类型
class MediaDownQueue: Operation {
    /// 任务在批量下载中的下标，用于排序与日志定位
    var index = 0
    /// 待下载的媒体资源描述
    let source: MediaSource
    /// 下载配置（如 LivePhoto 是否仅用于显示）
    var config: DownloadConfig?
    /// 单个任务完成回调（成功返回 MediaData，失败返回 MediaDownloadError）
    let finish: (_ data: MediaData?, _ err: MediaDownloadError?) -> Void
    /// 媒体处理钩子：可在下载完成后对图片/视频做二次处理（如水印、合成 LivePhoto），与下载逻辑完全解耦
    var mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)?
    /// 持有的 SDWebImage 下载请求，便于取消
    var task:Kingfisher.DownloadTask?
    
    var isHDDownload: Bool {
        if let config = config {
            return config.needHDDownload
        }
        return true
    }
    
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
    

    /// 初始化一个媒体下载任务
    /// - Parameters:
    ///   - source: 媒体资源描述
    ///   - index: 在批量下载中的下标
    ///   - config: 可选的下载配置
    ///   - mediaHandler: 下载完成后对媒体做二次处理的钩子
    ///   - completed: 完成回调（成功/失败）
    init(source: MediaSource, index: Int, config: DownloadConfig? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping (_ data: MediaData?, _ err: MediaDownloadError?) -> Void) {
        self.source = source
        self.index = index
        self.config = config
        self.finish = completed
        self.mediaHandler = mediaHandler
        // 调用父类Operation初始化
        super.init()
    }
    
    /// Operation 启动入口：根据 source 类型分发到对应的下载流程
    /// - 图片：单次下载
    /// - 视频：并行下载视频与封面，全部完成后回调
    /// - LivePhoto：并行下载图片与视频（onlyShowLiveImage 为 true 时跳过视频）
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        switch source {
        case .img(var url):
            var isHd = false
            if isHDDownload, url.contains("cmp_") {
                url = url.replacingOccurrences(of: "cmp_", with: "")
                isHd = true
            }
            download(imgUrl: url, isHD: isHd) { [weak self] media, err in
                if let mediaHandler = self?.mediaHandler, let media = media {
                    mediaHandler(media) { media in
                        self?.setFinish(data: media, err: err)
                    }
                } else {
                    self?.setFinish(data: media, err: err)
                }
            }
        case .video(var url, var cover):
            if isHDDownload {
                url = url.replacingOccurrences(of: "cmp_", with: "")
                cover = cover?.replacingOccurrences(of: "cmp_", with: "")
            }
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
        case .livePhoto(var imgUrl, var videoUrl):
            var isHd = false
            if isHDDownload, imgUrl.contains("cmp_") {
                imgUrl = imgUrl.replacingOccurrences(of: "cmp_", with: "")
                videoUrl = videoUrl.replacingOccurrences(of: "cmp_", with: "")
                isHd = true
            }
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
            download(imgUrl: imgUrl, isHD: isHd) { data, err in
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
    
    /// 下载单张图片（含 GIF）
    /// - 支持三种来源：
    ///   1. `/private/var/mobile` 开头：直接读取本地文件
    ///   2. `file://` / `http://local` 开头：通过本地相册资源 ID 取数据，必要时回落到对应网络 URL
    ///   3. 其他 http(s) URL：通过 SDWebImage 下载，并按需写入临时目录用于后续 LivePhoto/GIF/高清图保存
    /// - Parameters:
    ///   - imgUrl: 图片 URL（可能是网络/本地）
    ///   - isHD: 是否高清下载， 高清下载需要保存到本地
    ///   - completed: 完成回调
    func download(imgUrl: String, isHD: Bool = false, completed: @escaping ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)) {
        var url = imgUrl
        print("开始执行ImageDownQueue 第\(index)个，时间\(Date().timeIntervalSince1970)")
        
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

    /// 标记任务结束并触发完成回调
    /// - 若任务已被取消，则统一回调 `.cancel` 错误
    func setFinish(data: MediaData?, err: MediaDownloadError?) {
        if isCancelled {
           return
       }
       finish(data, err)
       isFinished = true
    }
    
    /// 取消任务
    /// - 若任务正在执行：取消底层下载请求并立即回调 `.cancel`
    /// - 若任务尚未执行：仅置标记，由 `start()` 跳过
    override func cancel() {
        if isFinished {
            return
        }
        isCancelled = true
        task?.cancel()
        task = nil
        finish(nil, .cancel)
        isFinished = true
    }
    
    deinit {
        print("MediaDownQueue已经回收")
    }
}

/// 媒体批量下载器
/// - 接收一组 `MediaSource`，并发下载并按原顺序回调
/// - 内部根据可用内存动态调整最大并发数
/// - 通过 KVO 监听 `operationCount` 判断整体完成
class MediaDownloader: NSObject {
    /// 用于监听内部 OperationQueue 的 operationCount 变化
    var observation: NSKeyValueObservation?
    
    /// 在临时目录下创建用于存放高清/LivePhoto/GIF 中间文件的缓存目录
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

    /// 统一下载图片、视频、PDF 与 ZIP，并依据响应 MIME 类型生成对应的 `MediaData`。
    /// - Returns: 可用于取消下载的任务 token。即使调用方不持有 token，任务也会执行到完成回调。
    @discardableResult
    func downloadFile(url: String, progress: ((_ pro: Float) -> Void)? = nil, speed: ((_ bytesPerSecond: Int64) -> Void)? = nil, completed: @escaping ((_ data: MediaData?, _ err: MediaDownloadError?) -> Void)) -> WGMediaFileDownloadToken {
        let token = WGMediaFileDownloadToken(url: url, progress: progress, speed: speed, completed: completed)
        token.start()
        return token
    }
    
    /// 批量下载混合类型的媒体资源（图片/视频/LivePhoto）
    /// - 任一 URL 不合法将立即整体失败
    /// - 出现"请求超时"会取消整个队列；其他错误仅累计失败计数
    /// - Parameters:
    ///   - sources: 待下载的媒体资源数组
    ///   - config: 下载配置
    ///   - progress: 进度回调（已完成的数量）
    ///   - mediaHandler: 媒体二次处理钩子
    ///   - completed: 整体完成回调（顺序与 sources 一致）
    /// - Returns: 内部使用的 OperationQueue（可由调用方持有以用于取消）
    func download(sources: [MediaSource], config: DownloadConfig? = nil, progress: ((_ count: Int) -> Void)? = nil, mediaHandler: ((_ media: MediaData, _ completion: @escaping (MediaData) -> Void) -> Void)? = nil, completed: @escaping ((_ img: [MediaData]?, _ err: MediaDownloadError?) -> Void)) -> OperationQueue? {
        // 调用start执行队列的时候, 直接清空掉单例中的数组内容, 确保每次只操作一组
        var downloadFailCount = 0
        
        if let invalidUrl = sources.first(where: { !$0.isValid }) {
            completed(nil, .invalidUrl("存在无效的URL: \(invalidUrl)"))
            return nil
        }
        createMediaHDCache()
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = UIDevice.availableMemory < 2000 ? 2 : 4
        var isCancel = false // 是否取消
        var isOverTime = false // 是否超时
        var error: MediaDownloadError?
        var arrMedia = [MediaData](repeating: .image(img: nil, path: nil, originUrl: ""), count: sources.count)
        let t1 = Date().timeIntervalSince1970
        for item in sources.enumerated() {
            let q = MediaDownQueue(source: item.element, index: item.offset, config: config, mediaHandler: mediaHandler) { data, err in
                if let err = err {
                    if err.localizedDescription == "Request explicitly cancelled." || err == .cancel {
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
    
    /// 批量下载图片资源（仅图片场景），保证回调顺序与入参一致
    /// - 不合法的 URL 会被跳过（对应位置返回 nil），不会导致整体失败
    /// - 出现"请求超时"会取消整个队列
    /// - Parameters:
    ///   - imgs: 图片 URL 数组
    ///   - config: 下载配置
    ///   - progress: 进度回调
    ///   - mediaHandler: 媒体二次处理钩子
    ///   - completed: 完成回调（数组长度与 imgs 一致，对应位置可能为 nil）
    /// - Returns: 内部使用的 OperationQueue
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
        // 这里不用weak self，是为了保持在内存里，如果用了weak self，MediaDownloader 很快就回收导致无法执行observe 的代码，在里面手动管理内存
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
        print("MediaDownloader已经回收")
    }
}

/// Objective-C 调用统一文件下载的轻量包装层。
/// 完成回调中成功返回本地 path，失败返回 error message。
@objc(WGMediaFileDownloader)
@objcMembers
final class WGMediaFileDownloader: NSObject {
    static let shared = WGMediaFileDownloader()

    private override init() {
        super.init()
    }

    @discardableResult
    @objc(downloadWithURL:progress:completion:)
    func download(url: String, progress: ((_ pro: Float) -> Void)?, completed: @escaping ((_ path: String?, _ errorMessage: String?) -> Void)) -> WGMediaFileDownloadToken {
        return MediaDownloader().downloadFile(url: url, progress: progress) { data, error in
            completed(data?.filePath, error?.localizedDescription)
        }
    }
}
