//
//  KeyboardInputTraits.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import Foundation
import QuartzCore
import UIKit
var traitPollingTimer: CADisplayLink?

extension KeyboardViewController {
    
    func addInputTraitsObservers() {
        // note that KVO doesn't work on textDocumentProxy, so we have to poll
        traitPollingTimer?.invalidate()
        traitPollingTimer = UIScreen.main.displayLink(withTarget: self, selector: #selector(KeyboardViewController.pollTraits))
        traitPollingTimer?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
    }
    
    @objc func pollTraits() {
        let proxy = self.textDocumentProxy
        
        if let layout = self.layout {
            let appearanceIsDark = (proxy.keyboardAppearance == UIKeyboardAppearance.dark)
            if appearanceIsDark != layout.darkMode {
                self.updateAppearances(appearanceIsDark)
            }
        }
    }
}
