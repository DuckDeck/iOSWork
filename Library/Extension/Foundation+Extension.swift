
//
//  Foundation+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import AVKit
import CommonCrypto
import Foundation
import GrandKit
import Kingfisher

extension NSObject {
    func addDispose() {}

    func getProperty() -> [String] { // 和description属性一样
        var selfProperties = [String]()
        var count: UInt32 = 0
        let vars = class_copyIvarList(type(of: self), &count)
        for i in 0..<count {
            let t = ivar_getName((vars?[Int(i)])!)
            if let n = NSString(cString: t!, encoding: String.Encoding.utf8.rawValue) as String? {
                selfProperties.append(n)
            }
        }
        free(vars)
        return selfProperties
    }
}

extension Dictionary {
    mutating func merge(newDict: Dictionary) {
        for (k, v) in newDict {
            self[k] = v
        }
    }
}

protocol DictionaryValue {
    var value: Any { get }
}

protocol JsonValue: DictionaryValue {
    var jsonValue: String { get }
}

extension DictionaryValue {
    var value: Any {
        let mirror = Mirror(reflecting: self)
        var result = [String: Any]()
        for c in mirror.children {
            guard let key = c.label else {
                fatalError("Invalid key in child: \(c)")
            }
            if let v = c.value as? DictionaryValue {
                result[key] = v.value
            }
            else {
                fatalError("Invalid value in child: \(c)")
            }
        }
        return result
    }
}

extension JsonValue {
    var jsonValue: String {
        let data = try? JSONSerialization.data(withJSONObject: value as! [String: Any], options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension Int: DictionaryValue { var value: Any { return self }}

extension Float: DictionaryValue { var value: Any { return self }}

extension String: DictionaryValue { var value: Any { return self }}

extension Bool: DictionaryValue { var value: Any { return self }}

extension Array: DictionaryValue {
    var value: Any {
        // 这里需要判断
        return map { ($0 as! DictionaryValue).value }
    }
}

extension Dictionary: DictionaryValue {
    var value: Any {
        var dict = [String: Any]()
        for (k, v) in self {
            dict[k as! String] = (v as! DictionaryValue).value
        }
        return dict
    }
}

extension Array: JsonValue {
    var jsonValue: String {
        // 这里需要判断
        let strs = map { ($0 as! DictionaryValue).value }
        let data = try? JSONSerialization.data(withJSONObject: strs, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension Dictionary: JsonValue {
    var jsonValue: String {
        // for normal dict ,the key always be a stribg
        // so we can do
        var dict = [String: Any]()
        for (k, v) in self {
            dict[k as! String] = (v as! DictionaryValue).value
        }
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension CGSize {
    func ratioSize(scale: CGFloat) -> CGSize {
        return CGSize(width: scale * self.width, height: scale * self.height)
    }
}

extension CGRect {
    public init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }

    var center: CGPoint {
        return CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y + self.size.height / 2)
    }

    func centerRect(w: CGFloat, h: CGFloat) -> CGRect {
        if w >= self.width || h >= self.height {
            return self
        }
        return CGRect(x: self.center.x - w / 2, y: self.center.y - h / 2, width: w, height: h)
    }

    func large(w: CGFloat, h: CGFloat) -> CGRect {
        return CGRect(x: origin.x - w, y: origin.y - h, width: size.width + w, height: size.height + h)
    }

    func large(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) -> CGRect {
        return CGRect(x: origin.x - left, y: origin.y - top, width: size.width + left + right, height: size.height + top + bottom)
    }
}

extension URL {
    func getfileSize() -> CLongLong {
        let manager = FileManager.default
        if manager.fileExists(atPath: self.path) {
            do {
                let item = try manager.attributesOfItem(atPath: self.path)
                return item[FileAttributeKey.size] as! CLongLong
            }
            catch {
                print("File not exist")
            }
        }
        return 0
    }

    func getFileCreateTime() -> Int? {
        if let attr = try? FileManager.default.attributesOfItem(atPath: self.path) {
            return DateTime.parse("\(attr[FileAttributeKey.creationDate]!)")?.timestamp
        }
        return 0
    }

    func getMediaDuration(mediaType: AVMediaType) -> Int {
        let assert = AVURLAsset(url: self)
        if let track = assert.tracks(withMediaType: mediaType).first {
            return Int(CMTimeGetSeconds(track.timeRange.duration))
        }
        return 0
    }

    var directory: URL? {
        if self.isFileURL {
            if self.lastPathComponent.count > 0 {
                var str = self.path
                str.removeLast(self.lastPathComponent.count)
                return URL(fileURLWithPath: str)
            }
        }
        return nil
    }

    var isFlod: Bool {
        var i = ObjCBool(false)
        FileManager.default.fileExists(atPath: self.absoluteString, isDirectory: &i)
        return i.boolValue
    }

    func changeSchema(targetSchema: String) -> URL? {
        var com = URLComponents(url: self, resolvingAgainstBaseURL: false)
        com?.scheme = targetSchema
        return com?.url
    }
}

public extension Sequence where Element: Hashable {
    // 如果集合中所有元素都满足要求就返回true
    func all(matching predicate: (Element) -> Bool) -> Bool {
        return !contains { !predicate($0) }
    }

    // 返回该集合中所有唯一的元素
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { element -> Bool in
            if seen.contains(element) {
                return false
            }
            else {
                seen.insert(element)
                return true
            }
        }
    }
}

extension Data {
    var md5: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = self.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(self.count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

