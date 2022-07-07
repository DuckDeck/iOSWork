//
//  Shake.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/14.
//

import UIKit
import AudioToolbox

struct Shake{
    static func keyShake(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
