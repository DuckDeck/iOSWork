//
//  UIViewExtension.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/5.
//

import UIKit

extension UIView{
    func addBorder() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.random.cgColor
    }
}
