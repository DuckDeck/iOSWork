//
//  File.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import Foundation
class ProjectMenuViewController:BaseViewController{
    var arrData = ["五笔查询","美图","9点解锁","连连看","计算器"]
    var tbMenu = UITableView()
    var isHooked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "独立项目"

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
extension ProjectMenuViewController:UITableViewDelegate,UITableViewDataSource{
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
