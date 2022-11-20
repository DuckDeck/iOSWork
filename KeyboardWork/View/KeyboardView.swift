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
    var keyboardName = ""
    weak var delegate: keyPressDeleaget?
    var boardStatus = BoardStatus.normal(!keyboardVC!.allText.isEmpty)
    func createBoard() {}
    func keyPress(key: KeyInfo) {}
    func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {}
    func updateStatus(_ status:BoardStatus){}
    var currentKeyBoardType: KeyboardType!
    var keyboardWidth: CGFloat = 0
    
    // 公有属性
    var keys = [[KeyInfo]]()
    var keyWidth: CGFloat = 0
    var keyHeight: CGFloat = 0
    var keyTopMargin: CGFloat = 0
    var keyHorGap: CGFloat = 0 // 水平间隙
    var keyVerGap: CGFloat = 0 // 垂直间隙
}

class KeyboardView: UIView ,keyPressDeleaget{

    var backspaceRepeatTimer: Timer?
    let backspaceDelay: TimeInterval = 0.05
    @objc static var returnValue: String?
    
    @objc var isNumberType: Bool = false
    @objc var isChineseInput: Bool = true
    // cur str
    
    var keyboard: Keyboard?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "keyboard_bg_color")!
        if KeyboardInfo.KeyboardType == .chinese9 {
            keyboard = NineKeyboardView()
        } else {
            keyboard = FullKeyboardView(keyboardType: KeyboardInfo.KeyboardType)
        }
        keyboard?.delegate = self
        addSubview(keyboard!)
        keyboard!.snp.makeConstraints { make in
            make.margins.equalTo(0)
        }
    }
    
    
    
    deinit {
        kbLog.info("键盘回收")
        print("keyboard view deint")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyPress(key: KeyInfo) {
        
        switch key.keyType {
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
            keyboard?.updateStatus(.normal(!keyboardVC!.allText.isEmpty))
            
        case .space:
            output(text: " ")
            keyboard?.updateStatus(.normal(true))
            
        case .separate:
            if key.text == "分词" {
                inputTextCode(code: key.engineCode)
            } else {
                keyboard?.updateStatus(.input)
                
            }
        case .returnKey:
            if !key.isEnable {
                return
            }
            output(text: "\n")
            (keyboard as? NineKeyboardView)?.updateLeftText(texts: nil)
            self.keyboard?.updateStatus(.normal(true))
        
        case .reInput: // 重输
            (keyboard as? NineKeyboardView)?.updateLeftText(texts: nil)
            keyboard?.updateStatus(.normal(!keyboardVC!.allText.isEmpty))
        case .newLine:
            keyboardVC?.insert(text: "\n ") // 换行符后加上空格，这样系统就不会把文字发送出去，然后再调用删除即可
            keyboard?.updateStatus(.normal(true))
            keyboardVC?.deleteText()
           
        default:
            break
        }
    }
    
    func keyLongPress(key: KeyInfo, state: UIGestureRecognizer.State) {
        if key.keyType == .del {
            switch state {
            case .began:
                backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceDelay, target: self, selector: #selector(keepDelete), userInfo: nil, repeats: true)
            case .cancelled, .ended:
                backspaceRepeatTimer?.invalidate()
                backspaceRepeatTimer = nil
            default:
                break
            }
        }
    }
    
  
    
   
    
    func switchKeyboard(keyboardType: KeyboardType) {
        // 处理当上面有候选字
        var newKeyboard: Keyboard?
        switch keyboardType {
        case .chinese9:
            newKeyboard = NineKeyboardView()
        case .number:
            newKeyboard = NumberKeyboardView()
        case .emoji:
            newKeyboard = EmojiKeyboard()
        case .chinese: // 返回中文键盘，具体是什么样的和自己系统设置有关
            if KeyboardInfo.KeyboardType == .chinese9 {
                newKeyboard = NineKeyboardView()
            } else {
                // 有可能选择了英文键盘。那么KeyboardInfo.KeyboardType 就是英文了。这里要换成中文
                newKeyboard = FullKeyboardView(keyboardType: .chinese26)
                KeyboardInfo.KeyboardType = .chinese26
            }
        default:
            newKeyboard = FullKeyboardView(keyboardType: keyboardType)
            
        }
        
        keyboard?.removeFromSuperview()
        keyboard = nil
        keyboard = newKeyboard
        keyboard?.delegate = self
        addSubview(keyboard!)
        keyboard!.snp.makeConstraints { make in
            make.margins.equalTo(0)
        }
    }
    
    func inputText(inputType: KeyInputType, key: KeyInfo) {
        // 只要有输入就移除粘贴板
        switch inputType {
        case .chinese:
            inputTextCode(code: key.engineCode)
        case .letter:
            // 特别处理
            inputTextCode(code: key.engineCode, index: key.index)
        case .character:
            output(text: key.clickText)
            if key.canBack {
                switchKeyboard(keyboardType: KeyboardInfo.KeyboardType)
            }
            if (keyboard as? FullKeyboardView)?.shiftStatus == .shift, key.text.first?.isLetter ?? false {
                (keyboard as? FullKeyboardView)?.updateShift(shift: .normal)
            }
            self.keyboard?.updateStatus(.normal(true))
        }
    }
    
    func inputTextCode(code: String, index: Int? = nil) {
       
    }
    
    func output(text: String) {
        keyboardVC?.insert(text: text)
    }
    
    func deleteText() {
        keyboardVC?.deleteText()
    }
    
    @objc func keepDelete() {
        print("长按删除")
        Shake.keyShake()
        deleteText()
        let newCount = keyboardVC?.allText.count ?? 0
        if newCount == 0 {
            keyboard?.updateStatus(.normal(false))
        }
        
    }
}
