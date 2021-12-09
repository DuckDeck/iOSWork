//
//  AppDelegate.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/22.
//

import UIKit
import WebKit
import Library
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //这里的代码目前用不了，不知为何
        UncaughtExceptionHandler.installUncaughtExceptionHandler()
        //
        //        NSSetUncaughtExceptionHandler { exp in
        //            print(exp.name)
        //            print(exp.callStackReturnAddresses)
        //            var errors = Store.AppErrors.Value
        //            let err = AppError(name: exp.name.rawValue)
        //            errors.append(err)
        //            Store.AppErrors.Value = errors
        //        }
        
        // Override point for customization after application launch.
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

