//
//  FullKeyboardView.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/4.
//

import UIKit

class FullKeyboardView: Keyboard {
    var popChooseView:PopKeyChooseView?
    
    var firstKeys:[KeyInfo]!
    var secondKeys:[KeyInfo]!
    var thirdKeys:[KeyInfo]!
    var forthKeys:[KeyInfo]!
    var shiftStatus = KeyShiftType.normal
    fileprivate override init(frame: CGRect) {
         super.init(frame: frame)
     }
     
     convenience init(keyboardType:KeyboardType) {
         self.init(frame: .zero)
         self.currentKeyBoardType = keyboardType
         
         switch keyboardType {
       
         case .chinese26,.chinese:
             setChinese26Data()
         case .english:
             setEnglish26Data()
         case .symbleChiese:
             setChineseSymbleData()
         case .symbleEnglish:
             setEnglishSymbleData()
         case .symbleChieseMore:
             setChineseSymbleMoreData()
         case .symbleEnglishMore:
             setEnglishSybmbleMoreData()
         
         default:
             break
         }
         
       
         
         addSubview(firstView)
         firstView.updateKeys(newKeys: firstKeys)
         firstView.snp.makeConstraints { make in
             make.left.right.equalTo(0)
             make.top.equalTo(3)
             make.height.equalTo(54)
         }
         
         addSubview(secondView)
         secondView.updateKeys(newKeys: secondKeys)
         secondView.snp.makeConstraints { make in
             make.left.right.equalTo(0)
             make.top.equalTo(firstView.snp.bottom)
             make.height.equalTo(54)
         }
         
         addSubview(thirdView)
         thirdView.updateKeys(newKeys: thirdKeys)
         thirdView.snp.makeConstraints { make in
             make.left.right.equalTo(0)
             make.top.equalTo(secondView.snp.bottom)
             make.height.equalTo(54)
         }
         
         addSubview(forthView)
         forthView.updateKeys(newKeys: forthKeys)
         forthView.snp.makeConstraints { make in
             make.left.right.equalTo(0)
             make.top.equalTo(thirdView.snp.bottom)
             make.height.equalTo(54)
         }
      
         for item in popKeyViews{
             addSubview(item)
         }
     }
    
     func updateShift(shift:KeyShiftType){
         self.shiftStatus = shift
         setEnglish26Data(shiftType: shift)
         firstView.updateKeys(newKeys: firstKeys)
         secondView.updateKeys(newKeys: secondKeys)
         thirdView.updateKeys(newKeys: thirdKeys)
         forthView.updateKeys(newKeys: forthKeys)
     }
     
     override func updateReturnKey(key: KeyInfo) {
         forthView.updateReturnKey(newKey: key)
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     override func keyPress(key:KeyInfo){
         print("你点了\(key.clickText)")
         delegate?.keyPress(key: key)
     }
     
     override func keyLongPress(key:KeyInfo,state:UIGestureRecognizer.State){
         delegate?.keyLongPress(key: key, state: state)
     }
     
     var idolPopKeyView:PopKeyView{
         if let v = popKeyViews.filter({$0.isHidden && !$0.isBig}).randomElement(){
             return v
         } else {
             popKeyViews.forEach{$0.isHidden = true}
             return popKeyViews.randomElement()!
         }
     }
     
     
     lazy var firstView: FullRowKeysView = {
         let v = FullRowKeysView(frame: .zero)
         return v
     }()
     
     lazy var secondView: FullRowKeysView = {
         let v = FullRowKeysView(frame: .zero)
         return v
     }()
     
     lazy var thirdView: FullRowKeysView = {
         let v = FullRowKeysView(frame: .zero)
         return v
     }()
     
     lazy var forthView: FullRowKeysView = {
         let v = FullRowKeysView(frame: .zero)
         return v
     }()
     
     lazy var popKeyViews: Set<PopKeyView> = {
         let xScale = (kSCREEN_WIDTH - 55.0) / 320.0
         var views = Set<PopKeyView>()
         for item in 0..<5{
             let v = PopKeyView(frame: CGRect(x: 0, y: 0, width: 78 * xScale, height: 104))
             v.isHidden = true
             views.insert(v)
         }
         return views
     }()
}
