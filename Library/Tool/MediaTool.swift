//
//  MediaTool.swift
//  Library
//
//  Created by Stan Hu on 2022/2/23.
//

import Foundation
import Alamofire
class MediaTool{
    static func downloadToFile(resources: [String], completed: @escaping ((_ failCount:Int, _ paths: [String])->Void)){
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
