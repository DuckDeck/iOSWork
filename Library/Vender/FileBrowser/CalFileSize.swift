//
//  File.swift
//  Library
//
//  Created by Stan Hu on 2024/6/9.
//

import Foundation

class FileCalManager{
    static var caledDirSize = NSCache<NSString, NSString>() //已经经过计算的目录放在这里，不需要重复计算
    static var calSizeQuene = FileCalQueue(qualityOfService: .utility,maxConcurrentOperationCount: 1,underlyingQueue: nil,name: nil,startSuspended: false)
    
}

class FileCalQueue: OperationQueue {
    var tasks = Set<String>()
    override func addOperation(_ op: Operation) {
        if let name = op.name {
            if !tasks.contains(name) {
                tasks.insert(name)
                super.addOperation(op)
            }
        } else {
            super.addOperation(op)
        }
    }

    func clearTask() {
        tasks.removeAll()
        cancelAllOperations()
    }

    func removeTask(id: String) {
        tasks.remove(id) // 任务成功，移除该任务
    }

    convenience init(qualityOfService: QualityOfService = .default,
                     maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount,
                     underlyingQueue: DispatchQueue? = nil,
                     name: String? = nil,
                     startSuspended: Bool = false) {
        self.init()
        self.qualityOfService = qualityOfService
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.underlyingQueue = underlyingQueue
        self.name = name
        isSuspended = startSuspended
    }

}



class CalFileSizeTask: Operation {
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

    override init() {
        super.init()
    }
    
    var path:URL!
    var completedBlock:((_ fileSize:String,_ err:NSError?)->Void)?

    convenience init(filePah:URL,completed:@escaping ((_ fileSize:String,_ err:NSError?)->Void)) {
        self.init()
        self.path = filePah
        self.completedBlock = completed
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        if let fileSize = FileCalManager.caledDirSize.object(forKey: path.path as NSString){
            completed(fileSize: fileSize as String,err: nil)
            isFinished = true
            return
        }
        
        if let enu = FileManager.default.enumerator(at: path, includingPropertiesForKeys: [.fileSizeKey,.totalFileSizeKey,.isDirectoryKey]){
            var totalSize : Float = 0
            while let subPath = enu.nextObject(),let strPath = subPath as? URL {
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: strPath.path, isDirectory: &isDir)
                if let attr = try? FileManager.default.attributesOfItem(atPath: strPath.path),!isDir.boolValue, let size = attr[FileAttributeKey.size] as? Float{
                    totalSize += size
                    var tmp = ""
                    if size < 1024{
                        tmp = "\(size.format(bitCount: 2, isRounding: false))b"
                    } else if size < 1048576 {
                        tmp = "\((size / 1024.0).format(bitCount: 2, isRounding: false))Kb"
                    } else {
                        tmp = "\((size / 1024.0 / 1024.0).format(bitCount: 2, isRounding: false))Mb"
                    }
                    FileCalManager.caledDirSize.setObject(tmp as NSString, forKey: strPath.path as NSString)
                    print("目录\(strPath.path)获取到的大小为\(tmp)")
                }
                
            }
            var resSize = ""
            if totalSize < 1024{
                resSize = "\(totalSize.format(bitCount: 2, isRounding: false))b"
            }else if totalSize < 1048576 {
                resSize = "\((totalSize / 1024.0).format(bitCount: 2, isRounding: false))Kb"
            } else {
                resSize = "\((totalSize / 1024.0 / 1024.0).format(bitCount: 2, isRounding: false))Mb"
            }
            FileCalManager.caledDirSize.setObject(resSize as NSString, forKey: path.path as NSString)
            completed(fileSize: resSize, err: nil)
            isFinished = true
        } else {
            completed(fileSize: "",err: NSError(domain: "get file enumerator fail", code: -1))
            isFinished = true
        }
    }
    
    func completed(fileSize:String,err:NSError?){
        DispatchQueue.main.async {
            self.completedBlock?(fileSize, err)
        }
    }
   

    override func cancel() {
        completed(fileSize: "",err: NSError(domain: "cancel Cal", code: -1))
        if isExecuting {
            isFinished = true
        } else {
            isCancelled = true
        }
    }


   
}
