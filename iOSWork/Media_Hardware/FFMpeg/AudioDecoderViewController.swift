//
//  AudioDecoderViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2021/11/28.
//

import Foundation
class AudioDecoderViewController: UIViewController {

    let btnRecord = UIButton()
    let btnStop = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Audio Queue 处理音频"
        view.backgroundColor = UIColor.white
        AudioQueueCaptureManager.getInstance().startAudioCapture()
      
        btnRecord.title(title: "开始录音").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(50)
        }
        
        btnRecord.addTarget(self, action: #selector(record), for: .touchUpInside)
        
        btnStop.title(title: "停止录音").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(100)
            m.right.equalTo(-50)
            m.width.equalTo(100)
            m.height.equalTo(50)
        }
        
        btnStop.addTarget(self, action: #selector(stop), for: .touchUpInside)

    }
    
    @objc func record()  {
        Toast.showToast(msg: "开始录音")
        AudioQueueCaptureManager.getInstance().startRecordFile()
    }
    
    @objc func stop() {
        Toast.showToast(msg: "结束录音")
        AudioQueueCaptureManager.getInstance().stopRecordFile()
    }

    deinit {
        AudioQueueCaptureManager.getInstance().stopAudioCapture()
    }

}

