//
//  FiveStroke.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/8.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandKit
import SwiftyJSON
struct FiveStroke: Codable { //好像GrandModel的自动保存已经失效？一定要加上@objcMembers才行
    var word = ""
    var spell = ""
    var code = ""
    static let FiveStrokeLog = GrandStore(name: "FiveStrokeLog", defaultValue: [FiveStroke]())
}


