//
//  Codable+Extension.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/1/13.
//

import Foundation
extension Decodable {
    static func parse(d: Data) -> Self? {
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: d)
    }
}

extension Encodable {
    var jsonString: String? {
        if let d = data {
            return String(data: d, encoding: .utf8)
        }
        return nil
    }

    var data: Data? {
        if let data = try? JSONEncoder().encode(self) {
            return data
        }
        return nil
    }
}
