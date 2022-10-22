//
//  Log.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
import SwiftyBeaver
import GrandKit
let kbLog = KBLog.shared.kbLog
func handle(exception:NSException){
    let reason = exception.reason ?? "未知原因"
    let arr = exception.callStackSymbols
    let dealStr = "\ndate: \(Date())\nname: \(exception.name)\nreason: \(reason)\ncallStackSymbols:\n\(arr.joined(separator: "\n"))"
    kbLog.info("异常崩溃报告:\(dealStr)")
    KBLog.shared.previoursHandler?(exception)
}
struct KBLog{
    static let shared = KBLog()
    let kbLog = SwiftyBeaver.self
    var previoursHandler: NSUncaughtExceptionHandler? = nil
    init() {
        if previoursHandler == nil{
            previoursHandler  = NSGetUncaughtExceptionHandler()
            NSSetUncaughtExceptionHandler(handle)
            registerSignalHandler()
        }
        
        
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("logs")
        if !FileManager.default.fileExists(atPath: dir.path){
           try?  FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let url = dir.appendingPathComponent("\(DateTime.now.dateString).log")
        let console = ConsoleDestination()
        let file = FileDestination(logFileURL: url)
        file.logFileMaxSize = (3 * 1024 * 1024)
        kbLog.addDestination(console)
        kbLog.addDestination(file)
    }
    
    func registerSignalHandler() {
        func SignalExceptionHandler(signal:Int32) -> Void {
            var mstr = String()
            //增加错误信息
            for symbol in Thread.callStackSymbols {
                mstr = mstr.appendingFormat("%@\r\n", symbol)
            }
            KBLog.shared.kbLog.error("异常崩溃报告:\(mstr)")
            exit(signal)
        }
        
        signal(SIGABRT, SignalExceptionHandler)
        signal(SIGSEGV, SignalExceptionHandler)
        signal(SIGBUS, SignalExceptionHandler)
        signal(SIGTRAP, SignalExceptionHandler)
        signal(SIGILL, SignalExceptionHandler)
        
//        signal(SIGABRT, SignalExceptionHandler)     //程序终止命令终止信号
//        signal(SIGSEGV, SignalExceptionHandler)     //程序试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
//        signal(SIGBUS, SignalExceptionHandler)      //非法地址, 包括内存地址对齐(alignment)出错。比如访问一个四个字长的整数, 但其地址不是4的倍数。它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
//        signal(SIGTRAP, SignalExceptionHandler)
//        signal(SIGILL, SignalExceptionHandler)  //程序非法指令信号
//        signal(SIGQUIT,SignalExceptionHandler)  //和SIGINT类似, 但由QUIT字符(通常是Ctrl-)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。
//        signal(SIGHUP,SignalExceptionHandler)   //程序终端终止信号
//        signal(SIGINT,SignalExceptionHandler)   //程序键盘终止信号
//        signal(SIGFPE,SignalExceptionHandler)   //在发生致命的算术运算错误时发出. 不仅包括浮点运算错误, 还包括溢出及除数为0等其它所有的算术的错误。
//        signal(SIGPIPE,SignalExceptionHandler)  //管道破裂。这个信号通常在进程间通信产生，比如采用FIFO(管道)通信的两个进程，读管道没打开或者意外终止就往管道写，写进程会收到SIGPIPE信号。此外用Socket通信的两个进程，写进程在写Socket的时候，读进程已经终止。
   
    }
    
    static func unregisterSignalHandler() {
        signal(SIGINT, SIG_DFL);
        signal(SIGSEGV, SIG_DFL);
        signal(SIGTRAP, SIG_DFL);
        signal(SIGABRT, SIG_DFL);
        signal(SIGILL, SIG_DFL);
    }
    
    func shareLog(vc:UIViewController){
        guard let paths = logPath else {return}
        let items = paths as [Any]
        var activityVC : UIActivityViewController! = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.print,.copyToPasteboard,.assignToContact,.saveToCameraRoll]
        vc.present(activityVC, animated: true)
        activityVC.completionWithItemsHandler = {( activityType,  completed,  returnedItems,  activityError) in
            activityVC = nil
        }
    }
    
    var logPath:[URL]?{
        kbLog.info("用户设备信息:\n 设备名称:\(UIDevice.current.name)\n 系统名称:\(UIDevice.current.systemName)\n 系统版本:\(UIDevice.current.systemVersion)\n 设备型号:\(UIDevice.modelName)\n")
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("logs")
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: path.path) else {return nil}
        return  files.sorted().reversed().prefix(5).map { p in
            return path.appendingPathComponent(p)
        }
    }
    
    func uploadLog() {
        
//        guard let paths = logPath else {return}
        
//        AF.upload(multipartFormData: { da in
//            da.append(paths.last!, withName: "upload-key")
//        }, to:  "http://lovelive.ink:9000/upload/header") { res in
//            print(res)
//        }
        
        
//        HttpClient.get(API_Qiniu_Token).addParams(["act":"logs"]).completion { res in
//            if res.code != 0{
//                return
//            }
//
//            let key =  "\(arc4random())\(item!)"
//            guard let data = try? Data.init(contentsOf:  path.appendingPathComponent(item as! String)) else{return}
//            let token = (res.data! as! String).removingPercentEncoding
//            QiNiuHttpClient.shared.qnUploadData(data as Data, key: key, token: token!) { isSuccess, info, key, resp in
//
//            }
//        }
    }

}
