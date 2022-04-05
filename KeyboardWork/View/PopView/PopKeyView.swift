//
//  PopKeyView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

class PopKeyView: UIImageView {
    var id:UInt8 = 0
    enum PopKeyViewLocation{
        case left,center,right
    }
    var isBig = false //大气泡，有一些按钮比较大
    let imgLeftPop = UIImage.yh_imageNamed("icon_keyboard_pop_left")
    let imgCenterPop = UIImage.yh_imageNamed("icon_keyboard_pop_center")
    let imgRightPop = UIImage.yh_imageNamed("icon_keyboard_pop_right")
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lblKey)
        lblKey.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.centerX.equalTo(self)
        }
    }
    
    func setKey(key:String,location:PopKeyViewLocation,popImage:String? = nil){
        switch location {
        case .left:
            self.image = imgLeftPop
            lblKey.snp.updateConstraints() { make in
                make.centerX.equalTo(self).offset(-7)
            }
        case .center:
            if popImage != nil{
                self.image =  UIImage.yh_imageNamed(popImage!)
            } else {
                self.image = imgCenterPop
            }
           
            lblKey.snp.updateConstraints() { make in
                make.centerX.equalTo(self)
            }
        case .right:
            self.image = imgRightPop
            lblKey.snp.updateConstraints() { make in
                make.centerX.equalTo(self).offset(7)
            }
        }
        
        lblKey.text = key
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    lazy var lblKey: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 36)
        v.textColor = kColor222222
        return v
    }()
}
