//
//  Calculator.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/3/6.
//

import UIKit

public enum OCConstant{
    case integer(Int)
    case float(Float)
    case boolean(Bool)
    case string(String)
}

public enum OCOperation{
    case plus
    case minus
    case mult
    case intDiv
}

public enum OCDirection{
    case left
    case right
}

public enum OCToken{
    case constant(OCConstant)
    case operation(OCOperation)
    case paren(OCDirection)
    case eof
    case witeSpaceAndNewLine
}

extension OCConstant:Equatable{
    public static func == (lhs:OCConstant,rhs:OCConstant)->Bool{
        switch (lhs ,rhs) {
        case let (.integer(left),.integer(right)):
            return left == right
        case let (.float(left),.float(right)):
            return left == right
        case let (.boolean(left),.boolean(right)):
            return left == right
        case let (.string(left),.string(right)):
            return left == right
        default:
            return false
        }
    }
}

extension OCOperation:Equatable{
    public static func == (lhs:OCOperation,rhs:OCOperation)->Bool{
        switch (lhs ,rhs) {
        case (.plus, .plus):
            return true
        case (.minus, .minus):
            return true
        case (.mult, .mult):
            return true
        case (.intDiv, .intDiv):
            return true
        default:
            return false
        }
    }
}


