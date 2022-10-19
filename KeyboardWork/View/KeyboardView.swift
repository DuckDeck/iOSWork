//
//  KeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

protocol keyPressDeleaget:NSObjectProtocol{
    func keyPress(key:KeyInfo)
    func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State)
}

class Keyboard:UIView{
    weak var delegate:keyPressDeleaget?
    func keyPress(key:KeyInfo){}
    func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State){}
    func updateReturnKey(key:KeyInfo){}
    var currentKeyBoardType:KeyboardType!
}

class KeyboardView: UIView ,keyPressDeleaget{

    var backspaceRepeatTimer: Timer?
    let backspaceDelay: TimeInterval = 0.1
    
    @objc static var returnValue: String?
    
    @objc var isNumberType: Bool = false
    @objc var isChineseInput : Bool = true
    //cur str
       
    var keyboard:Keyboard?
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = cKeyboardBgColor
       
        keyboard = FullKeyboardView(keyboardType: .english)
        keyboard?.delegate = self
        addSubview(keyboard!)
        keyboard!.snp.makeConstraints { make in
            make.margins.equalTo(0)
        }
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func keyPress(key: KeyInfo) {
        switch key.keyType{
        case .switchKeyboard(let type):
            switchKeyboard(keyboardType: type)
        case .backKeyboard:
            switchKeyboard(keyboardType: KeyboardInfo.KeyboardType)
        case .shift(let shift):
            (keyboard as? FullKeyboardView)?.updateShift(shift: shift)
        case .normal(let type):
            inputText(inputType: type, key: key)
        case .del:
            deleteText()
            keyboard?.updateReturnKey(key: ReturnKey)
            globalHeader?.refreshStatus()
        case .space:
            output(text: " ")
            keyboard?.updateReturnKey(key: ReturnKey)
        case .returnKey:
            if !key.isEnable{
                return
            }
            output(text: "\n")
            keyboard?.updateReturnKey(key: ReturnKey)
            
       
        default:
            break
        }
        
    }
    
    func inputText(inputType:KeyInputType, key:KeyInfo){
        output(text: key.clickText)
        if key.canBack{
            switchKeyboard(keyboardType: KeyboardInfo.KeyboardType)
        }
        if (keyboard as? FullKeyboardView)?.shiftStatus == .shift && keyboard?.currentKeyBoardType == .english && (key.text.first?.isLetter ?? false){
            (keyboard as? FullKeyboardView)?.updateShift(shift: .normal)
        }
        keyboard?.updateReturnKey(key: ReturnKey)
        globalHeader?.refreshStatus()
    }
    
    func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State) {
        if key.keyType == .del{
            switch state{
            case .began:
                backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceDelay, target: self, selector: #selector(keepDelete), userInfo: nil, repeats: true)
            case .cancelled,.ended:
                backspaceRepeatTimer?.invalidate()
                backspaceRepeatTimer = nil
            default:
                break
            }
        }
    }
    
    func switchKeyboard(keyboardType:KeyboardType){
        var newKeyboard : Keyboard?
        switch keyboardType {
        case .chinese26:
            newKeyboard = FullKeyboardView(keyboardType: .chinese26)
        case .chinese9:
            newKeyboard = NineKeyboardView()
        case .number:
            newKeyboard = NumKeyboardView()
        case .emoji:
            newKeyboard = EmojiKeyboard()
        default:
            newKeyboard = FullKeyboardView(keyboardType: keyboardType)
        }
        
        keyboard?.removeFromSuperview()
        keyboard = nil
        keyboard = newKeyboard
        
        if keyboard == nil{
            return
        }
        
        keyboard?.delegate = self
        addSubview(keyboard!)
        keyboard!.snp.makeConstraints { make in
            make.margins.equalTo(0)
        }
        
        if keyboardType == .emoji{
            self.snp.updateConstraints { make in
                make.height.equalTo(272)
            }
        } else {
            self.snp.updateConstraints { make in
                make.height.equalTo(222)
            }
        }
    }
    
    func output(text:String){
        keyboardVC?.insert(text: text)
        keyboardVC?.clientSockek?.write(text.data(using: .utf8), withTimeout: -1, tag: 0)
    }
    
    func deleteText(){
        keyboardVC?.deleteText()
    }
    
    @objc func keepDelete(){
        deleteText()
        keyboard?.updateReturnKey(key: ReturnKey)
        globalHeader?.refreshStatus()
    }
}
