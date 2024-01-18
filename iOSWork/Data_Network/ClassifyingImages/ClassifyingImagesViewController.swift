//
//  ClassifyingImagesViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/22.
//

import UIKit
class ClassifyingImagesViewController:BaseViewController,TZImagePickerControllerDelegate{
    
    var imagePickerController:TZImagePickerController!
    let img = UIImageView()
    let lblResult = UILabel()
    let imagePredictor = ImagePredictor()
    let predictionsToShow = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择照片", style: .plain, target: self, action: #selector(chooseImage))
        view.backgroundColor = UIColor.white

        imagePickerController = TZImagePickerController(maxImagesCount: 3, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let one = images?.first{
                self?.img.image = one
                self?.classifyImage(one)
               
            }
        }
        
        img.contentMode = .scaleAspectFill
        img.layer.borderWidth = 6
        img.layer.borderColor = UIColor.clear.cgColor
        img.clipsToBounds = true
        img.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(UIDevice.topAreaHeight)
            m.height.equalTo(ScreenWidth * 0.6)
        }

        lblResult.addTo(view: view).snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(img.snp.bottom).offset(50)
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            lblResult.text = "没有结果，请看log"
            return
        }

        let formattedPredictions = formatPredictions(predictions)

        let predictionString = formattedPredictions.joined(separator: "\n")
        lblResult.text = predictionString
    }

    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
    
    @objc func chooseImage(){
        present(imagePickerController, animated: true, completion: nil)
    }
}
