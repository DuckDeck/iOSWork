//
//  MediaTool.swift
//  Library
//
//  Created by Stan Hu on 2022/2/23.
//

import Foundation
import Alamofire


enum MediaSource{
    case url(String),
         image(UIImage),
         data(Data)
}


class MediaTool{
    static func downloadToFile(resources: [MediaSource], completed: @escaping ((_ failCount:Int, _ paths: [String])->Void)){
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "MediaDownload")
        let oq = OperationQueue()
        for item in resources{
            
        }
        
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
        let download = AF.download(self.url!) { _, res in
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
        }
        
        
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
