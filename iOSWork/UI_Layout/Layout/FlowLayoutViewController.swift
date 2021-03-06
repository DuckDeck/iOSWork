//
//  FlowLayoutViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/13.
//

import UIKit
class FlowLayoutViewController: UIViewController {

    var vCol:UICollectionView!
    var heights = [Double]()
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<200{
            var i = Double(arc4random() % 100 )
            if i < 20{
                i = i + 20
            }
            heights.append(i)
        }
        let layout = FlowLayout(columnCount: 3, columnMargin: 8) { [weak self](index) -> Double in
           return self!.heights[index.row]
        }

        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(vCol)
    }
    

   
}

extension FlowLayoutViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.random
        return cell
    }
    
    
}
