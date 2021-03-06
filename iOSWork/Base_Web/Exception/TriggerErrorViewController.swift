//
//  TriggerErrorViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/18.
//

import UIKit
class TriggerErrorViewController: BaseViewController {
    var arrData = ["越界错误", "内存", "渲染"]
    var tbMenu = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "引发错误"

        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { m in
            m.edges.equalTo(0)
        }
    }
}

extension TriggerErrorViewController: UITableViewDelegate, UITableViewDataSource {
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
            var arr = [1,3,4,5]
            arr.insert(9, at: 10)
        case 1:
            Toast.showToast(msg: "怎么引发sigle错误？")
            
        default:
            break
        }
    }
}
