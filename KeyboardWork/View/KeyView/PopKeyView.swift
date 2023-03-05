//
//  PopKeyView.swift
//  WGKeyBoard
//
//  Created by Stan Hu on 2022/7/12.
//

import Foundation
import UIKit
class PopKeyView:UIImageView{
    
    var id:UInt8 = 0
    enum PopKeyViewLocation{
        case left,center,right
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lblKey)
        lblKey.snp.makeConstraints { make in
            make.top.equalTo(3)
            make.centerX.equalTo(self)
        }
    }
    
    func setKey(key:String,location:PopKeyViewLocation,popImage:String? = nil,fontsize:CGFloat? = nil,keyTop:CGFloat? = nil){
      
      
        lblKey.text = key
        if fontsize != nil{
            lblKey.font = UIFont(name: "PingFangSC-Regular", size: fontsize!)
            
        }
        if keyTop != nil{
            lblKey.snp.updateConstraints { make in
                make.top.equalTo(keyTop!)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    lazy var lblKey: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "PingFangSC-Regular", size: 36)
        v.textColor = cKeyTextColor
        return v
    }()
}
