//
//  HidViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2026/4/13.
//

import Foundation
class HidViewController:UIViewController {
    let hidView = HidView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "键盘", style: .plain, target: self, action: #selector(popKeyboard))
        
        
        view.addSubview(hidView)
        hidView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    @objc func popKeyboard(){
        hidView.becomeFirstResponder()
    }
}

class HidView:UIView, UIKeyInput {
    var lblX: CGFloat = 0
    var lblY: CGFloat = 50
    
    var hasText: Bool {return true}
    
    func insertText(_ text: String) {
        
    }
    
    func deleteBackward() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touchPoint in touches
        {
            let point = touchPoint.location(in: self)
            let color = UIColor.random
            let pointView = UIView()
            pointView.frame = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
            pointView.backgroundColor = color
            pointView.layer.cornerRadius = 5
            addSubview(pointView)
            
            let lbl = UILabel()
            lbl.text = "x:\(point.x), y:\(point.y)"
            lbl.textColor = color
            lbl.font = UIFont.systemFont(ofSize: 10)
            lbl.frame = CGRect(x: lblX, y: lblY, width: 100, height: 12)
            addSubview(lbl)
            lblY += 12
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
