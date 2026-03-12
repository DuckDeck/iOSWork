//
//  MediaTool.swift
//  Library
//
//  Created by Stan Hu on 2022/2/23.
//

import Foundation
import Alamofire
import MobileCoreServices
import Photos



enum ImgDownloadResult {
    case success([Data]),
         fail(Int, Error),
         cancel
}

class MediaTool{
    var observation: NSKeyValueObservation?

    func downloadToFile(resources: [String], completed: @escaping ((_ failCount:Int, _ paths: [String])->Void)){
        var failCount = 0
        var paths = [String]()
        let oq = OperationQueue()
        
        for item in resources{
            let q = DownQueue(url: item) { path, err in
                if err != nil{
                    failCount += 1
                } else{
                    paths.append(path)
                }
                if failCount + paths.count == resources.count{
                    completed(failCount,paths)
                }
            }
            oq.addOperation(q)
        }
    }
    
    func downloadToImage(resources: [String], completed: @escaping ((_ result: ImgDownloadResult)->Void)){
        var failCount = 0
        if resources.count == 0 {
            completed(.fail(0, AFError.invalidURL(url: "")))
            return
        }
        var downloadImgs = [Data?].init(repeating: nil, count: resources.count)
        let oq = OperationQueue()
        var error:Error?
        for item in resources.enumerated(){
            
            let q = DownDataQueue(url: item.element) { data, err in
                if let imgDate = data {
                    downloadImgs.append(imgDate)
                } else {
                    failCount += 1
                    error = err
                }
                
            }
            oq.addOperation(q)
        }
        observation = oq.observe(\.operationCount, options: [.new], changeHandler: { _, change in
            if change.newValue! == 0 {
                self.observation = nil
                if let error = error {
                    completed(.fail(failCount, error))
                } else {
                    completed(.success(downloadImgs.compactMap{$0}))
                }
            }
        })
    }
}

class DownQueue: Operation {
    var url:String?
    var finish:((_ path:String,_ err:Swift.Error?)->Void)?
    private var _finished: Bool = false
    override private(set) var isFinished: Bool{
        get {return _finished}
        set{
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    convenience init(url:String,completed:@escaping ((_ path:String, _ err:Swift.Error?)->Void)) {
        self.init()
        self.url = url
        self.finish = completed
    }
    
    override func start() {
        
        let download = AF.download(self.url!, to:  { _, res in
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
            let fileName = res.suggestedFilename ?? ""
            if fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg"){
                return  (documentsUrl.appendingPathComponent(fileName), [.removePreviousFile, .createIntermediateDirectories])
            } else {
                let mimeType = res.mimeType ?? ""
                if mimeType == "image/jpeg"{
                    return (documentsUrl.appendingPathComponent(fileName + ".jpg"), [.removePreviousFile, .createIntermediateDirectories])
                }
                
            }
            return (documentsUrl.appendingPathComponent(res.suggestedFilename!), [.removePreviousFile, .createIntermediateDirectories])
        })
        
        
        download.response(queue: DispatchQueue.main) { resData in
            self.isFinished = true
            switch resData.result{
            case .success( _):
                
                self.finish?(resData.fileURL!.path, nil)
            case .failure(let fail):
                self.finish?("", fail)
            }
        }
    }
}


class DownDataQueue: Operation {
    var url:String?
    var finish:((_ data:Data?,_ err:AFError?)->Void)?
    private var _finished: Bool = false
    override private(set) var isFinished: Bool{
        get {return _finished}
        set{
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    convenience init(url:String,completed:@escaping ((_ data:Data?, _ err:AFError?)->Void)) {
        self.init()
        self.url = url
        self.finish = completed
    }
    
    override func start() {
        
        guard let url = self.url else {
                self.isFinished = true
            self.finish?(nil, .invalidURL(url: ""))
                return
            }
            // 1. 改用 AF.request 发送 GET 请求（替代 download）
            let request = AF.request(url, method: .get)
            
            // 2. 响应数据（获取 Data）
            request.responseData(queue: DispatchQueue.main) { resData in
                
                switch resData.result {
                case .success(let data):
                    // 回调返回 Data（替代原有的 path）
                    self.finish?(data, nil) // 注意：需修改 finish 闭包的参数
                    
                case .failure(let fail):
                    self.finish?(nil, fail)
                }
                self.isFinished = true
            }
    }
}
