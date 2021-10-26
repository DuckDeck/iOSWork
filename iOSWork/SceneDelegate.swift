//
//  SceneDelegate.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let sc = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: sc)
        let tabbarCtl = UITabBarController()
        let baseVC = BaseMenuViewController()
        baseVC.tabBarItem.image = UIImage(named: "apple")?.withRenderingMode(.alwaysOriginal)
        baseVC.tabBarItem.title = "基本&Web"
        let nav1 = UINavigationController(rootViewController: baseVC)
        
        let uiVC = UIMenuViewController()
        uiVC.tabBarItem.image = UIImage(named: "pineapple")
        uiVC.tabBarItem.title = "UI&布局"
        let nav2 = UINavigationController(rootViewController: uiVC)
        
        let dataVC = DataMenuViewController()
        dataVC.tabBarItem.image = UIImage(named: "watermelon")
        dataVC.tabBarItem.title = "数据&网络"
        let nav3 = UINavigationController(rootViewController: dataVC)
        
        let mediaVC = MediaMenuViewController()
        mediaVC.tabBarItem.image = UIImage(named: "watermelon")
        mediaVC.tabBarItem.title = "多媒体&硬件"
        let nav4 = UINavigationController(rootViewController: mediaVC)
        
        let projectVC = ProjectMenuViewController()
        projectVC.tabBarItem.image = UIImage(named: "strawberry")
        projectVC.tabBarItem.title = "独立项目"

        let nav5 = UINavigationController(rootViewController: projectVC)
        tabbarCtl.viewControllers = [nav1,nav2,nav3,nav4,nav5]
        
        tabbarCtl.tabBar.barTintColor = UIColor.white
        window?.rootViewController = tabbarCtl
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
