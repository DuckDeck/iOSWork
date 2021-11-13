//
//  MediaMenuViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation
class MediaMenuViewController:BaseViewController{
    var arrData = ["图片旋转","多点Touch"]
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
extension MediaMenuViewController:UITableViewDelegate,UITableViewDataSource{
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
            let vc = ImageRotationViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = TouchTestViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}
