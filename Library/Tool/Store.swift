//
//  Store.swift
//  Library
//
//  Created by Stan Hu on 2021/11/22.
//

import Foundation
import GrandKit
class Store:NSObject{
    static var AppErrors = GrandStore(name: "AppErrors", defaultValue: [AppError]())
}
