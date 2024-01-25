//
//  NetTool.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/1/4.
//

import UIKit
import PhoneNetSDK
class NetTool {
    
    fileprivate var traceroute: PNUdpTraceroute?

    
    func getDNSAddress()->[String]{
        return BaseBridge().getDnsAddress()
    }
    
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
    
    func checkPing(url:String,callback: @escaping NetPingResultHandler, lossCallback: @escaping (_ count: Int,_ error:Error?) -> Void) {
        guard let u = URL(string: url) else {
            lossCallback(0,NSError(domain: "url不合法", code: -1))
            return
        }
        guard let host = u.host else {
            lossCallback(0,NSError(domain: "url没有host", code: -1))
            return
        }
        if PhoneNetManager.shareInstance().isDoingPing() {
            PhoneNetManager.shareInstance().netStopPing()
        }
        if self.traceroute?.isDoingUdpTraceroute() ?? false {
            self.traceroute?.stop()
        }
        let pingRegular = "[\\s\\S]*?packets transmitted , loss:(\\d*?) , delay:[\\s\\S]*?"
        PhoneNetManager.shareInstance().netStartPing(host, packetCount: 10) { (res) in
            DispatchQueue.main.async {
                if let r = res,let result = RegexTool.init(pingRegular).matchResult(input: r),result.count > 0{
                    let  range = result[0].range
                    let count = r.substring(from: range.location, length: range.length)
                    lossCallback(Int(count) ?? 0, nil)
                    print(result)
                }
                
                callback(res)
            }
        }
    }
    
    func traceRoute(url:String,callback: @escaping PNUdpTracerouteHandler, completeCallback: @escaping (_ msg: String?,_ err:Error?) -> Void){
        guard let u = URL(string: url) else {
            completeCallback(nil,NSError(domain: "url不合法", code: -1))
            return
        }
        guard let host = u.host else {
            completeCallback(nil,NSError(domain: "url没有host", code: -1))
            return
        }
        if self.traceroute?.isDoingUdpTraceroute() ?? false {
            self.traceroute?.stop()
        }
        let traceRegular = "udp traceroute complete"
        self.traceroute = PNUdpTraceroute.start(host) { (res) in
            DispatchQueue.main.async {
                callback(res)
                if let r = res,let result = RegexTool.init(traceRegular).matchResult(input: r as String),result.count > 0{
                    completeCallback(r as String,nil)
                }
            }
        }
    }
}

struct DomainInfo{
    var name = ""
    var ip = ""
}
