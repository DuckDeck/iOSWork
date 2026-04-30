//
//  File.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation

class ProjectMenuViewController: BaseViewController {
    var arrData = ["五笔查询", "美图", "9点解锁", "连连看", "计算器"]
    var tbMenu = UITableView()
    var isHooked = false
    var guideMaskView: UIView?
    var maskLayer: CAShapeLayer!
    private var initialHoleRect: CGRect = .zero // 记录初始挖空位置
    private var whiteCoverBlock: UIView? // 用于变白的填充块
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "独立项目"

        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { m in
            m.edges.equalTo(0)
        }
    }

    func showAnimate() {
        guideMaskView?.removeFromSuperview()
        whiteCoverBlock?.removeFromSuperview()
            
        guard let window = UIApplication.shared.windows.first else { return }
        let deviceCornerRadius : CGFloat = 8
            
        // 1. 初始位置
        let initialHole = CGRect(x: 16, y: 200, width: window.bounds.width - 32, height: 48)
            
        // 2. 创建白色遮挡块，并设置圆角
        let block = UIView(frame: initialHole)
        block.backgroundColor = .white
        block.alpha = 0
        block.layer.cornerRadius = deviceCornerRadius // 设置圆角
        block.layer.masksToBounds = true
        // 为了让圆角在放大时看起来更像 iPhone 的“连续曲线”，可以设置：
        block.layer.cornerCurve = .continuous
            
        whiteCoverBlock = block
        window.addSubview(block)
            
        // 3. 创建黑色遮罩层
        let maskView = UIView(frame: window.bounds)
        guideMaskView = maskView
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillRule = .evenOdd
        maskView.layer.mask = shapeLayer
        maskLayer = shapeLayer
            
        // 4. 设置初始 Path (改为 roundedRect)
        let fullPath = UIBezierPath(rect: window.bounds)
        let holePath = UIBezierPath(roundedRect: initialHole, cornerRadius: deviceCornerRadius)
        fullPath.append(holePath)
        shapeLayer.path = fullPath.cgPath
            
        window.addSubview(maskView)
            
        UIView.animate(withDuration: 0.2) {
            maskView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            self.whiteCoverBlock?.alpha = 1.0
        } completion: { _ in
            self.startComplexAnimation(cornerRadius: deviceCornerRadius)
        }
    }
    
    func startComplexAnimation(cornerRadius: CGFloat) {
        guard let window = UIApplication.shared.windows.first,
              let maskLayer = maskLayer,
              let whiteBlock = whiteCoverBlock else { return }
        
        let screenBounds = window.bounds
        
        // --- 定义三个位置的 Rect ---
        let r0 = CGRect(x: 16, y: 200, width: screenBounds.width - 32, height: 48)
        let r1 = CGRect(x: 32, y: 64, width: screenBounds.width - 64, height: 120)
        let r2 = CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height)
        
        // --- 定义对应的三个 Path (全部改用 roundedRect) ---
        // 注意：在全屏阶段 (r2)，圆角通常应设为 0 或者保持不变，取决于你是否想让它最终铺满全屏
        let p0 = UIBezierPath(rect: screenBounds)
        p0.append(UIBezierPath(roundedRect: r0, cornerRadius: 16))
        
        let p1 = UIBezierPath(rect: screenBounds)
        p1.append(UIBezierPath(roundedRect: r1, cornerRadius: 16))
        
        let p2 = UIBezierPath(rect: screenBounds)
        p2.append(UIBezierPath(roundedRect: r2, cornerRadius: 44)) // 最终铺满，圆角归零
        
        // 1. 路径关键帧动画
        let pathAnim = CAKeyframeAnimation(keyPath: "path")
        pathAnim.values = [p0.cgPath, p1.cgPath, p2.cgPath]
        pathAnim.keyTimes = [0, 0.25, 1.0]
        pathAnim.duration = 0.4
        pathAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathAnim.isRemovedOnCompletion = false
        pathAnim.fillMode = .forwards
        
        maskLayer.add(pathAnim, forKey: "stepAnimation")
        maskLayer.path = p2.cgPath
        
        // 2. 白色块的同步动画
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                whiteBlock.frame = r1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75) {
                whiteBlock.frame = r2
                whiteBlock.layer.cornerRadius = 0 // 同步圆角归零
            }
        } completion: { _ in
            self.finishAnimation()
        }
    }
    
    func finishAnimation() {
        let vc = TempViewController()
        vc.view.isHidden = true
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.guideMaskView?.removeFromSuperview()
            self.whiteCoverBlock?.removeFromSuperview()
            vc.view.isHidden = false
        }
    }
}

extension ProjectMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = FiveStrokeViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = MitoViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = PointLockViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = LinkGameViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = CalculatorViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
//        case 5:
//            let vc = SnapkitTableViewController()
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc, animated: true)
//        case 6:
//            let vc = AnimationViewController()
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

class TempViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let btn = UIButton()
        btn.setTitle("关闭", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        btn.addClickEvent { _ in
            self.dismiss(animated: true)
        }
    }
}

extension UIScreen {
    var safeCornerRadius: CGFloat {
        // 尝试通过私有键获取
        if let radius = value(forKey: "_displayCornerRadius") as? CGFloat {
            return radius
        }
        // 兜底方案：如果是全面屏 iPhone，通常 44 是个很接近的中间值
        return 44
    }
}
