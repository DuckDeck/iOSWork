//
//  Theme.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/7/10.
//

import Foundation
import UIKit
infix operator |: AdditionPrecedence
public extension UIColor {
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
        if UserDefaults.standard.overridedUserInterfaceStyle == .unspecified {
            return UIColor { traitCollection -> UIColor in
                traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
            }
        } else {
            return UserDefaults.standard.overridedUserInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}

var MenuBgColor: UIColor {
    return  menuBgColor
}



var cPopChooseBorderColor:UIColor{
    return Colors.colorB4B7C0 | Colors.color48494D
}
var cSelectTextBorderColor:UIColor{
    return Colors.color17181A.withAlphaComponent(0.08) | UIColor.white.withAlphaComponent(0.16)
}

var menuBgColor:UIColor{
    return Colors.colorF6F6F6 | UIColor("444444")
}

var chatMenuBgColor:UIColor{
    return Colors.colorF6F6F6 | UIColor("1C1D1F")
}

var keyboardBgColor:UIColor{
    return UIColor("D1D3D9") | UIColor("313131")
}


var cKeyCalBgColor: UIColor {
    return UIColor(hexString: "F6F6F6")! | UIColor(hexString: "414347")!
}

var cKeyTextColor: UIColor {
    return UIColor(hexString: "1E2028")! | UIColor.white
}

var cKeyTipColor: UIColor {
    return UIColor(hexString: "6E7382")! | UIColor(hexString: "BFC1C6")!
}

var cKeyBgColor: UIColor {
    return UIColor.white | UIColor(hexString: "696B70")!
}

var cKeyBgColor2: UIColor {
    return UIColor(hexString: "B4B7C0")! | UIColor(hexString: "48494D")!
}

var cKeyShadowColor: UIColor {
    return UIColor(hexString: "898A8D")! | UIColor.black.withAlphaComponent(0.3)
}

var cKeyBgPressColor: UIColor {
    return UIColor(hexString: "AFB2BD")! | UIColor(hexString: "48494D")!
}

var cKeyShiftOnColor: UIColor {
    return UIColor.white | UIColor(hexString: "F1F1F1")!
}

var cKeyboardBgColor:UIColor{
    return UIColor(hexString: "D5D8DD")!.withAlphaComponent(0.93) | UIColor(hexString: "313132")!
}
