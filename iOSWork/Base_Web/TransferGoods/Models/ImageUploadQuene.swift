//
//  ImageUploadQuene.swift
//  WeAblum
//
//  Created by Stan Hu on 2024-04-28.
//  Copyright © 2024 WeAblum. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class ImageUploadQuene: Operation {
    private var _finished = false
    var request: DataRequest?
    var completed: ((_ originUrl: String, _ index: Int, _ url: String?, _ mediaInfoDict: [String: Int], _ error: NSError?)->Void)?
    var isVideo = false
    var url = ""
    var index = 0
    override private(set) var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    private var _isCancelled = false

    override private(set) var isCancelled: Bool {
        get { return _isCancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _isCancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    convenience init(url: String, isVideo: Bool, index: Int, completed: @escaping ((_ originUrl: String, _ index: Int, _ url: String?, _ mediaInfoDict: [String: Int], _ error: NSError?)->Void)) {
        self.init()
        self.url = url
        self.isVideo = isVideo
        self.index = index
        self.completed = completed
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        print("搬家---------开始商品搬家队列")
        upload()
    }
    
    func upload() {
        let stampTime = "\(Date().timeIntervalSince1970 * 1000)"
        let para = ["sourceUrl": url, "type": isVideo ? "2" : "1", "time": stampTime]
        let tmp = "8d7sj9skd92qkkdsos\(stampTime)\(url.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)"
        let md5 = tmp.md5
        let requestUrl = "script/api/v2/qiniu/getUploadInfo" + "?sourceUrl=" + url.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        print("````````````````````````````````上传图片参数````````````````````````````````")
        print(tmp)
        print(md5)
        print(requestUrl)
       
        
    }
    
    override func cancel() {
        if isExecuting {
            request?.cancel()
            isFinished = true
        } else {
            isCancelled = true
        }
    }
}
