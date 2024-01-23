//
//  NetTool.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit
import PhoneNetSDK
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
    
    func checkDNS(url: String) async -> Result<[DomainInfo],Error>{
        await withCheckedContinuation { con in
            guard let u = URL(string: url) else {
                return con.resume(returning: .failure(NSError(domain: "url不合法", code: -1)))
            }
            guard let host = u.host else {
                return con.resume(returning: .failure(NSError(domain: "url没有host", code: -1)))
            }
            PhoneNetManager.shareInstance().netLookupDomain(host) { arr, err in
                if let err = err{
                    con.resume(returning: .failure(err.error))
                } else if let arr = arr,arr.count > 0,let domains = arr as? [DomainLookUpRes] {
                    var ips = [DomainInfo]()
                    for item in domains{
                        let d = DomainInfo(name: item.name,ip: item.ip)
                        ips.append(d)
                    }
                    con.resume(returning: .success(ips))
                } else {
                    con.resume(returning: .failure(NSError(domain: "PhoneNetManager没返回正确的数据", code: -1)))
                }
            }
        }
        
    }
}

struct DomainInfo{
    var name = ""
    var ip = ""
}
