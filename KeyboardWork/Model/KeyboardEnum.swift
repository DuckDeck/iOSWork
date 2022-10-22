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

