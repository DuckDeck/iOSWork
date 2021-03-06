//
//  SwiftUIWorkApp.swift
//  SwiftUIWork
//
//  Created by Stan Hu on 2021/10/22.
//

import SwiftUI
import IQKeyboardManagerSwift
import WebKit

@main
struct SwiftUIWorkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //这里可以使用appDelegate
    @Environment(\.scenePhase) var scenePhase                       //这里可以使用scene周期
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                print("here handle deeplink\(url)")
            }).onChange(of: scenePhase) { (newScenePhase) in
                switch newScenePhase{
                case .active:
                    print("iOSProjectApp is active")
                case .inactive:
                    print("iOSProjectApp is inactive")
                case .background:
                    print("iOSProjectApp is background")
                
                @unknown default:
                    print("Oh - interesting: in app cycle I received an unexpected new value.")
                }
            }
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
      
        return true
    }
    //如果有些库还是用appDelegate来处理的话还是可以在这里处理生命周期, 下面方法不用调用
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidBecomeActive")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationWillResignActive")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidEnterBackground")
    }
    
 
}
