//
//  AppDelegate.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/22.
//

import UIKit
import WebKit
import Library
import SwiftyBeaver
import GrandKit
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //这里的代码目前用不了，不知为何
        // UncaughtExceptionHandler.installUncaughtExceptionHandler()
        //
        ViewChaosStart.awake()
        let errs = Store.AppErrors.Value
        for item in errs{
            print(item.name)
        }
        
        let dnss = BaseBridge().getDnsAddress()
        print(dnss)
            
        IQKeyboardManager.shared.enable = false
     
        
        NSSetUncaughtExceptionHandler { exp in
            print(exp.name)
            print(exp.callStackReturnAddresses)
            var errors = Store.AppErrors.Value
            let err = AppError(name: exp.name.rawValue)
            errors.append(err)
            Store.AppErrors.Value = errors
        }
        registerSignalHandler()
        let log = SwiftyBeaver.self
        
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("logs")
        if !FileManager.default.fileExists(atPath: dir.path){
            try?  FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let url = dir.appendingPathComponent("\(DateTime.now.dateString).log")
        
        
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination(logFileURL: url)  // log to default swiftybeaver.log file
        //        let cloud = SBPlatformDestination(appID: "foo", appSecret: "bar", encryptionKey: "123") // to cloud
        //
        //        // use custom format and set console output to short time, log level & message
        //        console.format = "$DHH:mm:ss$d $L $M"
        //        // or use this for JSON output: console.format = "$J"
        //
        //        // add the destinations to SwiftyBeaver
        
        log.addDestination(console)
        log.addDestination(file)
        //        log.addDestination(cloud)
        //
        //        // Now let’s log!
        log.verbose("not so important")  // prio 1, VERBOSE in silver
        log.debug("something to debug")  // prio 2, DEBUG in green
        //        log.info("a nice information")   // prio 3, INFO in blue
        //        log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        //        log.error("ouch, an error did occur!")  // prio 5, ERROR in red
        
        
        
        
        // Override point for customization after application launch.
        
        
//                let exception = NSException(name: NSExceptionName(rawValue:"arbitrary"), reason:"arbitrary reason", userInfo: nil)
//                    exception.raise()
        
        //        var arr = [1,3,4,5]
        //        arr.insert(9, at: 10)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func hookMethod() {
        hookClassMethod(cls: WKWebView.self, originalSelector: #selector(WKWebView.handlesURLScheme(_:)), swizzleSelector: #selector(WKWebView.gghandlesURLScheme(_:)))
        hookInstanceMethod(cls: WKWebView.self, originalSelector: #selector(WKWebView.load(_:)), swizzleSelector: #selector(WKWebView.ggLoad(_:)))
    }
    
    

    func registerSignalHandler() {
        func SignalExceptionHandler(signal:Int32) -> Void {
            var mstr = String()
            //增加错误信息
            for symbol in Thread.callStackSymbols {
                mstr = mstr.appendingFormat("%@\r\n", symbol)
            }
            let log = SwiftyBeaver.self
            log.error("异常崩溃报告:\(mstr)")
            exit(signal)
        }
        
//        signal(SIGABRT, SignalExceptionHandler)
//        signal(SIGSEGV, SignalExceptionHandler)
//        signal(SIGBUS, SignalExceptionHandler)
//        signal(SIGTRAP, SignalExceptionHandler)
//        signal(SIGILL, SignalExceptionHandler)
        
        signal(SIGABRT, SignalExceptionHandler)     //程序终止命令终止信号
        signal(SIGSEGV, SignalExceptionHandler)     //程序试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
        signal(SIGBUS, SignalExceptionHandler)      //非法地址, 包括内存地址对齐(alignment)出错。比如访问一个四个字长的整数, 但其地址不是4的倍数。它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
        signal(SIGTRAP, SignalExceptionHandler)
        signal(SIGILL, SignalExceptionHandler)  //程序非法指令信号
        signal(SIGQUIT,SignalExceptionHandler)  //和SIGINT类似, 但由QUIT字符(通常是Ctrl-)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。
        signal(SIGHUP,SignalExceptionHandler)   //程序终端终止信号
        signal(SIGINT,SignalExceptionHandler)   //程序键盘终止信号
        signal(SIGFPE,SignalExceptionHandler)   //在发生致命的算术运算错误时发出. 不仅包括浮点运算错误, 还包括溢出及除数为0等其它所有的算术的错误。
        signal(SIGPIPE,SignalExceptionHandler)  //管道破裂。这个信号通常在进程间通信产生，比如采用FIFO(管道)通信的两个进程，读管道没打开或者意外终止就往管道写，写进程会收到SIGPIPE信号。此外用Socket通信的两个进程，写进程在写Socket的时候，读进程已经终止。
   
    }
}

