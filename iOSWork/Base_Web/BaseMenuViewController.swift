//
//  BaseMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation
import SwiftyBeaver
class BaseMenuViewController:BaseViewController{
    var arrData = ["多线程","内存","渲染","通知","扫码","分享","城市选择","二进制合并","二进制插桩","异常处理","购物平台搬家"]
    var tbMenu = UITableView()
    var isHooked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "基本&WEB"
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "WebView", style: .plain, target: self, action: #selector(toWebView))
        
        let lblFps = FPSLable()
        UIApplication.shared.keyWindow?.addSubview(lblFps)
        if UIDevice.isNotch {
            lblFps.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-15)
            }
        } else {
            lblFps.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(10)
            }
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "日志分享", style: .plain, target: self, action: #selector(shareLog))
        
    }
    
    @objc func toWebView(){
        let vc = WebViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func shareLog(){
        let log = SwiftyBeaver.self
        log.info("用户设备信息:\n 设备名称:\(UIDevice.current.name)\n 系统名称:\(UIDevice.current.systemName)\n 系统版本:\(UIDevice.current.systemVersion)\n 设备型号:\(UIDevice.modelName)\n")
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("logs")
        if let files = try? FileManager.default.contentsOfDirectory(atPath: path.path){
            let paths =  files.sorted().reversed().prefix(5).map { p in
                return path.appendingPathComponent(p)
            }
            
            let items = paths as [Any]
            var activityVC : UIActivityViewController! = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
            activityVC.excludedActivityTypes = [.print,.copyToPasteboard,.assignToContact,.saveToCameraRoll]
            navigationController?.present(activityVC, animated: true)
            activityVC.completionWithItemsHandler = {( activityType,  completed,  returnedItems,  activityError) in
                activityVC = nil
            }
            
        }
       
        
    }
}

extension BaseMenuViewController:UITableViewDelegate,UITableViewDataSource{
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
            let vc = ThreadViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = MemoryViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = OffSreenRenderViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = NotifcationViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = ScanCodeViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = ShareViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = CityChooseViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 7:
            let vc = PatchViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 8:
            let vc = RerangeBinaryViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 9:
            let vc = TriggerErrorViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
       
        default:
            break
        }
    }
    

}
