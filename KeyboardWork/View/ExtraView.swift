//
//  ExtraView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/2/22.
//

import UIKit
class ExtraView: UIView {
    
    var globalColors: GlobalColors.Type?
    var darkMode: Bool
    var solidColorMode: Bool
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        self.globalColors = globalColors
        self.darkMode = darkMode
        self.solidColorMode = solidColorMode
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.globalColors = nil
        self.darkMode = false
        self.solidColorMode = false
        
        super.init(coder: aDecoder)
    }
}
