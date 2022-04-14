//
//  InputText.swift
//  Library
//
//  Created by Stan Hu on 2022/4/11.
//

import Foundation
import UIKit
class InputText:UIView{
    
    var txtChangeBlock:((_ txt:String)->Void)?
    
    var leftOffset : CGFloat = 5{
        didSet{
            lbl.snp.updateConstraints { make in
                make.left.equalTo(leftOffset)
            }
            updateCursor()
        }
    }
    
    var text:String{
        if isEmpty{
            return ""
        }
        return lbl.text ?? ""
    }
    
    var textColor = UIColor.black{
        didSet{
            lbl.textColor = textColor
        }
    }
    var font = UIFont.systemFont(ofSize: UIFont.systemFontSize){
        didSet{
            lbl.font = font
            updateCursor()
        }
    }
    var maxTextCount = 100
    var leftText = ""
    var rightText = ""
    var isEmpty = true
    var placeHolder = ""{
        didSet{
            if isEmpty{
                lbl.text = placeHolder
                lbl.textColor = UIColor.gray
            }
        }
    }
    
    var timer:Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(leftOffset)
            make.right.equalTo(-5)
            make.height.equalTo(self).multipliedBy(0.8)
        }
        
        scrollView.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.centerY.equalTo(scrollView)
            make.left.right.equalTo(0)
            
        }
        
        addSubview(cursor)
        cursor.snp.makeConstraints { make in
            make.left.equalTo(leftOffset)
            make.centerY.equalTo(self)
            make.height.equalTo(lbl).multipliedBy(1.1)
            make.width.equalTo(2)
        }
        
        timer =  Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeFire), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertText(text:String){
        if text.isEmpty{
            return
        }
        leftText += text
        lbl.textColor = textColor
        lbl.text = leftText + rightText
        isEmpty = false
        updateCursor()
        txtChangeBlock?(text)
    }
    
    
    func deleteText() -> String?{
        if isEmpty{
            return nil
        }
        let str = leftText.removeLast()
        lbl.text = leftText + rightText
        if lbl.text!.isEmpty{
            isEmpty = true
            lbl.text = placeHolder
            lbl.textColor = UIColor.gray
        } else {
            isEmpty = false
        }
        updateCursor()
        txtChangeBlock?(text)
        return String(str)
    }
    
    func clear(){
        isEmpty = true
        leftText = ""
        rightText = ""
        lbl.text = placeHolder
        lbl.textColor = UIColor.gray
        updateCursor()
        txtChangeBlock?(text)
    }
    
    func updateCursor(){
        if isEmpty{
            cursor.snp.updateConstraints { make in
                make.left.equalTo(leftOffset)
            }
        } else {
            let width = leftText.boundingRect(with: CGSize(width: 1000, height: 25), font: font)
            cursor.snp.updateConstraints { make in
                make.left.equalTo(width.width + leftOffset)
            }
        }
        
        
    }
    
    @objc func timeFire(){
        cursor.isHidden = !cursor.isHidden
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    lazy var cursor: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.green
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    lazy var lbl: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.font = font
        v.textColor = textColor
        return v
    }()
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

//先不考虑光标移动问题
class InputLabel:UILabel{
    
}
