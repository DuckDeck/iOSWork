//
//  NetTool.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit

class NetTool {
    func getIpAddress(url:String)->String?{
        guard let u = URL(string: url) else { return nil }
        if u.host == nil{
            return nil
        }
        let host = CFHostCreateWithName(nil, u.host! as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success :DarwinBoolean = false
        if let addressArray = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,let address = addressArray.firstObject as? NSData{
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(address.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(address.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                return numAddress
            }
        }
        return nil
    }
}
