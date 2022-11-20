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
