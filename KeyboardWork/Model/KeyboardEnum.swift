//
//  KeyboardEnum.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit

enum RecognizeType{
    case phone(String)
    case wechat(String)
}
enum KeyboardStatus{
    case background, active, inActive
    var rawString:String{
        switch self {
        case .background:
            return "后台"
        case .active:
            return "激活"
        case .inActive:
            return "非激活"
        }
    }
}

enum BoardStatus:Equatable{
    case normal(Bool),       //键盘初始态，这时回车有可用不可用两种状态
         input         //选词状态
}

enum KeyboardHeight {
    case normal , high, big
    var value: CGFloat {
            return self.boardHeight + self.headerHeight + self.rawValue

    }
    
    var  rawValue:CGFloat{
        switch UIDevice.current.deviceDirection{
        case .PhoneHor:
            return 0
        case .PhoneVer:
            switch self {
            case .normal:
                return 0
            case .high:
                return 96
            case .big:
                return 216
            }
        case .PadVer:
            switch self {
            case .normal:
                return 0
            case .high:
                return 154
            case .big:
                return 216
            }
        case .PadHor:
            switch self {
            case .normal:
                return  0
            case .high:
                return 156
            case .big:
                return 216
            }
        }
    }
    
    var headerHeight:CGFloat{   //头高度
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor:
            return 80
        case .PhoneHor:
            return 52
        case .PhoneVer:
            return 66
        }
    }
    
    var boardHeight:CGFloat{        //键盘体高度
        return CGFloat(KeyboardInfo.boardHeight)
    }
    
    var bottomMargin:CGFloat{   //底部margin
        switch UIDevice.current.deviceDirection{
        case .PadVer:
            return 3
        case .PadHor:
            return 4
        case .PhoneHor:
            return 4
        case .PhoneVer:
            return 5
        }
    }
    
    var headerPinyinHeight:CGFloat{         //键盘头上部分高度
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor:
            return 32
        case .PhoneHor:
            return 20
        case .PhoneVer:
            return 28
        }
    }
    
    var headerWordsHeight:CGFloat{          //键盘头下部分高度
        switch UIDevice.current.deviceDirection{
        case .PadVer,.PadHor:
            return 48
        case .PhoneHor:
            return 32
        case .PhoneVer:
            return 38
        }
    }
}
