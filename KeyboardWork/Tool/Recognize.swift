//
//  Recognize.swift
//  KeyboardWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit
let weChatPrefixes: [String] = ["微信","微信号","加微","加v","+v","vx","wx"]

class Recognize: UIView {

    static func recognizeWeChatNumber(_ str: String) -> [String] {
        var recognizeds = recognizePhoneNumber(str)
        guard recognizeds.count == 0 else { return recognizeds }
        recognizeds = recognizeByKeyWord(str)
        if recognizeds.count == 0 {
            recognizeds = recognizeByNormal(str)
        }
        return recognizeds
    }
    
    static func recognize(_ str: String) -> [RecognizeType] {
        var regs = [RecognizeType]()
        var recognizeds = recognizePhoneNumber(str)
        for item in recognizeds{
            regs.append(.phone(item))
        }
        recognizeds = recognizeByKeyWord(str)
        for item in recognizeds{
            regs.append(.wechat(item))
        }
        return regs
    }
    
    static func recognizeByKeyWord(_ str: String) -> [String] {
        var results = [String]()
        for item in weChatPrefixes {
            if str.contains(item.lowercased()) || str.contains(item.uppercased()) {
                let range = str.range(of: item)
                if range != nil {
                    var location = str.distance(from: str.startIndex, to: range!.lowerBound) + item.count
                    let subA = str.substring(from: location, to: location)
                    let subB = str.substring(from: location + 1, to: location + 1)
                    location = isSpecial(subA) ? location + 1 : location
                    let sub = isSpecial(subA) ? subB : subA
                    if sub.count > 0 {
                        if isFirstConformWeChat(sub) {
                            let result = getWechatNumber(str, location: location)
                            if result.count > 0 {
                                results.append(result)
                            }
                        }
                    }
                }
            }
        }
        return results
    }
    
    static func recognizeByNormal(_ str: String) -> [String] {
        let results = [String]()
        // 暂时不处理
        return results
    }
    
    static func recognizePhoneNumber(_ str: String) -> [String] {
        var subStr = ""
        let regex = try! NSRegularExpression(pattern: "(1\\d{10})", options:[])
        let matches = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.count))
        //解析出子串
        if let match = matches.first {
            subStr = String(str[Range(match.range(at: 1), in: str)!])
        }
        return subStr.count > 0 ? [subStr] : [String]()
    }
    
    
    static func getWechatNumber(_ str: String, location: Int) -> String {
        var result = ""
        let recognized = str.substring(from: location, to: location + 20)
        if recognized.count >= 6 {
            for (_, c) in recognized.enumerated() {
                let cStr = String.init(c)
                if c.isNumber || isFirstConformWeChat(cStr) || cStr == "-" {
                    result = "\(result)\(cStr)"
                } else {
                    return result
                }
            }
            return result
        }
        return result
    }
    
    static func isFirstConformWeChat(_ str: String) -> Bool {
        let isEn = str.matches(for: "[a-zA-Z]").count > 0
        let isCharacter = str.isEqual("_")
        return isEn || isCharacter
    }
    
    static func isSpecial(_ str: String) -> Bool {
        let characters = "[`~!@#$%^&*()\\-+=<>?:\"{}|,./;'·~！@#￥%……&*（）——-+={}|《》？：“”【】、；‘'，。、] "
        if str.count > 0 {
            if characters.contains(str) {
                return true
            }
        }
        return false
    }
    

}
