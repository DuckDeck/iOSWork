//
//  Store.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit
import SwiftyJSON
open class Store<T> where T: Codable {
    fileprivate var name: String!
    fileprivate var value: T?
    fileprivate var defaultValue: T?
    var hasValue: Bool = false
    fileprivate var timeout: Int = 0
    fileprivate var observerBlock: ((_ observerObject: AnyObject, _ observerKey: String, _ oldValue: AnyObject, _ newValue: AnyObject) -> Void)?
    fileprivate var isUseKeyboardStore = false
    @objc var key: String {
        return name
    }
    //如果键盘没有开启完全访问的情况下不是能访问appgroup的沙盒的，好像只能访问自己的userdefault
    public init(name: String, defaultValue: T,isUseKeyboardStore:Bool = false) {
        self.name = name
        self.defaultValue = defaultValue
        self.isUseKeyboardStore = isUseKeyboardStore
    }
    
    var store:UserDefaults{
        if isUseKeyboardStore{
            return Store.keyboardStore
        } else {
            return Store.store
        }
    }
    
    open var Value: T {
        get {
            if !hasValue {
                if storeLevel == 0 {
                    if store.object(forKey: name) == nil {
                        self.value = self.defaultValue
                        store.set(self.value!, forKey: self.name)
                    } else {
                        self.value = store.object(forKey: self.name) as? T
                    }
                }
                if storeLevel == 1 {
                    if store.data(forKey: self.name) == nil {
                        self.value = self.defaultValue
                        store.setValue(self.value?.toData, forKey: self.name)
                    } else {
                        let data = store.data(forKey: self.name)
                        let d = JSONDecoder()
                        if let tmp = try? d.decode(T.self, from: data!) {
                            self.value = tmp
                        } else {
                            clear()
                            self.value = defaultValue
                        }
                    }
                }
                hasValue = true
                store.synchronize()
            }
            return self.value ?? defaultValue!
        }
        set {
            if let call = self.observerBlock {
                if self.value == nil {
                    self.value = self.defaultValue
                }
                call(self, self.name, self.value as AnyObject, newValue as AnyObject)
            }
            self.value = newValue
            if storeLevel == 0 {
                store.set(self.value!, forKey: self.name)
                store.synchronize()
            }
            if storeLevel == 1 {
                store.setValue(self.value?.toData, forKey: self.name)
            }
            hasValue = true
        }
    }

    open var DictValue: [String: Any]? {
        get {
            if storeLevel == 1 {
                let jsonEncoder = JSONEncoder()
                guard let jsonData = try? jsonEncoder.encode(Value) else {return nil}
                guard let obj = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) else {return nil}
                return obj as? [String: Any]
            } else {
                return nil
            }
        }
        set {
            if storeLevel == 1 {
                if let dict = newValue {
                    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {return}
                    let jsonDecoder = JSONDecoder()
                    Value = try! jsonDecoder.decode(T.self, from: data)
                }
            }
        }
    }

    open var JsonValue: String? {
        get {
            if storeLevel == 1 {
                let jsonEncoder = JSONEncoder()
                guard let jsonData = try? jsonEncoder.encode(Value) else {return nil}
                return String(data: jsonData, encoding: .utf8)
            } else {
                return nil
            }
        }
        set {
            if storeLevel == 1 {
                if let str = newValue {
                    let jsonDecoder = JSONDecoder()
                    guard let data = str.data(using: .utf8) else {return}
                    Value = try! jsonDecoder.decode(T.self, from: data)
                }
            }
        }
    }

    open var wilfulValue: T? {
        return value
    }

    open func clear() {
        if let call = observerBlock {
            call(self, name, value as AnyObject, defaultValue as AnyObject)
        }
        store.removeObject(forKey: name)
        store.synchronize()
        hasValue = false
    }

    func clearMemory() {
        hasValue = false
    }

    open func addObserver(_ block: @escaping (_ observerObject: AnyObject, _ observerKey: String, _ oldValue: AnyObject, _ newValue: AnyObject) -> Void) {
        observerBlock = block
    }

    open func removeObserver() {
        observerBlock = nil
    }

    fileprivate var storeLevel : Int {
        if defaultValue! is NSNumber || defaultValue! is String || defaultValue! is Date || defaultValue! is Data
        {
            return 0
        }
        return 1
    }

    
    static func value(key:String)->T?{
        return store.value(forKey: key) as? T
    }
    
    static func clear(key:String){
        store.removeObject(forKey: key)
    }
    
    static func setValue(key:String,value:T){
        store.set(value, forKey: key)
        store.synchronize()
    }
    
    
    static func innerValue(key:String)->T?{
        return keyboardStore.value(forKey: key) as? T
    }
    
    static func clearInner(key:String){
        keyboardStore.removeObject(forKey: key)
        keyboardStore.synchronize()
    }
    
    static func clearInners(keys:[String]){
        for item in keys{
            keyboardStore.removeObject(forKey: item)
            keyboardStore.synchronize()
        }
    }
    
    static func setInnerValue(key:String,value:T){
        keyboardStore.set(value, forKey: key)
        keyboardStore.synchronize()
    }
    
    
    
    fileprivate static var store : UserDefaults {
        return UserDefaults(suiteName: "group.com.wego.com.wego.WeAblum.WGKeyBoard.ShareExtension")!
    }
    fileprivate static var keyboardStore : UserDefaults {
        return UserDefaults.standard
    }
}

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
    var toStringJson : String? {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    var toData:Data?{
        if let data = try? JSONEncoder().encode(self){
            return data
        }
        return nil
    }
}
