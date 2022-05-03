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
        if #available(iOSApplicationExtension 13.0, *) {
            let impact = UIImpactFeedbackGenerator(style: .soft)
            impact.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
}
