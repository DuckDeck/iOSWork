//
//  Codable+Extension.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/1/13.
//

import Foundation
import SwiftyJSON

extension Decodable {
    static func parse(d: Data) -> Self? {
        let decoder = JSONDecoder()
        let obj:Self?
        do{
            obj = try decoder.decode(Self.self, from: d)
        } catch DecodingError.dataCorrupted(let context) {
            obj = nil
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            let str = String(data: d, encoding: .utf8)
            print("要转换的数据：——————————")
            print(str ?? "")
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            obj = nil
        } catch DecodingError.valueNotFound(let value, let context) {
            let str = String(data: d, encoding: .utf8)
            print("要转换的数据：——————————")
            print(str ?? "")
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            obj = nil
        } catch DecodingError.typeMismatch(let type, let context) {
            let str = String(data: d, encoding: .utf8)
            print("要转换的数据：——————————")
            print(str ?? "")
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            obj = nil
        } catch {
            let str = String(data: d, encoding: .utf8)
            print("要转换的数据：——————————")
            print(str ?? "")
            print(error.localizedDescription)
            obj = nil
        }
        return obj
        
    }
    
    static func parse(js: JSON) -> Self? {
        if let d = try? JSONSerialization.data(withJSONObject: js.dictionaryObject!, options: []) {
            return parse(d: d)
        }
        return nil
    }
    
    static func parse(dict:[String:Any]) -> Self?{
        if let d = try? JSONSerialization.data(withJSONObject: dict, options: []){
            return parse(d: d)
        }
        return nil
    }
    
}

extension Encodable {
    var jsonString: String? {
        if let d = data {
            return String(data: d, encoding: .utf8)
        }
        return nil
    }

    var data: Data? {
        if let data = try? JSONEncoder().encode(self) {
            return data
        }
        return nil
    }
}
