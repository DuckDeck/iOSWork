//
//  CatchExtension.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/19.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation

extension String {
    func addHttps() -> String {
        if !hasPrefix("http") && hasPrefix("//") {
            return "https:\(self)"
        }
        return self
    }

    var unicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }

    var removeSpace: String {
        replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\u00a0".unicodeCharacters, with: "").replacingOccurrences(of: "\\u3000".unicodeCharacters, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var replaceSpaceSymble: String {
        replacingOccurrences(of: "\\u00a0".unicodeCharacters, with: " ").replacingOccurrences(of: "\\u3000".unicodeCharacters, with: " ")
    }
}
