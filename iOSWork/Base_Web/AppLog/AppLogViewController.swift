//
//  AppLogViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/6/27.
//

import Foundation
import SwiftyBeaver
class AppLogViewController:BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let log = SwiftyBeaver.self
        
        log.verbose("not so important")  // prio 1, VERBOSE in silver
        log.debug("something to debug")  // prio 2, DEBUG in green
        log.info("a nice information")   // prio 3, INFO in blue
        log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        log.error("ouch, an error did occur!")  // prio 5, ERROR in red

    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "日志分享", style: .plain, target: self, action: #selector(shareLog))
    }
    
    
    @objc func shareLog(){
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ShadowEdge.iOSProject")!.appendingPathComponent("inputdata").appendingPathComponent("applog.log")
//        guard let data = try? Data.init(contentsOf:  path) else{return}
        let items = [path] as [Any]
        var activityVC : UIActivityViewController! = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.print,.copyToPasteboard,.assignToContact,.saveToCameraRoll]
        present(activityVC, animated: true)
        activityVC.completionWithItemsHandler = {( activityType,  completed,  returnedItems,  activityError) in
            activityVC = nil
        }
    }
    
    
}
