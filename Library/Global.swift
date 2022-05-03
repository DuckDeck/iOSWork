//
//  Global.swift
//  Library
//
//  Created by Stan Hu on 2021/10/23.
//

import UIKit
import GrandKit
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let TabBarHeight:CGFloat = 49.0
let SystemVersion:Double = Double(UIDevice.current.systemVersion)!
let APPVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

let NotchStatusBarHeight : CGFloat = 25
let NavigationBarHeight:CGFloat = 64.0 + (UIDevice.isNotchScreen ? NotchStatusBarHeight : 0)
let StatusBarHeight:CGFloat = 0.0 + (UIDevice.isNotchScreen ? NotchStatusBarHeight : 0)
let iPhoneBottomBarHeight:CGFloat = 0.0 + (UIDevice.isNotchScreen ? 35 : 0)


let kColorcccccc = UIColor(hexString: "cccccc")!
let kColora6a6a6 = UIColor(hexString: "a6a6a6")!
let kColor3a9a52 = UIColor(hexString: "3a9a52")!
let kColor49c167 = UIColor(hexString: "49c167")!      //主题色
let kColor222222 = UIColor(hexString: "222222")!
let kColor0a0a0a = UIColor(hexString: "0a0a0a")!
let kColor888888 = UIColor(hexString: "888888")!
let kColorb3b7bC = UIColor(hexString: "B3B7BC")!
let kColord1d5db = UIColor(hexString: "D1D5DB")!
let kColor5b5b5b = UIColor(hexString: "5B5B5B")!
let kColorff5338 = UIColor(hexString: "FF5338")!
let kColorebebeb = UIColor(hexString: "EBEBEB")!
let kColor626266 = UIColor(hexString: "626266")!
let kColorbbbbbb = UIColor(hexString: "BBBBBB")!
let kColorf5f5f5 = UIColor(hexString: "F5F5F5")!
let kColorf5fff8 = UIColor(hexString: "F5FFF8")!
let kColor285b9a = UIColor(hexString: "285B9A")!
let kColordddddd = UIColor(hexString: "DDDDDD")!
let kColor898a8d = UIColor(hexString: "898a8d")!
let kColora9abb0 = UIColor(hexString: "A9ABB0")!

struct regexTool {
    let regex:NSRegularExpression?
    init(_ pattern:String){
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    func match(input:String)->Bool{
        if let matches = regex?.matches(in: input, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        else{
            return false
        }
    }
}



infix operator =~
func =~(lhs:String,rhs:String) -> Bool{ //正则判断
    return regexTool(rhs).match(input: lhs)
}

let REGEX_FlOAT = "^([0-9]*.)?[0-9]+$"
let REGEX_MAIL = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
let REGEX_CELLPHONE = "^(0|86|17951)?1[0-9]{10}$"
let REGEX_IDENTITY_NUM = "^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X)$"
let REGEX_EMOJI = "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
let REGEX_URL = "^http://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
let REGEX_QQ = "^[1-9][0-9]{4,10}"
let REGEX_TEL_PHONE = "^(([0\\+]\\d{2,3}-)?(0\\d{2,3})-)?(\\d{7,8})(-(\\d{3,}))?$"




typealias Task = (_ cancel:Bool)->()
@discardableResult
func delay(time:TimeInterval,task:@escaping ()->())->Task?{
    func dispatch_later( block: @escaping ()->Void){
        let delayTime = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
    }
    var closure:(()->Void)? = task
    var result:Task?
    let delayClosure:Task = {
        cancel in
        if let internalClosure = closure{
            if cancel == false{
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    result = delayClosure
    dispatch_later {
        if let delayClosure = result{
            delayClosure(false)
        }
    }
    return result
}

func cancel(task:Task?){
    task?(true)
}


func Log<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    #if DEBUG
        if   let path = NSURL(string: file)
        {
            let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
            print(log)
        }
    #endif
}

func GLog<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    if   let path = NSURL(string: file)
    {
        let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
    //    let s = LogTool.sharedInstance.addLog(log: log)
        
        print(log)
    }
}



func +(lhs: Int,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Int)->Double{
    return lhs + Double(rhs)
}

func +(lhs: Int,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:Int)->Float{
    return lhs + Float(rhs)
}

func +(lhs: Float,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Float)->Double{
    return lhs + Double(rhs)
}


func +(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:UInt)->Double{
    return lhs + Double(rhs)
}

func +(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:UInt)->Float{
    return lhs + Float(rhs)
}

func -(lhs: Int,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Int)->Double{
    return lhs - Double(rhs)
}

func -(lhs: Int,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:Int)->Float{
    return lhs - Float(rhs)
}

func -(lhs: Float,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Float)->Double{
    return lhs - Double(rhs)
}


func -(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:UInt)->Double{
    return lhs - Double(rhs)
}

func -(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:UInt)->Float{
    return lhs - Float(rhs)
}

func *(lhs: Int,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Int)->Double{
    return lhs * Double(rhs)
}

func *(lhs: Int,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:Int)->Float{
    return lhs * Float(rhs)
}

func *(lhs: Int,rhs:CGFloat)->CGFloat{
    return CGFloat(lhs) * rhs
}

func *(lhs: CGFloat,rhs:Int)->CGFloat{
    return lhs * CGFloat(rhs)
}

func *(lhs: Float,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Float)->Double{
    return lhs * Double(rhs)
}


func *(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:UInt)->Double{
    return lhs * Double(rhs)
}

func *(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:UInt)->Float{
    return lhs * Float(rhs)
}


func /(lhs: Int,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Int)->Double{
    return lhs / Double(rhs)
}

func /(lhs: Int,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:Int)->Float{
    return lhs / Float(rhs)
}

func /(lhs: Float,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Float)->Double{
    return lhs / Double(rhs)
}


func /(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:UInt)->Double{
    return lhs / Double(rhs)
}

func /(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:UInt)->Float{
    return lhs / Float(rhs)
}




//Swizzle

func hookInstanceMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)
    let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    if didAddMethod{
        class_replaceMethod(cls, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    }
    else{
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

public func hookClassMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
    let originalMethod = class_getClassMethod(cls, originalSelector)
    let swizzledMethod = class_getClassMethod(cls, swizzleSelector)
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    //交换 static 或者 class 方法不能使用class_addMethod，直接使用method_exchangeImplementations就行
}


//let kColor222222 = UIColor(hexString: "222222")!
//let kColorb3b7bC = UIColor(hexString: "b3b7bC")!
//let kColor0a0a0a = UIColor(hexString: "0a0a0a")!
//let kColor3a9a52 = UIColor(hexString: "3a9a52")!
//let kColora6a6a6 = UIColor(hexString: "a6a6a6")!
//let kColor898a8d = UIColor(hexString: "898a8d")!
//let kColord1d5db = UIColor(hexString: "d1d5db")!
//let kColor888888 = UIColor(hexString: "888888")!
//let kColorbbbbbb = UIColor(hexString: "bbbbbb")!
//let kCOlora9abb0 = UIColor(hexString: "a9abb0")!
