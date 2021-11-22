//
//  String+Extension.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/10/24.
//

import UIKit
import CommonCrypto
import Kingfisher

//ForwardFilter从最前面开始,出现数字后一直到没有数字为止
//BackwordFilter从最后面开始,出现数字后一直到没有数字为止
//AllFilter获取所的数字
public enum FilterToInt:Int{
    case ForwardFilter = 0,
         BackwordFilter,
         AllFilter
    static func toFilter(type:Int)->Self{
        switch type{
        case 0:return .ForwardFilter
        case 1:return .BackwordFilter
        case 2:return .AllFilter
        default:return AllFilter
        }
    }
}


extension String{
     func bitEllipsis(bitCount:Int) -> String {
        if bitCount <= 0{
            return self
        }
         var num = 0
         var res = ""
        for item in self{
            num += item.isChinese ? 2 : 1
            res.append(item)
            if num >= bitCount{
                return res
            }
        }
        return self
    }
    
    var isChinese:Bool{
        let match: String = "(^[\\u4e00-\\u9fa5]+$)"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: self)
    }
}

extension Character{
    var isChinese:Bool{
        return "\u{4E00}" <= self  && self <= "\u{9FA5}"
    }
}



extension String{
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }


    func insertString(indexs:[Int],str:String) -> String {
        assert(indexs.count > 0, "count must bigger zero")
        assert(indexs.count <= count, "count must small length")
        assert(indexs.first! >= 0, "fist element must bingger or equal zero")
        //assert(indexs.last! < length, "start must bingger zero")
        assert(count > 0,"length must bigger 0")
        var arr =  [String]()
        for c in self{
            arr.append(String(c))
        }
        var j = 0
        for i in indexs{
            if i + j > count{
                break
            }
            arr.insert(str, at: i + j)
            j += str.count
        }
        return arr.joined(separator: "")
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }

    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if size.equalTo(CGSize.zero) {
            
            textSize = self.size(withAttributes: [NSAttributedString.Key.font:font])
        } else {
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let stringRect = self.boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font:font], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }

    public func split(_ separator: String) -> [String] {
        return self.components(separatedBy: separator).filter {
            !$0.trimmed().isEmpty
        }
    }
    
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    var md5:String{
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce(""){$0 + String(format:"%02x",$1)}
    }
    
    var MD5:String{
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce(""){$0 + String(format:"%02X",$1)}
    }
    
    public func hmac(key:String)->String{
        let utf8 = cString(using: .utf8)
        let keyData = key.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), keyData, strlen(keyData!), utf8, strlen(utf8!), &digest)
        return digest.reduce(""){$0 + String(format:"%02X",$1)}
    }
    
    public func filteToInt(filter:FilterToInt)->Int?{
        let enu = self.enumerated()
        var tmp = ""
       
        //用正则更好,也不一定
        for item in enu{
            if item.element.isNumber{
                tmp.append(item.element)
            }
            else{
                if tmp.last != nil && tmp.last! != "|"{
                    tmp.append("|")
                }
            }
            
        }
        let numFragment = tmp.split("|")
        if numFragment.count <= 0{
            return nil
        }
        if numFragment.count == 1{
            return numFragment[0].toInt()
        }
        switch filter {
            case .ForwardFilter:
                return numFragment.first?.toInt()
            
            case .BackwordFilter:
                return numFragment.last?.toInt()
            
            case .AllFilter:
                return numFragment.joined().toInt()
        }
       
    }
    
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    func toUrlFileName() -> String {
        return self.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "#", with: "_").replacingOccurrences(of: "&", with: "_").replacingOccurrences(of: "?", with: "_")
    }
    
    
    func getNumbers() -> [NSNumber] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let charset = CharacterSet.init(charactersIn: " ,.")
        return matches(for: "[+-]?([0-9]+([., ][0-9]*)*|[.][0-9]+)").compactMap { string in
            return formatter.number(from: string.trimmingCharacters(in: charset))
        }
    }

    // https://stackoverflow.com/a/54900097/4488252
    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            return String(self[range])
        }
    }
    
    
    func fileSizeAtPath() -> Double? {
        let manager = FileManager.default
        if manager.fileExists(atPath: self) {
            guard let attr =  try? manager.attributesOfItem(atPath: self) else{
                return nil
            }
            return attr[FileAttributeKey.size] as? Double
        }
        else{
            return nil
        }
    }
    
    func folderSizeAtPath(completed:@escaping (_ size:Double?)->Void)  {
        let manager = FileManager.default
        var cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        cachePath = cachePath + "/" + self;
        var fileSize = 0.0
        DispatchQueue.global().async {
            if manager.fileExists(atPath: cachePath) {
                if let childFiles = manager.subpaths(atPath: cachePath){
                    for fileName in childFiles {
                        let aPath = cachePath + "/" + fileName
                        let size = aPath.fileSizeAtPath() ?? 0
                        fileSize += size
                    }
                }
                 KingfisherManager.shared.cache.calculateDiskStorageSize(completion: { res in
                   let imgSize =  try? res.get()
                    print(imgSize ?? 0)
                    completed(fileSize)
                })
                
                
            }
            else{
                completed(nil)
            }
        }
       
    }
    
    func replaceRange(start:Int,end:Int,str:String) -> String {
        let s = substring(from: start, to: end)
        return replacingOccurrences(of: s, with: str)
    }
    
    func index(str:Character) -> Int {
        let index = self.firstIndex(of: str)
        if index == nil {
            return -1
        }
        return self.distance(from: startIndex, to: index!)
    }
    
    func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    func toDecimal() -> Decimal?  {
        if let dou = toDouble(){
            return Decimal(dou)
        }
        return nil
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
}

extension NSMutableAttributedString{
    func addColor(color:UIColor,range:NSRange)  {
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func addFont(font:UIFont,range:NSRange) {
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
}
