//
//  PanCollectionView.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/16.
//

import UIKit

class PanCollectionView:UICollectionView{
    
    var selectMode = false
    var lastSelectedCell : IndexPath?
    var chooseMode = true //根据第一个选择的来决定是选择还是取消选择,true 是选择，false是取消选择
    var arrSelectedIndex = [IndexPath]()
    var firstSelectIndex : IndexPath?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        lastSelectedCell = nil
        firstSelectIndex = nil
        arrSelectedIndex.removeAll()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.randomElement()?.location(in: self){
            if let index = self.indexPathForItem(at: point){
                if lastSelectedCell == nil{
                    if (cellForItem(at: index) as? PanCollectionCell)?.isSelect ?? false{
                        chooseMode = false
                    } else {
                        chooseMode = true
                    }
                }
                if lastSelectedCell == nil || index != lastSelectedCell!{
                    //获取甩的cell
                    if lastSelectedCell != nil{
                        let small = min(index.row, lastSelectedCell!.row)
                        let big = max(index.row, lastSelectedCell!.row)
                        for i in small...big{
                            let path =  IndexPath(row: i, section: 0)
                            if !arrSelectedIndex.contains(path){
                                arrSelectedIndex.append(path)
                                (cellForItem(at: path) as? PanCollectionCell)?.isSelect = chooseMode
                            }
                        }
                        
                        let fSmall = min(index.row, firstSelectIndex!.row)
                        let fBig = max(index.row, firstSelectIndex!.row)

                        var ids = [Int]()
                        for i in arrSelectedIndex{
                            if fSmall > i.row || fBig < i.row{
                                ids.append(i.row)
                            }
                        }
                        
                        arrSelectedIndex.removeWith { e in
                            ids.contains(e.row)
                        }
                        for i in ids{
                            (cellForItem(at: IndexPath(row: i, section: 0)) as? PanCollectionCell)?.isSelect = !chooseMode
                        }
                        
                        if index.row > lastSelectedCell!.row{
                            if point.y - contentOffset.y > frame.size.height - 50{
                                if numberOfItems(inSection: 0) - index.row > 10{
                                    scrollToItem(at: IndexPath(row: index.row + 10, section: 0), at: .bottom, animated: true)
                                } else {
                                    scrollToItem(at: IndexPath(row: numberOfItems(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
                                }
                            }
                        }
                        if index.row < lastSelectedCell!.row{
                            if point.y - contentOffset.y < 50{
                                if index.row > 10{
                                    scrollToItem(at: IndexPath(row: index.row - 10, section: 0), at: .bottom, animated: true)
                                } else {
                                    scrollToItem(at: IndexPath(row:  0, section: 0), at: .bottom, animated: true)
                                }
                            }
                        }
                    }
                    lastSelectedCell = index
                    if firstSelectIndex == nil{
                        firstSelectIndex = index
                    }
                }
                
            }
        }

    }
}

class PanCollectionCell:UICollectionViewCell{
    var isSelect:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
//    override var isSelected: Bool  为什么要自定义一个，因为在滑动Cell时会自己调用isSelected，导致异常，所以要自己定义一个isSelect
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
