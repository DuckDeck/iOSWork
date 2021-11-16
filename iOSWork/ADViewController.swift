//
//  ADViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/16.
//

import UIKit
import GrandKit
class AdViewController: UIViewController {
    lazy var timer  = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    var seconds = 5
    lazy var btnCount = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        timeCountDown()
        
        btnCount.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        btnCount.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 120, width: 80, height: 30)
        btnCount.addTarget(self, action: #selector(skipToHome), for: .touchUpInside)
        view.addSubview(btnCount)
        
        
    }
    
    func timeCountDown() {
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler {
            DispatchQueue.main.async { [weak self] in
                if self!.seconds <= 0{
                    self?.terminate()
                }
                self?.btnCount.setTitle("跳过\(self!.seconds)", for: .normal)
                self!.seconds -= 1
            }
        }
        timer.resume()
    }
    
   @objc func skipToHome() {
        terminate()
    }
    
    func terminate() {
        timer.cancel()
        switchRootViewController()
    }
    
    func switchRootViewController() {
        let window = UIApplication.shared.windows.first!
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let old = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = self.tab
            UIView.setAnimationsEnabled(old)
            
        } completion: { (_) in

        }

    }
    
    lazy var tab:UITabBarController = {
        let tabbarCtl = UITabBarController()
        let baseVC = BaseMenuViewController()
        baseVC.tabBarItem.image = UIImage(named: "house_black")?.withRenderingMode(.alwaysOriginal)
        baseVC.tabBarItem.selectedImage = UIImage(named: "house_blue")?.withRenderingMode(.alwaysOriginal)
        baseVC.tabBarItem.title = "基本&Web"
        let nav1 = UINavigationController(rootViewController: baseVC)

        let uiVC = UIMenuViewController()
        uiVC.tabBarItem.image = UIImage(named: "menu_black")?.withRenderingMode(.alwaysOriginal)
        uiVC.tabBarItem.selectedImage = UIImage(named: "menu_blue")?.withRenderingMode(.alwaysOriginal)

        uiVC.tabBarItem.title = "UI&布局"
        let nav2 = UINavigationController(rootViewController: uiVC)

        let dataVC = DataMenuViewController()
        dataVC.tabBarItem.image = UIImage(named: "data_black")?.withRenderingMode(.alwaysOriginal)
        dataVC.tabBarItem.selectedImage = UIImage(named: "data_blue")?.withRenderingMode(.alwaysOriginal)
        dataVC.tabBarItem.title = "数据&网络"
        let nav3 = UINavigationController(rootViewController: dataVC)

        let mediaVC = MediaMenuViewController()
        mediaVC.tabBarItem.image = UIImage(named: "media_black")?.withRenderingMode(.alwaysOriginal)
        mediaVC.tabBarItem.selectedImage = UIImage(named: "media_blue")?.withRenderingMode(.alwaysOriginal)
        mediaVC.tabBarItem.title = "多媒体&硬件"
        let nav4 = UINavigationController(rootViewController: mediaVC)

        let projectVC = ProjectMenuViewController()
        projectVC.tabBarItem.image = UIImage(named: "project_black")?.withRenderingMode(.alwaysOriginal)
        projectVC.tabBarItem.selectedImage = UIImage(named: "project_blue")?.withRenderingMode(.alwaysOriginal)
        projectVC.tabBarItem.title = "独立项目"

        let nav5 = UINavigationController(rootViewController: projectVC)
        tabbarCtl.viewControllers = [nav1,nav2,nav3,nav4,nav5]

        tabbarCtl.tabBar.barTintColor = UIColor.white
        return tabbarCtl
    }()

    
}
