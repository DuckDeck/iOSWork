//
//  ShadowVideoPlayerView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import AVKit
import CoreMedia
import Foundation

class ShadowVideoPlayerView: UIView {
    // 目前这个方法还不支持缓存到本地，需要改进
    var oldConstriants: [NSLayoutConstraint]!
    var isPlaying = false
    var isFullScreen = false
    var isDraging = false
    private var url: URL!
    private let lblTitle = UILabel()
    private let btnVideoInfo = UIButton()
    private let vScInfo = UIScrollView()
    private let vErrorVideo = UIView()
    private let lblError = UILabel()
    private let vActivity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private weak var currentVC: UIViewController?
    static var count = 0
    var isCached = false
    var cachePath: String?
    var isFileExist = false
    var isFileCacheComplete = false
    var asset: AVURLAsset?
    var videoRes: CGSize?
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var config: [ShadowUIConfig: Any]!
    
    var player: ShadowPlayer!

    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var mode = VideoGravity.ResizeAspect // videoGravity设置屏幕填充模式，（只写）
    {
        didSet {
            switch mode {
            case .ResizeAspect:
                playerLayer.videoGravity = .resizeAspect
            case .Resize:
                playerLayer.videoGravity = .resize
            case .ResizeAspectFill:
                playerLayer.videoGravity = .resizeAspectFill
            }
        }
    }
    
    var title: String {
        set {
            lblTitle.text = newValue
        }
        get {
            return lblTitle.text ?? ""
        }
    }

    var vPlay: ShadowVideoPlayControlView!
    var vControl: ShadowVideoControlView!
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
    }

    // 与url初始化
    // 需要一个config来设置外观,目前还没有想好怎么设计
    
    convenience init(frame: CGRect, asset: AVURLAsset, config: [ShadowUIConfig: Any] = [ShadowUIConfig: Any]()) {
        self.init(frame: frame)
        self.config = config
        self.asset = asset
        player = ShadowPlayer(asset: asset, playerLayer: playerLayer)
        initView()
    }
    
    convenience init(frame: CGRect, url: URL, config: [ShadowUIConfig: Any] = [ShadowUIConfig: Any]()) {
        self.init(frame: frame)
        self.url = url
        self.config = config
        
        player = ShadowPlayer(url: url, playerLayer: playerLayer)
        
        initView()
    }
    
    func initView() {
        vControl = ShadowVideoControlView(frame: CGRect(), config: config)
        vPlay = ShadowVideoPlayControlView(frame: CGRect())
        
        player.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(notif:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notif:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        vActivity.startAnimating()
        // 添加标题
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.font = UIFont.systemFont(ofSize: 15)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.white
        lblTitle.numberOfLines = 2
        addSubview(lblTitle)
        
        // 添加播放和暂停按钮
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(ges:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        vPlay.backgroundColor = UIColor.clear
        vPlay.playBlock = { [weak self] (_: ShadowVideoPlayControlView, state: Bool) in
            ShadowVideoPlayerView.count = 0
            if state {
                self?.play()
            }
            else {
                self?.pause()
            }
        }
        vPlay.isHidden = true
        
        addSubview(vPlay)
        // 添加控制视图
        vControl.currentTime = "00:00"
        vControl.totalTime = "00:00"
        vControl.delegate = self
        vControl.backgroundColor = UIColor.clear
        if let ges = vPlay.btnImage.gestureRecognizers?.first {
            vControl.tapGesture?.require(toFail: ges)
        }
        addSubview(vControl)
        // 添加加载视图
        vActivity.hidesWhenStopped = true
        addSubview(vActivity)
        
        // 添加查看视频信息按键
        btnVideoInfo.setImage(#imageLiteral(resourceName: "info"), for: .normal)
        addSubview(btnVideoInfo)
        btnVideoInfo.addTarget(self, action: #selector(showVideoInfo), for: .touchUpInside)
        vScInfo.backgroundColor = UIColor(gray: 0.3, alpha: 0.5)
        addSubview(vScInfo)

        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(handleTapInfo(ges:)))
        vScInfo.addGestureRecognizer(tapInfo)
        vScInfo.isHidden = true
        let infos = getVideoInfo()
        var tmp: UIView!
        
        for info in infos {
            let lbl = UILabel()
            lbl.text = "\(info.0) : \(info.1)"
            lbl.textColor = UIColor.white
            lbl.font = UIFont.systemFont(ofSize: 14)
            vScInfo.addSubview(lbl)
            lbl.snp.makeConstraints { m in
                m.left.equalTo(15)
                if tmp == nil {
                    m.top.equalTo(10)
                }
                else {
                    m.top.equalTo(tmp.snp.bottom).offset(5)
                }
                m.width.equalTo(ScreenWidth - 30)
                m.height.equalTo(18)
            }
            tmp = lbl
        }
        if tmp != nil {
            tmp.snp.makeConstraints { m in
                m.bottom.equalTo(-10)
            }
        }
        
        vErrorVideo.isHidden = true
        vErrorVideo.backgroundColor = UIColor(gray: 0.3, alpha: 0.5)
        addSubview(vErrorVideo)
        let tapError = UITapGestureRecognizer(target: self, action: #selector(handleTapError(ges:)))
        vErrorVideo.addGestureRecognizer(tapError)

        let imgError = UIImageView(image: #imageLiteral(resourceName: "icon_error"))
        vErrorVideo.addSubview(imgError)
        lblError.textColor = UIColor.white
        lblError.font = UIFont.systemFont(ofSize: 18)
        lblError.textAlignment = .center
        lblError.numberOfLines = 0
        lblError.textAlignment = .left
        vErrorVideo.addSubview(lblError)
        imgError.snp.makeConstraints { m in
            m.center.equalTo(self)
        }
        
        lblError.snp.makeConstraints { m in
            m.centerX.equalTo(self)
            m.width.equalTo(ScreenWidth - 100)
            m.top.equalTo(imgError.snp.bottom).offset(4)
        }
    }
  
    override func layoutSubviews() {
        setupPlayerUI()
    }
    
    func replaceWithUrl(url: URL) {
        player.replaceWithUrl(url: url)
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayerUI() {
        if lblTitle.superview == nil {
            return
        }
        lblTitle.snp.makeConstraints { m in
            m.left.equalTo(0)
            m.top.equalTo(10)
            m.right.equalTo(-30)
        }
        // 添加点击事件
       
        vPlay.snp.makeConstraints { m in
            m.edges.equalTo(self)
        }
        vControl.snp.makeConstraints { m in
            m.left.right.bottom.equalTo(0)
            m.height.equalTo(44)
        }
        
        vActivity.snp.makeConstraints { m in
            m.width.height.equalTo(80)
            m.center.equalTo(self)
        }
        // 初始化时间
        
        btnVideoInfo.snp.makeConstraints { m in
            m.right.equalTo(-10)
            m.top.equalTo(10)
            m.width.height.equalTo(20)
        }
        vScInfo.snp.makeConstraints { m in
            m.edges.equalTo(self)
        }
        
        vErrorVideo.snp.makeConstraints { m in
            m.edges.equalTo(self)
        }
    }
    
    @objc func handleTapAction(ges: UIGestureRecognizer) {
        setSubViewsIsHide(isHide: false)
        ShadowVideoPlayerView.count = 0
    }
    
    @objc func showVideoInfo() {
        pause()
        vScInfo.isHidden = false
    }
    
    @objc func handleTapInfo(ges: UIGestureRecognizer) {
        vScInfo.isHidden = true
        play()
    }
    
    @objc func handleTapError(ges: UIGestureRecognizer) {
        vErrorVideo.isHidden = true
        // 先这样吧
    }
    
    func convertTime(second: Float) -> String {
        let d = Date(timeIntervalSince1970: TimeInterval(second))
        let format = DateFormatter()
        if second / 3600 >= 1 {
            format.dateFormat = "HH:mm:ss"
        }
        else {
            format.dateFormat = "mm:ss"
        }
        return format.string(from: d)
    }
    
    func showErrorInfo(info: String) {
        lblError.text = info
        vErrorVideo.isHidden = false
        vPlay.isHidden = true
        vActivity.stopAnimating()
    }
    
    func play() {
        if player != nil, player.playStatus != .Playing {
            player.play()
            vPlay.setState(state: true)
        }
    }
    
    func pause() {
        if player != nil, player.playStatus != .Paused {
            player.pause()
            vPlay.setState(state: false)
        }
    }
    
    func stop() {
        if player != nil {
            pause()
            vControl.value = 0
            vControl.currentTime = "00:00"
            vControl.totalTime = "00:00"
            player.stop()
            player = nil
            removeSubviews() // 有疑问
        }
    }
 
    func setSubViewsIsHide(isHide: Bool) {
        vControl.isHidden = isHide
        vPlay.isHidden = isHide
        lblTitle.isHidden = isHide
        btnVideoInfo.isHidden = isHide
    }
    
    func interfaceOrientation(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        // 有一些判断
        if orientation == .landscapeRight || orientation == .landscapeLeft {
        }
        else if orientation == .portrait {
        }
        else if orientation == .portraitUpsideDown {}
    }
    
    func rotate(orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            break // 默认为这种，不需要再处理
        case .landscapeLeft:
            UIView.animate(withDuration: 0.2) {
                self.vPlay.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.vControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.vControl.snp.updateConstraints { m in
                    m.width.equalTo(ScreenHeight)
                    m.height.equalTo(ScreenWidth)
                }
                self.layoutIfNeeded()
            }
            
        default:
            break
        }
    }

    func getVideoInfo() -> [(String, String)] {
        var info = [(String, String)]()
        if url != nil, url.absoluteString.starts(with: "file") {
            if let attr = try? FileManager.default.attributesOfItem(atPath: url.path) {
                let size = attr[FileAttributeKey.size] as! Int
                info.append(("文件大小", "\(size / 1000000)M"))
                info.append(("创建日期", "\(attr[FileAttributeKey.creationDate]!)"))
                info.append(("扩展名", url.pathExtension))
            }
        }
        
        let assert: AVURLAsset!
        if url != nil {
            assert = AVURLAsset(url: url)
        }
        else {
            assert = asset
        }
        
        if assert.tracks.count <= 0 {
            return info
        }
        
        for item in assert.tracks {
            let format = item.formatDescriptions.first! as! CMFormatDescription
            let type = CMFormatDescriptionGetMediaType(format)
            
            if type == kCMMediaType_Video {
                info.append(("类型", "视频"))
                guard let track = assert.tracks(withMediaType: .video).first else {
                    return info
                }
                
                let res = track.naturalSize
                videoRes = res
                info.append(("分辨率", "\(res.width) * \(res.height)"))
                info.append(("时长", "\(track.timeRange.duration.seconds)秒"))
                info.append(("帧率", "\(track.nominalFrameRate)帧每秒"))
                info.append(("码率", "\(track.estimatedDataRate / 8000000) M每秒"))
                
                let format = track.formatDescriptions
                for item in format where item is CMVideoFormatDescription {
                    let t = item as! CMVideoFormatDescription
                    let exts = t.extensions
                    
                    if let value = exts[CMFormatDescription.Extensions.Key.sampleDescriptionExtensionAtoms] as? CFPropertyList {
                        let vv = CMFormatDescription.Extensions.Value(value)
                        print(vv)
                        print(CFGetTypeID(value))
                        print(value.self)
                    }
                    if let format = exts[CMFormatDescription.Extensions.Key.formatName] as? CFTypeRef{
                        print(format)
                        print(format.self)
                    }
                }
            }
            else if type == kCMMediaType_Audio {
                info.append(("类型", "音频"))
                guard let track = assert.tracks(withMediaType: .audio).first else {
                    return info
                }
                info.append(("时长", "\(track.timeRange.duration.seconds)秒"))
                info.append(("帧率", "\(track.nominalFrameRate)帧每秒"))
                info.append(("码率", "\(track.estimatedDataRate / 8000000) M每秒"))
            }
        }
        
        return info
    }
    
    func clearCache() {}
    
    deinit {
        Log(message: "\(type(of: self))已经被回收了")
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

extension ShadowVideoPlayerView: UIGestureRecognizerDelegate, ShadowVideoControlViewDelegate {
    func controlView(view: ShadowVideoControlView, pointSliderLocationWithCurrentValue: Float) {
        ShadowVideoPlayerView.count = 0
        player.currentTime = Double(pointSliderLocationWithCurrentValue)
    }
    
    func controlView(view: ShadowVideoControlView, draggedPositionWithSlider: UISlider) {
        player.isPositioning = true
        isDraging = true
        ShadowVideoPlayerView.count = 0
        player.currentTime = Double(view.value)
    }
    
    func controlView(view: ShadowVideoControlView, draggedPositionExitWithSlider: UISlider) {
        isDraging = false
        player.isPositioning = false
    }
    
    func controlView(view: ShadowVideoControlView, withLargeButton: UIButton) {
        ShadowVideoPlayerView.count = 0
        let ori = UIDevice.current.orientation
        if ori == .portrait || ori == .portraitUpsideDown {
            interfaceOrientation(orientation: .landscapeRight)
        }
        else if ori == .landscapeLeft || ori == .landscapeRight {
            interfaceOrientation(orientation: .portrait)
        }
        else {
            interfaceOrientation(orientation: .landscapeRight)
        }
    }
 
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is ShadowVideoControlView {
            return false
        }
        return true
    }
}

extension ShadowVideoPlayerView {
    @objc func deviceOrientationDidChange(notif: Notification) {
        if currentVC == nil {
            currentVC = currentViewController()
            if currentVC == nil {
                return
            }
        }
        
        let _interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch _interfaceOrientation {
        case .landscapeLeft, .landscapeRight:
            isFullScreen = true
            if oldConstriants == nil {
                oldConstriants = currentVC!.view.constraints
            }
            vControl.updateConstraintsIfNeeded()
            // 删除UIView animate可以去除横竖屏切换过渡动画
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
                UIApplication.shared.keyWindow?.addSubview(self)
                self.snp.makeConstraints { m in
                    m.edges.equalTo(UIApplication.shared.keyWindow!)
                }
                self.layoutIfNeeded()
            }, completion: nil)
        case .portraitUpsideDown, .portrait:
            isFullScreen = false
            currentVC!.view.addSubview(self)
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
                if self.oldConstriants != nil {
                    self.currentVC!.view.addConstraints(self.oldConstriants)
                }
                self.layoutIfNeeded()
            }, completion: nil)
        case .unknown:
            print("UIInterfaceOrientationUnknown")
        }
    }

    @objc func willResignActive(notif: Notification) {
        if isPlaying {
            setSubViewsIsHide(isHide: false)
            ShadowVideoPlayerView.count = 0
            pause()
        }
    }
}

extension ShadowVideoPlayerView: ShadowPlayDelegate {
    func playStateChange(status: PlayStatus) {
        switch status {
        case .Stopped:
            break
        case .Playing:
            break
        case .Paused:
            setSubViewsIsHide(isHide: false)
            vPlay.setState(state: false)

        case .Finished:
            setSubViewsIsHide(isHide: false)
            ShadowVideoPlayerView.count = 0
            pause()
            vPlay.setState(state: false)
        }
    }
    
    func resouceStateChange(status: ResourceStatus) {
        switch status {
        case .Unknow:
            break
        case .Failed:
            break
        case .GetInfo:
            let info = player.mediaInfo!
            vControl.maxValue = Float(info.duration)
            vControl.minValue = 0
            vControl.totalTime = convertTime(second: Float(info.duration))

        case .ReadyToPlay:
            vActivity.stopAnimating()
            if player.isAutoPlay {
                if player.playStatus == .Playing {
                    vPlay.setState(state: true)
                }
            }
            else {
                vPlay.isHidden = false
            }
        case .Buffering:
            if !vActivity.isHidden {
                vActivity.startAnimating()
            }
        }
    }
    
    func bufferProcess(current: Float, duration: Float) {
        print(current)
        vControl.bufferValue = current / duration
    }
    
    func playProcess(current: Float, duration: Float) {
        print("播放到\(current)")
        vControl.value = current
        vControl.currentTime = convertTime(second: current)
        if ShadowVideoPlayerView.count >= 200 {
            setSubViewsIsHide(isHide: true)
        }
        else {
            setSubViewsIsHide(isHide: false)
        }
        ShadowVideoPlayerView.count += 1
    }
    
    func loadMediaFail(error: NSError) {
        DispatchQueue.main.async {
            self.showErrorInfo(info: error.localizedDescription)
        }
    }
}
