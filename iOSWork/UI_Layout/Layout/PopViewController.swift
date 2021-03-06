//
//  PopViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/4/7.
//

import Foundation
import UIKit
class PopViewController:UIViewController{
    
    let inputText = InputText()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        
        
        let contentView = UIView()
        let lbl = UILabel()
        lbl.text = "我要测试一下这个气泡"
        lbl.textColor = UIColor.white
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        contentView.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-22)
            make.top.bottom.equalTo(0)
            make.height.equalTo(30)
        }
        
        let popView = PopHintView(tranOffset: 0.5, direction: .top, contentView: contentView)
        view.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.top.equalTo(120)
        }
        
        
        
        let btnAddText = UIButton()
        btnAddText.setTitle("添加文字", for: .normal)
        btnAddText.setTitleColor(UIColor.black, for: .normal)
        btnAddText.addTarget(self, action: #selector(addText), for: .touchUpInside)
        view.addSubview(btnAddText)
        btnAddText.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.top.equalTo(160)
        }
        
        let btnRemoveText = UIButton()
        btnRemoveText.setTitleColor(UIColor.black, for: .normal)
        btnRemoveText.setTitle("删除文字", for: .normal)
        btnRemoveText.addTarget(self, action: #selector(removeText), for: .touchUpInside)
        view.addSubview(btnRemoveText)
        btnRemoveText.snp.makeConstraints { make in
            make.left.equalTo(200)
            make.top.equalTo(150)
        }
        
        
        view.addSubview(inputText)
        inputText.placeHolder = "标签名字支持任意字符或emoji"
        inputText.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        inputText.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.top.equalTo(200)
            make.height.equalTo(44)
        }
        
        
        let vTouch = TouchTestView()
//        vTouch.isUserInteractionEnabled = true
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(ges:)))
//        pan.maximumNumberOfTouches = 2
//        pan.minimumNumberOfTouches = 1
//        pan.delaysTouchesBegan = false
//        vTouch.addGestureRecognizer(pan)
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(ges:)))
//        longPress.minimumPressDuration = 0.4
//        vTouch.addGestureRecognizer(longPress)
        
        
        vTouch.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        view.addSubview(vTouch)
        vTouch.snp.makeConstraints { make in
            make.top.equalTo(250)
            make.left.right.equalTo(0)
            make.height.equalTo(300)
        }
        
        let btn = HButtom().title(title: "边缘高亮").addTo(view: view)
        btn.snp.makeConstraints { make in
            make.top.equalTo(600)
            make.left.equalTo(0)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        btn.addTarget(self, action: #selector(hightLight), for: .touchUpInside)
        btn.setBackgroundColor(color: UIColor.lightGray, forState: .normal)
        btn.setBackgroundColor(color: UIColor.darkGray, forState: .highlighted)
        
        
    }
    
    @objc func addText(){
        inputText.insertText(text: "我来测试")
    }
    
    @objc func removeText(){
        _ = inputText.deleteText()
    }

    @objc func hightLight(){
        print("边缘高亮")
    }
    
    @objc func panGes(ges:UIGestureRecognizer){
        print("panGes 触发")
    }
    
    @objc func longPressGes(ges:UIGestureRecognizer){
        print("longPressGes 触发")
    }
}


class TouchTestView:UIView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
    }
}

class HButtom:UIButton{
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        if inside && !self.isHighlighted && event?.type == .touches{
            self.isHighlighted = true
        }
        return inside
    }
}
