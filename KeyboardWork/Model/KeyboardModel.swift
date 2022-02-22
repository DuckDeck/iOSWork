//
//  File.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import Foundation
var counter = 0

enum ShiftState {
    case disabled
    case enabled
    case locked
    
    func uppercase() -> Bool {
        switch self {
        case .disabled:
            return false
        case .enabled:
            return true
        case .locked:
            return true
        }
    }
}

class Keyboard {
    var pages: [Page] = []
    
    func add(key: Key, row: Int, page: Int) {
        if self.pages.count <= page {
            for _ in self.pages.count...page {
                self.pages.append(Page())
            }
        }
        
        self.pages[page].add(key: key, row: row)
    }
}

class Page {
    var rows: [[Key]] = []
    
    func add(key: Key, row: Int) {
        if self.rows.count <= row {
            for _ in self.rows.count...row {
                self.rows.append([])
            }
        }

        self.rows[row].append(key)
    }
}

class Key: Hashable {
    enum KeyType {
        case character
        case specialCharacter
        case shift
        case backspace
        case modeChange
        case keyboardChange
        case period
        case space
        case `return`
        case settings
        case other
    }
    
    var type: KeyType
    var uppercaseKeyCap: String?
    var lowercaseKeyCap: String?
    var uppercaseOutput: String?
    var lowercaseOutput: String?
    var toMode: Int? //if the key is a mode button, this indicates which page it links to
    
    var isCharacter: Bool {
        get {
            switch self.type {
            case
            .character,
            .specialCharacter,
            .period:
                return true
            default:
                return false
            }
        }
    }
    
    var isSpecial: Bool {
        get {
            switch self.type {
            case .shift:
                return true
            case .backspace:
                return true
            case .modeChange:
                return true
            case .keyboardChange:
                return true
            case .return:
                return true
            case .settings:
                return true
            default:
                return false
            }
        }
    }
    
    var hasOutput: Bool {
        get {
            return (self.uppercaseOutput != nil) || (self.lowercaseOutput != nil)
        }
    }
    
    // TODO: this is kind of a hack
    var hashValue: Int
    
    init(_ type: KeyType) {
        self.type = type
        self.hashValue = counter
        counter += 1
    }
    
    convenience init(_ key: Key) {
        self.init(key.type)
        
        self.uppercaseKeyCap = key.uppercaseKeyCap
        self.lowercaseKeyCap = key.lowercaseKeyCap
        self.uppercaseOutput = key.uppercaseOutput
        self.lowercaseOutput = key.lowercaseOutput
        self.toMode = key.toMode
    }
    
    func setLetter(_ letter: String) {
        self.lowercaseOutput = letter.lowercased()
        self.uppercaseOutput = letter.uppercased()
        self.lowercaseKeyCap = self.lowercaseOutput
        self.uppercaseKeyCap = self.uppercaseOutput
    }
    
    func outputForCase(_ uppercase: Bool) -> String {
        if uppercase {
            return uppercaseOutput ?? lowercaseOutput ?? ""
        }
        else {
            return lowercaseOutput ?? uppercaseOutput ?? ""
        }
    }
    
    func keyCapForCase(_ uppercase: Bool) -> String {
        if uppercase {
            return uppercaseKeyCap ?? lowercaseKeyCap ?? ""
        }
        else {
            return lowercaseKeyCap ?? uppercaseKeyCap ?? ""
        }
    }
}

func ==(lhs: Key, rhs: Key) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

enum Direction: Int, CustomStringConvertible {
    case left = 0
    case down = 3
    case right = 2
    case up = 1
    
    var description: String {
        get {
            switch self {
            case .left:
                return "Left"
            case .right:
                return "Right"
            case .up:
                return "Up"
            case .down:
                return "Down"
            }
        }
    }
    
    func clockwise() -> Direction {
        switch self {
        case .left:
            return .up
        case .right:
            return .down
        case .up:
            return .right
        case .down:
            return .left
        }
    }
    
    func counterclockwise() -> Direction {
        switch self {
        case .left:
            return .down
        case .right:
            return .up
        case .up:
            return .left
        case .down:
            return .right
        }
    }
    
    func opposite() -> Direction {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .up:
            return .down
        case .down:
            return .up
        }
    }
    
    func horizontal() -> Bool {
        switch self {
        case
        .left,
        .right:
            return true
        default:
            return false
        }
    }
}
