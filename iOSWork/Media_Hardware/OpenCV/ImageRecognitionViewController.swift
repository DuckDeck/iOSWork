//
//  \ImageRecognitionViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/28.
//

import Foundation
class ImageRecognitionViewController: OpenCVBaseViewController {
  
    
    var handle:OpenCV!
    var previewImage : UIImage?
   let imgView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let layerWidth = view.bounds.size.width - 40
        imgView.addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(layerWidth + 100)
            m.centerX.equalTo(view)
            m.width.height.equalTo(layerWidth)
        }
        handle = OpenCV()
        // Do any additional setup after loading the view.
    }

   

    func updatePreviewImage(sampleBuffer:CMSampleBuffer)  {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return
        }
        let ciimage = CIImage(cvImageBuffer: imageBuffer)
        previewImage = convertCIImageToUIImage(cimage: ciimage)
        let img = handle.regImage2(previewImage!)
        DispatchQueue.main.sync {
           
            tagLayer?.contents = img.cgImage
        }
    }

    func convertCIImageToUIImage(cimage:CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(cimage, from: cimage.extent) else{
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIImage.Orientation.right)
        return image
    }

}

extension ImageRecognitionViewController:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
//        let img = handle.regImage(sampleBuffer)
//        tagLayer?.contents = img.cgImage
        
        updatePreviewImage(sampleBuffer: sampleBuffer)
    }
}
