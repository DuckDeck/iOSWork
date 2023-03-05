//
//  PasteboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/7.
//

import UIKit
class PasteboardView:KeyboardNav{
    var arrStr = [String]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        title = "剪贴板"
        backgroundColor = UIColor.white
        arrStr = PastInfo.Strings
        addSubview(tb)
        tb.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.right.bottom.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tb: UITableView = {
        let tb = UITableView.init()
        tb.delegate = self
        tb.dataSource = self
        tb.separatorColor = Colors.colorEBEBEB
        tb.tableFooterView = UIView()
        tb.estimatedRowHeight = 32
        tb.showsVerticalScrollIndicator = false
        tb.showsHorizontalScrollIndicator = false
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "PasteCell")
        return tb
    }()
}

extension PasteboardView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasteCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = arrStr[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStr.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keyboardVC?.insert(text: self.arrStr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "拆词") {  (contextualAction, view, boolValue) in
            let splitedWords = self.arrStr[indexPath.row].participleString
            
            
            tableView.setEditing(false, animated: true)
        }
        let action2 = UIContextualAction(style: .normal, title: "删除")  {  (contextualAction, view, boolValue) in
            self.arrStr.remove(at: indexPath.row)
            self.tb.reloadData()
            PastInfo.Strings = self.arrStr
            tableView.setEditing(false, animated: true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [action1,action2])
        return swipeActions
    }
    
}
