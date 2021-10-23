//
//  Global.swift
//  Library
//
//  Created by Stan Hu on 2021/10/23.
//

import Foundation


typealias Task = (_ cancel:Bool)->()
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
