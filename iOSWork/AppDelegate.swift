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
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //这里的代码目前用不了，不知为何
       // UncaughtExceptionHandler.installUncaughtExceptionHandler()
        //
        
//        let errs = Store.AppErrors.Value
//        for item in errs{
//            print(item.name)
//        }

//        Bugly.start(withAppId: "", config: BuglyConfig())
        
//        let config = BuglyConfig()
//        config.debugMode = true
//        config.applicationGroupIdentifier = "group.ShadowEdge.iOSProject"
//        
//        Bugly.start(withAppId: "ddac261ac5", config: config)
        
        NSSetUncaughtExceptionHandler { exp in
            print(exp.name)
            print(exp.callStackReturnAddresses)
            var errors = Store.AppErrors.Value
            let err = AppError(name: exp.name.rawValue)
            errors.append(err)
            Store.AppErrors.Value = errors
        }
        
        let log = SwiftyBeaver.self
        
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("inputdata").appendingPathComponent("applog.log")
        
        
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
//        log.verbose("not so important")  // prio 1, VERBOSE in silver
//        log.debug("something to debug")  // prio 2, DEBUG in green
//        log.info("a nice information")   // prio 3, INFO in blue
//        log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
//        log.error("ouch, an error did occur!")  // prio 5, ERROR in red


        

        // Override point for customization after application launch.

        
//        let exception = NSException(name: NSExceptionName(rawValue:"arbitrary"), reason:"arbitrary reason", userInfo: nil)
//            exception.raise()
       
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
    
}

