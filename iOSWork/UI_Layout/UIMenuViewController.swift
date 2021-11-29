//
//  UIMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import UIKit
class UIMenuViewController:BaseViewController{
    var arrData = ["无限滚动的横向Table","样式Table","优化的Table","流式布局","GRID 布局","自己适应高度 Table","动画效果","图片浏览器"]
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
//            var arrMedia = [MediaModel]()
//            var m = MediaModel()
//            m.type = .Image
//            m.url = "https://pic.netbian.com/uploads/allimg/211127/001033-16379430335612.jpg"
//            arrMedia.append(m)
//             m = MediaModel()
//            m.type = .Image
//            m.url = "https://pic.netbian.com/uploads/allimg/211124/003353-1637685233484f.jpg"
//            arrMedia.append(m)
//             m = MediaModel()
//            m.type = .Image
//            m.url = "https://pic.netbian.com/uploads/allimg/211125/002326-163777100602af.jpg"
//            arrMedia.append(m)
//            let br = ImageBroswerView(media: arrMedia)
//            br.frame = UIScreen.main.bounds
//
//            UIApplication.shared.keyWindow?.addSubview(br)
            
            let vc = ImageBrowserViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.arrImages = ["https://pic.netbian.com/uploads/allimg/211127/001033-16379430335612.jpg","https://pic.netbian.com/uploads/allimg/211124/003353-1637685233484f.jpg","https://pic.netbian.com/uploads/allimg/211125/002326-163777100602af.jpg"]
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }

}
