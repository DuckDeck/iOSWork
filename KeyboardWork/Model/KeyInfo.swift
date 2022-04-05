//
//  KeyInfo.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

struct KeyInfo{
    var id:UInt8 = 0
    var tip = ""
    var text = ""
    var image = ""
    var number = ""
    var fillColor = UIColor.clear
    var pressColor = UIColor.clear
    var textColor = UIColor.clear
    var isEnable = true
    var keyType = KeyType.normal(.chinese)
    var position = CGRect.zero
    //用于输入法引擎
    var engineCode : String{
        switch keyType {
        case .normal(let keyInputType):
            switch keyInputType {
            case .chinese:
                if self.text.count >= 3{  //这里是用9键时，输入法引擎只接收数字
                    return self.tip
                }
                return self.text
            case .letter:
                return self.text
            default:
                return ""
            }

        case .del:
            return "Backspace"
        case .separate:
            return "Separate"
        default:
            return ""
        }
    }
    var clickType = ClickType.text //点击触发的类型，
    var clickText:String{
        switch clickType {
        case .text:
            return text
        case .tip:
            return tip.isEmpty ? text : tip
        }
    }
    var canBack = false
    var keyLayer:CAShapeLayer?
    var textLayer:CATextLayer?
    var imgLayer:CALayer?
    var textSize:CGFloat?
    var popView:PopKeyView?
    var popViewImage:String?
    var index = 0 //用于9键时点击左侧
}

enum ClickType{
    case text,tip
}

enum KeyType:Equatable{
      case  normal(KeyInputType),//正常
            separate, // 九键分隔符
            shiftParticiple, // 分词
            shift(KeyShiftType),// 上档键
            del, // 退格
            symble,//符号
            switchKeyboard(KeyboardType),//键盘切换
            returnKey(ReturnKeyType),//回车
            space, //空格
            backKeyboard, //返回默认键盘
            reInput //重输
    
    
    var isNormal:Bool{
        switch self {
        case .normal(_):
            return true
        default:
            return false
        }
    }
    
    var isReturnKey:Bool{
        switch self {
        case .returnKey(_):
            return true
        default:
            return false
        }
    }
}

enum KeyShiftType{
    case normal,shift,lock
}

enum KeyInputType:Equatable{
     case chinese,letter,character
}

enum KeyboardType:Int,Codable,CustomDebugStringConvertible{
    case  chinese9 = 0 ,chinese26,english,number,emoji,symbleChiese,symbleEnglish,symbleChieseMore,symbleEnglishMore,handwriting,chinese
    
   
    public var debugDescription: String{
        switch self {
        case .chinese9:
            return "中文九键"
        case .chinese26:
            return "中文26键"
        case .english:
            return "英文26键"
        case .handwriting:
            return "手写"
         case .number:
            return "数字"
        default:
            return "其他"
        }
    }
}

enum ReturnKeyType:Equatable{
    case disable, //不可用
         intermediate, //中间态，指可以选择候选字状态
         usable//可使用态
}

enum KeyboardUseType{
    case normal,search,talk
}

struct OutputInfo{
    var pinyin = ""
    var pinyinPartial : String?
    var texts = [String]()
}
