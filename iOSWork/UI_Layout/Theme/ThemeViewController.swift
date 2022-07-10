//
//  ThemeViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/7/10.
//

import Foundation
class ThemeViewController:BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "main_color")
        title = "主题切换"
        let action1 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .unspecified
            self.updateStyle(style: .unspecified)
        }
        action1.title = "跟随系统"
        let action2 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .dark
            self.updateStyle(style: .dark)
        }
        action2.title = "深色模式"
        let action3 = UIAction { a in
            UserDefaults.standard.overridedUserInterfaceStyle = .light
            self.updateStyle(style: .light)
        }
        action3.title = "浅色模式"
        
        let seg = UISegmentedControl(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 50),actions: [action1,action2,action3])
        view.addSubview(seg)
        
        
    }

    func updateStyle(style:UIUserInterfaceStyle){
        UIApplication.shared.override(style)
        UserDefaults.standard.overridedUserInterfaceStyle = style
    }

}

extension UserDefaults{
    var overridedUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: integer(forKey: #function)) ?? .unspecified
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
}
public extension UIApplication {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        // iPad支持多窗口，不支持iPad的话可以删除这段判断
        if #available(iOS 13.0, *), supportsMultipleScenes {
            for connectedScene in connectedScenes {
                if let scene = connectedScene as? UIWindowScene {
                    scene.windows.override(userInterfaceStyle)
                }
            }
        }
        else {
            windows.override(userInterfaceStyle)
        }
    }
}
public extension UIWindow {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        if #available(iOS 13.0, tvOS 13.0, *) {
            overrideUserInterfaceStyle = userInterfaceStyle
        }
    }
}
public extension Array where Element: UIWindow {
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        for window in self {
            window.override(userInterfaceStyle)
        }
    }
}
  
