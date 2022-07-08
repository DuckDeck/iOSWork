//
//  PasteboardManage.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/7.
//

import Foundation

struct PastInfo:Codable{
    var strings = [String]()
    var currentStr = ""
    var changeCount = 0
    static var PastStrings = Store(name: "PastStrings", defaultValue: PastInfo())
    
    static var Strings:[String]{
        get{return PastStrings.Value.strings}
        set{var tmp = PastStrings.Value;tmp.strings = newValue;PastInfo.PastStrings.Value = tmp}
    }
    
    static func insert(str:String){
        var tmp = PastInfo.Strings
        if tmp.count >= 50{
            tmp.removeLast()
        }
        if tmp.contains(str){
            tmp.removeWith { item in
                return item == str
            }
        }
        tmp.insert(str, at: 0)
        PastInfo.Strings = tmp
    }
    
    static var ChangeCount:Int{
        get{return PastStrings.Value.changeCount}
        set{var tmp = PastStrings.Value;tmp.changeCount = newValue;PastInfo.PastStrings.Value = tmp}
    }
    
    static var CurrentStr:String{
        get{return PastStrings.Value.currentStr}
        set{var tmp = PastStrings.Value;tmp.currentStr = newValue;PastInfo.PastStrings.Value = tmp}
    }
}


class PastboardManage{
    //从键盘自身复制的文字需要过虑
    static var pastStringFromKeyboard = Set<String>()
    static func addKeyboardPastString(str:String){
        if pastStringFromKeyboard.count >= 50{
            pastStringFromKeyboard.removeFirst()
        }
        pastStringFromKeyboard.insert(str)
    }
    
    
    var timer:Timer?
    var pastChangeBlock:((_ str:String,_ words:[RecognizeType])->Void)?
    init(pastChange: @escaping ((_ str:String,_ words:[RecognizeType])->Void)) {
        self.pastChangeBlock = pastChange
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkPast), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func checkPast(){
        let changeCount = PastInfo.ChangeCount
        if UIPasteboard.general.hasStrings && UIPasteboard.general.changeCount != changeCount {
            let (str, words) = readpasteBoard()
            if !str.isEmpty{
                pastChangeBlock?(str,words)
            }
               
            
        }
        
    }
    
    func readpasteBoard() ->(String, [RecognizeType]) {
        let p = UIPasteboard.general
        let pastStr = p.string ?? ""
        if  !pastStr.isEmpty && !PastboardManage.pastStringFromKeyboard.contains(pastStr){ //微信SDK当使用小程序分享时，会粘贴一个小程序的链接，在这里过滤
            let str = p.string!.trimmingCharacters(in: .whitespaces)
//            let words = KBRecognizeServer.recognize(str)
            PastInfo.CurrentStr = p.string!
            PastInfo.ChangeCount = UIPasteboard.general.changeCount
            PastInfo.insert(str: p.string!)
            return (str, [])
        }
        PastInfo.ChangeCount = UIPasteboard.general.changeCount
        return ("", [])
    }
    
    func clear(){
        timer?.invalidate()
        timer = nil
        pastChangeBlock = nil
    }
}

enum RecognizeType{
    case phone(String)
    case wechat(String)
}
