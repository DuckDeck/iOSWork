//
//  UIMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import UIKit
class UIMenuViewController:BaseViewController{
    var arrData = ["无限滚动的横向Table","样式Table","优化的Table","流式布局","GRID 布局","自己适应高度 Table","动画效果","图片浏览器","View缩放显示","键盘测试","气泡测试","手势Collection","主题","花漾字"]
    var tbMenu = UITableView()
    var isHooked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "多媒体&硬件"

        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "动画", style: .plain, target: self, action: #selector(showAnimate))

    }

    @objc func showAnimate() {

        
        // 1. 基础设置
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(overlayView)

        let arcCenter = CGPoint(x: view.bounds.width, y: view.bounds.height)
        let fullRadius = view.bounds.width

        // 2. 定义一个生成“带洞路径”的辅助函数
        func createMaskPath(radius: CGFloat) -> CGPath {
            let path = UIBezierPath(rect: view.bounds)
            
            let piePath = UIBezierPath()
            piePath.move(to: arcCenter)
            // 即使半径为0，也要保持路径结构一致，以便动画平滑
            piePath.addArc(
                withCenter: arcCenter,
                radius: radius,
                startAngle: .pi,
                endAngle: .pi * 1.5,
                clockwise: true
            )
            piePath.close()
            
            path.append(piePath)
            return path.cgPath
        }

        // 3. 创建 Mask Layer
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer

        // 4. 执行动画
        let startPath = createMaskPath(radius: fullRadius)
        let endPath = createMaskPath(radius: 0)

        // 设置初始状态
        maskLayer.path = startPath

        // 创建路径动画
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = startPath
        pathAnimation.toValue = endPath
        pathAnimation.duration = 0.5
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn) // 走向圆心时带一点加速感

        // 防止动画结束后跳回原状
        maskLayer.path = endPath
        maskLayer.add(pathAnimation, forKey: "pathAnimation")

        // 5. 动画结束后可选：移除整个遮罩层
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 如果你希望彻底清理
           
            self.nextAnimation()
            overlayView.removeFromSuperview()
        }
    }
    
    func nextAnimation() {
        var keyWindow: UIWindow?

        if #available(iOS 13.0, *) {
            // 1. 获取所有已连接的场景
            let connectedScenes = UIApplication.shared.connectedScenes
            
            // 2. 遍历场景，找到处于前台活跃状态的窗口场景
            for scene in connectedScenes {
                if scene.activationState == .foregroundActive,
                   let windowScene = scene as? UIWindowScene {
                    // 3. 从该窗口场景中获取 keyWindow
                    keyWindow = windowScene.windows.first { $0.isKeyWindow }
                    break // 找到第一个活跃的即可
                }
            }
        } else {
            // iOS 13 以下版本，使用旧方式
            keyWindow = UIApplication.shared.keyWindow
        }
        
        let tabVc = keyWindow?.rootViewController as? UITabBarController
        tabVc?.selectedIndex = 4
        let projectVc = (tabVc?.viewControllers?.last as? UINavigationController)?.viewControllers.first as? ProjectMenuViewController
        projectVc?.showAnimate()
    }
}
extension UIMenuViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Shake.keyShake()
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = HorizontalTableViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = StyleTableViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = OptimizeTableViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = FlowLayoutViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = GridViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = SnapkitTableViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = AnimationViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 7:
            let vc = MediaBroswerViewController()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        case 8:
            let vc = ScaleViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 9:
            let vc = TestKeyboardViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 10:
            let vc = PopViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 11:
            let vc = PanCollectionViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 12:
            let vc = ThemeViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 13:
            let vc = FlowerTextViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }

}
