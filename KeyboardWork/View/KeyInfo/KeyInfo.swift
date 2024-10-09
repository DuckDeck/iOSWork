//
//  KeyModel.swift
//  WGKeyBoardExtension
//
//  Created by Stan Hu on 2022/3/12.
//

import Foundation
import UIKit

struct SubKeyInfo{
    var text = ""
    var textColor = UIColor.clear
    var fontSize:CGFloat?
}
struct KeyInfo{
    var id:UInt8 = 0
    var tip = ""                  //单个且显示在按键上的
    var tips : [SymbleInfo]?      //某些符号可以有多个选择的，但不显示在上面
    var defaultSymbleIndex : Int?
    var text = ""
    var subKey:SubKeyInfo?          //有时需要同时绘制第二个
    var image = ""
    var number = ""
    var fillColor = UIColor.clear
    var pressColor : UIColor?
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
    var showTip = true      //显示符号
    
    var keyLayer:CAShapeLayer?
    var textLayer:CATextLayer?
    var imgLayer:CALayer?
    var tipLayer:CATextLayer?
    
    var fontSize:CGFloat?
    var tipSize:CGFloat?
    var positionOffset:CGPoint? //有时侯计算出来的位置不对，需要偏移
    var tipHorOffset:CGFloat?  //tip横向偏移
    var tipVerOffset:CGFloat?  //tip竖向偏移
    var hotArea:CGRect?       //热区
    var hotAreaLayer:CAShapeLayer?
    var index = 0            //用于9键时点击左侧
    
    var location:(Int,Int)?   //所在键盘的位置
    
    static func returnKey(ref:Bool = false)->KeyInfo{ //参考值，true参考alltext，false参考hastext
            var k = KeyInfo()
//            if globalheader?.isHavePinYin ?? false{
//                k.text = "确定"
//                k.fontSize = 20
//                k.textColor = UIColor.white
//                k.fillColor = .green
//                k.isEnable = true
//                k.keyType = .returnKey(.intermediate)
//            } else {
                let type = keyboardVC?.textDocumentProxy.returnText ?? ""
                if type.isEmpty{
                    k.text = "换行"
                    k.fontSize = 20
                    k.textColor = cKeyTextColor
                    k.fillColor = cKeyBgColor2
                    k.isEnable = true
                    k.keyType = .returnKey(.usable)
                } else {
                    k.text = type
                    k.fontSize = 20
                    if type != "发送"{            //只有发送时 需要判断是不是禁用的
                        k.isEnable = true
                    } else{
                        k.isEnable = ref ? !keyboardVC!.allText.isEmpty : keyboardVC!.hasText        //判断存文字有两个标准，通常用hasText来是比较准确的，但是有个问题就是 hasText 不能判断换行符的问题，某种情况下是需要用到换行符号的
                    }
                    if k.isEnable{
                        k.textColor = UIColor.white
                        k.fillColor = .green
                        k.keyType = .returnKey(.usable)
                    } else {
                        k.textColor = Colors.color1E2028.withAlphaComponent(0.3) | UIColor.white.withAlphaComponent(0.2)
                        k.fillColor = cKeyBgColor2
                        k.keyType = .returnKey(.disable)
                    }
                }
//            }
            return k
        }
    
}


struct SymbleInfo{
    enum SymbleAngle{
        case halfAngle,fullAngle
    }
    let text : String
    let angle : SymbleAngle?
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
            reInput, //重输
            newLine,   //换行
            special(String),     //特别 有需求会在按键上加一些特别的东西
            switchInput                //切换其他键盘
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
    
    var isShift:Bool{
        switch self {
        case .shift(_):
            return true
        default:
            return false
        }
    }
    
    var isLowercase : Bool{
        switch self{
        case .shift(.normal):
            return true
        default:
            return false
        }
    }
    
    var isSwitch:Bool{
        switch self {
        case .switchKeyboard(_):
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
    //chinese就是普通的拼音输入
    //letter是9键拼音时用于修改拼音
    //character 就是符号和其他的
}

enum KeyboardType:Int,Codable,CustomDebugStringConvertible,Hashable{
    case  chinese9 = 0,chinese26,english,number,emoji,symbleChiese,symbleEnglish,symbleChieseMore,symbleEnglishMore,handwriting
    
//    var asDwinType:DwimeInputType{
//        switch self {
//        case .chinese9:
//            return .chinese9
//        default:
//            return .chinese26
//        }
//    }
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
        case .emoji:
            return "表情"
        case .symbleChiese:
            return "符号中文"
        case .symbleEnglish:
            return "符号英文"
        case  .symbleChieseMore:
            return "符号中文更多"
        case .symbleEnglishMore:
            return "符号英文更多"
        }
    }
    
    var isSymble:Bool{
        return isChineseSymble || isEnglishSymble
    }
    
    var isEnglish:Bool{
        switch self {
        case .english,.symbleEnglish,.symbleEnglishMore:
            return true
        default:
            return false
        }
    }
    
    var isChinese:Bool{
        switch self {
        case .chinese9,.chinese26,.symbleChiese,.symbleChieseMore:
            return true
        default:
            return false
        }
    }
    
    var isChineseSymble : Bool{
        switch self {
        case .symbleChiese,.symbleChieseMore:
            return true
        default:
            return false
        }
    }
    
    var isEnglishSymble : Bool{
        switch self {
        case .symbleEnglish,.symbleEnglishMore:
            return true
        default:
            return false
        }
    }
}

enum ReturnKeyType:Equatable{
    case disable, //不可用
         intermediate, //中间态，指可以选择候选字状态
         usable//可使用态
}



