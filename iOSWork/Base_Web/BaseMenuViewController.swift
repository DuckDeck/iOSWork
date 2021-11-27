//
//  BaseMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation
class BaseMenuViewController:BaseViewController{
    var arrData = ["多线程","内存","渲染","通知","扫码","分享","城市选择","二进制合并","二进制插桩","异常处理"]
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
    }
    
    @objc func toWebView(){
        let vc = WebViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)

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
