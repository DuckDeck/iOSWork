//
//  SpeechViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/6/5.
//

import UIKit
import AVFAudio
class SpeechViewController: UIViewController,AVSpeechSynthesizerDelegate {
    let syn = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "语音合成"
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(play))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @objc func play(){
        let path = NSTemporaryDirectory()
        let words = "相册收款123123.44元"
            // 拿文本，去实例化语音文本单元
        let utterance = AVSpeechUtterance(string: words)
        // 设置发音为简体中文 （ 中国大陆 ）
    utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        // 设置朗读的语速
    utterance.rate = AVSpeechUtteranceMaximumSpeechRate * 0.55
        // 设置音高
    utterance.pitchMultiplier = 1
    var output: AVAudioFile?
    let soundPath = "\(path)/Library/Sounds"
    if #available(iOSApplicationExtension 13.0, *) {
        syn.write(utterance) { (buffer: AVAudioBuffer) in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                fatalError("unknown buffer type: \(buffer)")
            }
            if pcmBuffer.frameLength == 0 {
                // done
                let player = AVPlayer(url: URL(fileURLWithPath: "\(path)/uri.caf"))
                player.play()
            
            } else {
                // append buffer to file
                do {
                    if output == nil {
                        try  output = AVAudioFile(
                            forWriting: URL(fileURLWithPath: "\(path)/uri.caf"),
                            settings: pcmBuffer.format.settings,
                            commonFormat: .pcmFormatInt16,
                            interleaved: false)
                    }
                    try output?.write(from: pcmBuffer)
                } catch {
                    print(error.localizedDescription)
                }
             
            }
        }
    }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
