//
//  HardareInfo.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/4/13.
//

import Foundation
import GrandKit
class HardwareInfoViewController:UIViewController{
    var timer:GrandTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        timer = GrandTimer.every(TimeSpan.fromSeconds(1), block: {
            if let info = UIDevice.current.cpuUsage{
                print(info.cpu_ticks.0)
                print(info.cpu_ticks.1)
                print(info.cpu_ticks.2)
                print(info.cpu_ticks.3)
                print("--------------")
            }
        })
        timer.fire()
    }
}


extension UIDevice{
    var cpuUsage:host_cpu_load_info?{
//        kern_return_t kr;
//            mach_msg_type_number_t count;
//            static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
//            host_cpu_load_info_data_t info;
//
//            count = HOST_CPU_LOAD_INFO_COUNT;
//
//            kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
//            if (kr != KERN_SUCCESS) {
//                return -1;
//            }
//
//            natural_t user   = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
//            natural_t nice   = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
//            natural_t system = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
//            natural_t idle   = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
//            natural_t total  = user + nice + system + idle;
//            previous_info    = info;
//
//            return (user + nice + system) * 100.0 / total;\
        
            let  HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride

            var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
            let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)

            let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }

            if result != KERN_SUCCESS{
                print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
                return nil
            }
            let data = hostInfo.move()
            hostInfo.deallocate()
            let user = data.cpu_ticks.0
            return data
    }
}
