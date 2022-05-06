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
    var txtTapBlock:(()->Void)?
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
                lbl.textColor = kColorbbbbbb
            }
        }
    }
    var arrLocations = [CGRect]()
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
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func focus(){
        timer =  Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeFire), userInfo: nil, repeats: true)
        timer?.fire()
        cursor.isHidden = false
    }
    
    func unFocus(){
        timer?.invalidate()
        timer = nil
        cursor.isHidden = true
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
        
        layoutIfNeeded()
        
        arrLocations.removeAll()
        for i in 0..<lbl.text!.count{
            arrLocations.append(lbl.boundingRect(forCharacterRange: NSRange(location: i, length: 1))!)
        }
        
    }
    
    
    func deleteText() -> String?{
        txtTapBlock?()
        if isEmpty{
            return nil
        }
        let str = leftText.removeLast()
        lbl.text = leftText + rightText
        if lbl.text!.isEmpty{
            isEmpty = true
            lbl.text = placeHolder
            lbl.textColor = kColorbbbbbb
        } else {
            isEmpty = false
        }
        updateCursor()
        txtChangeBlock?(text)
        
        layoutIfNeeded()
        arrLocations.removeAll()
        for i in 0..<lbl.text!.count{
            arrLocations.append(lbl.boundingRect(forCharacterRange: NSRange(location: i, length: 1))!)
        }
        
        return String(str)
    }
    
    func clear(){
        isEmpty = true
        leftText = ""
        rightText = ""
        lbl.text = placeHolder
        lbl.textColor = kColorbbbbbb
        updateCursor()
        arrLocations.removeAll()
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
    
    func touchPoint(point:CGPoint)  {
        if isEmpty{
            return
        }
        if point.x > lbl.frame.maxX{
            leftText = lbl.text!
            rightText = ""
        }
        for item in arrLocations.enumerated(){
            if point.x > item.element.midX && point.x <= item.element.maxX{
                leftText = lbl.text!.substring(to: item.offset)
                rightText = lbl.text!.substring(from: item.offset + 1)
            } else if  point.x > item.element.minX && point.x <= item.element.midX{
                leftText = lbl.text!.substring(to: item.offset - 1)
                rightText = lbl.text!.substring(from: item.offset)
            }
        }
        updateCursor()
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
        v.isHidden = true
        return v
    }()
    
    lazy var scrollView: InputSrollView = {
        let v = InputSrollView()
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
class InputSrollView:UIScrollView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let p = touches.randomElement()?.location(in: self){
            if let inputText = superview as? InputText{
                inputText.touchPoint(point: p)
            }
        }
    }
}

extension UILabel {
    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {

        guard let attributedText = attributedText else { return nil }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0

        layoutManager.addTextContainer(textContainer)

        var glyphRange = NSRange()

        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)

        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
