//
//  ScanCodeViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/11.
//

import Foundation
import AVFoundation
import SnapKit
//需要添加选择图片扫码
class ScanCodeViewController: UIViewController {
    var code:String?
    //扫描相关变量
    var device:AVCaptureDevice?
    var input:AVCaptureDeviceInput?
    var outPut:AVCaptureMetadataOutput?
    var session:AVCaptureSession?
    var preview:AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "扫码"
        initView()
        setupCamera()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.startRunning()
    }
    
    func initView() {
        let vScanFrame = ScanView()
        view.addSubview(vScanFrame)
        vScanFrame.snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.height.equalTo(ScreenWidth / 2)
        }
    }

    func setupCamera() {
        device = AVCaptureDevice.default(for: AVMediaType.video)
        
        input = try? AVCaptureDeviceInput(device: device!)
        outPut = AVCaptureMetadataOutput()
        outPut?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session = AVCaptureSession()
        session?.sessionPreset = .high
        if input != nil && session!.canAddInput(input!) {
            session?.addInput(input!)
        }
        if session!.canAddOutput(outPut!) {
            session?.addOutput(outPut!)
        }
        outPut?.metadataObjectTypes = getMetadataObjectTypes()
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview?.frame = CGRect(x: 0, y: NavigationBarHeight, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight)
        view.layer.insertSublayer(preview!, at: 0)
        session?.startRunning()
    }

    func getMetadataObjectTypes() -> [AVMetadataObject.ObjectType] {
        var arr = [AVMetadataObject.ObjectType]()
        
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.ean13) {
            arr.append(AVMetadataObject.ObjectType.ean13)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.code39) {
            arr.append(AVMetadataObject.ObjectType.code39)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.ean8) {
            arr.append(AVMetadataObject.ObjectType.ean8)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.code128) {
            arr.append(AVMetadataObject.ObjectType.code128)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.qr) {
            arr.append(AVMetadataObject.ObjectType.qr)
        }
        if arr.count == 0 {
            Auth.showEventAccessDeniedAlert(view: self, authTpye: AuthType.Camera)
        }
        return arr
    }
}

extension ScanCodeViewController:AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session?.stopRunning()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        if metadataObjects.count > 0 {
            print(metadataObjects.last!)
            if let val = metadataObjects.last!.value(forKey: "stringValue") as? String{
                UIAlertController.init(title: "扫码结果", message: val, preferredStyle: .alert).action(title: "确认") { action in
                    
                }.show()
            }
        }
        else{
            session?.startRunning()
        }
    }
}

class ScanView: UIView {
    let vMobile = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
