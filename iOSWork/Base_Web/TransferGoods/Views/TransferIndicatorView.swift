//
//  TransferIndicatorView.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/26.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftyJSON
import GrandKit
import Lottie

class TransferIndicatorView: UIView {
    var totalNum = 0
    var resultMessage = ""
//    var alert: AlertView?
    var stage: CatchGoods.CatchStage = .Begin {
        didSet {
            switch stage {
            case .ShopInfo(let name, let icon, let platform):
                if vPrepareView.superview == nil {
                    vContent.addSubview(vPrepareView)
                    vPrepareView.snp.makeConstraints { make in
                        make.left.right.equalTo(0)
                        make.centerY.equalTo(vContent)
                    }
                }
                lblTitle.text = name
                if icon.isEmpty {
                    imgHead.image = UIImage(named: platform.icon)
                } else {
                    imgHead.setImg(url: icon)
                    imgPlatform.image = UIImage(named: platform.icon)
                }
                let str = NSMutableAttributedString(string: "准备计算搬家商品数量...")
                str.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 12)], range: NSMakeRange(0, str.string.count))
                str.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, str.string.count))
                lblTransferNum.attributedText = str
            case .GoodsNum(let num):
                if vPrepareView.superview == nil {
                    vContent.addSubview(vPrepareView)
                    vPrepareView.snp.makeConstraints { make in
                        make.left.right.equalTo(0)
                        make.centerY.equalTo(vContent)
                    }
                }
                let str = NSMutableAttributedString(string: "正在计算搬家商品数量 \(num)")
                str.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 12)], range: NSMakeRange(0, str.string.count))
                str.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, 10))
                str.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], range: NSMakeRange(11, str.string.count - 11))
                lblTransferNum.attributedText = str
            case .Ready(let num, let isOver):
                if vPrepareView.superview == nil {
                    vContent.addSubview(vPrepareView)
                    vPrepareView.snp.makeConstraints { make in
                        make.left.right.equalTo(0)
                        make.centerY.equalTo(vContent)
                    }
                }
                
                btnBeginTransder.setTitle("开始搬家", for: .normal)
                btnBeginTransder.isEnabled = true
                let str = NSMutableAttributedString(string: "本次计划搬家 \(num)个 商品")
                str.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 12)], range: NSMakeRange(0, str.string.count))
                str.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, str.string.count))
                str.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], range: NSMakeRange(7, "\(num)".count + 1))
                lblTransferNum.attributedText = str
                
                if isOver {
                    let msg = NSMutableAttributedString(string: "每次搬家只支持复制最新的3000个商品，如需搬家更多商品，请联系客服")
                    msg.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 14)], range: NSMakeRange(0, msg.string.count))
                    msg.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, msg.string.count))
//                    let alert = AlertView.alert(withTitle: "商品数量超过3000", message: msg)
//                    alert.add(AlertAction(title: "开始搬家", color: WGColor.main, font: UIFont.pingfangMedium(size: 16), handler: {
//                        self.beginTransfer()
//                    }))
//                    alert.add(AlertAction(title: "联系客服", color: Colors.color1E2028, font: UIFont.pingfangMedium(size: 16), handler: {
//                        self.customService()
//                    }))
//                    
//                    alert.add(AlertAction(title: "我知道了", color: Colors.color1E2028, font: UIFont.pingfangMedium(size: 16), handler: {}))
//                    alert.show()
                }
                
                totalNum = num
            case .Transfering(let index):
                let totalTime = (totalNum - index) * 8 + 60
                let timeFormat = TimeSpan.fromSeconds(Double(totalTime))
                let timeStr = timeFormat.format(format: "HH小时mm分钟").replacingOccurrences(of: "00小时", with: "").removePrefixZero
                let str = "\(index)/\(totalNum) (\(timeStr))"
                lblTransferNum.isHidden = true
                btnBeginTransder.isHidden = true
                
                if vPrepareView.superview == nil {
                    vContent.addSubview(vPrepareView)
                    vPrepareView.snp.makeConstraints { make in
                        make.left.right.equalTo(0)
                        make.centerY.equalTo(vContent)
                    }
                }
                
                if lblTransferProcess.superview == nil {
                    vPrepareView.addSubview(lblTransferProcess)
                    lblTransferProcess.snp.makeConstraints { make in
                        make.centerX.equalTo(vPrepareView)
                        make.top.equalTo(lblTitle.snp.bottom).offset(48)
                    }
                }
                lblTransferProcess.text = str
                if progressBar.superview == nil {
                    vPrepareView.addSubview(progressBar)
                    progressBar.snp.makeConstraints { make in
                        make.left.equalTo(48)
                        make.right.equalTo(-48)
                        make.top.equalTo(lblTransferProcess.snp.bottom).offset(12)
                        make.height.equalTo(12)
                    }
                }
                progressBar.setProgress(Float(index) / Float(totalNum), animated: true)
                
                if vTransferHint.superview == nil {
                    vPrepareView.addSubview(vTransferHint)
                    vTransferHint.snp.makeConstraints { make in
                        make.centerX.equalTo(vPrepareView)
                        make.top.equalTo(progressBar.snp.bottom).offset(12)
                    }
                }
                if btnStopTransder.superview == nil {
                    vPrepareView.addSubview(btnStopTransder)
                    btnStopTransder.snp.makeConstraints { make in
                        make.centerX.equalTo(vPrepareView)
                        make.top.equalTo(imgHead.snp.bottom).offset(313)
                        make.width.equalTo(160)
                        make.height.equalTo(40)
                        make.bottom.equalTo(-20)
                    }
                }
            case .Success:
//                alert?.removeFromSuperview()
                resultMessage = "\(totalNum)个商品搬家成功，0个失败\n以后登录相同账号，即可同步最新商品"
                imgHead.removeFromSuperview()
                lblTitle.superview?.removeFromSuperview()
                lblTransferProcess.removeFromSuperview()
                progressBar.removeFromSuperview()
                vTransferHint.removeFromSuperview()
                btnStopTransder.removeFromSuperview()
                vContent.addSubview(vSuccessView)
                vSuccessView.snp.makeConstraints { make in
                    make.center.equalTo(vContent)
                    make.left.right.equalTo(0)
                }
            case .Fail(let success, let fail):
//                alert?.removeFromSuperview()
                vPrepareView.isHidden = true
                vContent.addSubview(vFailView)
                vFailView.snp.makeConstraints { make in
                    make.center.equalTo(vContent)
                    make.left.right.equalTo(0)
                }
                let a = "\(success)个商品搬家成功，"
                let b = "\(fail)个失败"
                let attrStr = NSMutableAttributedString(string: a + b)
                attrStr.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 14)], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.yellow], range: NSMakeRange(a.count, "\(fail)".count))
                (vFailView.viewWithTag(20) as? UILabel)?.text = "搬家结束"
                (vFailView.viewWithTag(21) as? UILabel)?.attributedText = attrStr
                (vFailView.viewWithTag(22) as? UIButton)?.setTitle("重试(\(fail)个)", for: .normal)
                (vFailView.viewWithTag(23) as? UIButton)?.setTitle("联系客服", for: .normal)
            case .FailNoVip(let success, let fail):
                // 一键搬家过程中, 提示会员失败
//                alert?.removeFromSuperview()
                vPrepareView.isHidden = true
                vContent.addSubview(vCapacityOverFailView)
                vCapacityOverFailView.snp.remakeConstraints { make in
                    make.top.equalTo(48)
                    make.left.right.equalTo(0)
                    make.bottom.equalTo(-UIDevice.bottomAreaHeight)
                }
                let a = "\(success)个商品搬家成功，"
                let b = "\(fail)个失败"
                let attrStr = NSMutableAttributedString(string: a + b)
                attrStr.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 14)], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.yellow], range: NSMakeRange(a.count, "\(fail)".count))
                (vCapacityOverFailView.viewWithTag(20) as? UILabel)?.text = "会员已到期，搬家中断"
                (vCapacityOverFailView.viewWithTag(21) as? UILabel)?.attributedText = attrStr
                (vCapacityOverFailView.viewWithTag(22) as? UIButton)?.setTitle("重试(\(fail)个)", for: .normal)
                (vCapacityOverFailView.viewWithTag(23) as? UIButton)?.setTitle("联系客服", for: .normal)
            case .FailOverCapacity(let success, let fail):
                // 一键搬家过程中, 提示容量超出
//                alert?.removeFromSuperview()
                vPrepareView.isHidden = true
                vContent.addSubview(vCapacityOverFailView)
                vCapacityOverFailView.snp.remakeConstraints { make in
                    make.top.equalTo(48)
                    make.left.right.equalTo(0)
                    make.bottom.equalTo(vContent).offset(-UIDevice.bottomAreaHeight)
                }
                let a = "\(success)个商品搬家成功，"
                let b = "\(fail)个失败"
                let attrStr = NSMutableAttributedString(string: a + b)
                attrStr.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 14)], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSMakeRange(0, attrStr.string.count))
                attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.yellow], range: NSMakeRange(a.count, "\(fail)".count))
                (vCapacityOverFailView.viewWithTag(20) as? UILabel)?.text = "容量不足，搬家中断"
                (vCapacityOverFailView.viewWithTag(21) as? UILabel)?.attributedText = attrStr
                (vCapacityOverFailView.viewWithTag(22) as? UIButton)?.setTitle("重试(\(fail)个)", for: .normal)
                (vCapacityOverFailView.viewWithTag(23) as? UIButton)?.setTitle("联系客服", for: .normal)

            case .Cancel(let success, let fail):
//                alert?.removeFromSuperview()
                vPrepareView.isHidden = true
                vContent.addSubview(vFailView)
                vFailView.snp.makeConstraints { make in
                    make.center.equalTo(vContent)
                    make.left.right.equalTo(0)
                }
                (vFailView.viewWithTag(20) as? UILabel)?.text = "搬家被手动中止"
                (vFailView.viewWithTag(21) as? UILabel)?.text = "\(success)个商品搬家成功，\(fail)个未开始"
                (vFailView.viewWithTag(22) as? UIButton)?.setTitle("去查看", for: .normal)
                (vFailView.viewWithTag(23) as? UIButton)?.setTitle("批量编辑", for: .normal)
            case .noGoodsToTransfer:
                resultMessage = "店铺没有新增商品，相册已是最新版本"
                vPrepareView.removeFromSuperview()
                vContent.addSubview(vSuccessView)
                vSuccessView.snp.makeConstraints { make in
                    make.center.equalTo(vContent)
                    make.left.right.equalTo(0)
                }
                (vSuccessView.viewWithTag(30) as? UILabel)?.text = "无需更新"
                (vSuccessView.viewWithTag(33) as? UIButton)?.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            default:
                break
            }
        }
    }

//    var step = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(vContent)
        vContent.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(UIDevice.topAreaHeight)
        }
        
        let btnClose = UIButton()
        btnClose.setImage(UIImage(named: "close"), for: .normal)
        vContent.addSubview(btnClose)
        btnClose.touchInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        btnClose.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(24)
        }
        
   
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let btnDebug = UIButton()
        btnDebug.setTitle("关闭", for: .normal)
        btnDebug.setTitleColor(.black, for: .normal)
        btnDebug.touchInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        btnDebug.addTarget(self, action: #selector(debugClose), for: .touchUpInside)
        vContent.addSubview(btnDebug)
        btnDebug.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(btnClose)
            make.height.equalTo(24)
            make.width.equalTo(40)
        }
      
    }
 
    @objc func debugClose() {
        guard let vc = currentViewController() as? TransferGoodsViewController else { return }
        vc.hideIndicatorView()
    }
    
    @objc func close() {
        switch stage {
        case .Transfering:
            guard let vc = currentViewController() as? TransferGoodsViewController else { return }
            
            let attr = NSMutableAttributedString(string: "确认结束搬家吗？已复制的商品不会被删除")
            attr.addAttributes([NSAttributedString.Key.font: UIFont.pingfangRegular(size: 16)], range: NSMakeRange(0, attr.string.count))
            attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, attr.string.count))
//            let alert = AlertView.alert(withTitle: "", message: attr)
//            alert.add(AlertAction(title: "继续搬家", color: Colors.color1E2028, font: UIFont.pingfangMedium(size: 16), handler: {
//                vc.catchGoods.catchStatus = .resume
//                SensorsAnalyticsSDK.sharedInstance()?.track("srf_copycapturegoods", withProperties: ["srf_copycapturegoods_page": "结束搬家二次确认弹窗", "srf_copycapturegoods_button": "结束搬家二次确认继续搬家"])
//            }))
//            alert.add(AlertAction(title: "结束", color: Colors.colorFF3333, font: UIFont.pingfangMedium(size: 16), handler: {
//                self.cancelTransfer()
//                SensorsAnalyticsSDK.sharedInstance()?.track("srf_copycapturegoods", withProperties: ["srf_copycapturegoods_page": "结束搬家二次确认弹窗", "srf_copycapturegoods_button": "结束搬家二次确认结束"])
//            }))
//            alert.show()
//            vc.catchGoods.catchStatus = .pause
//            self.alert = alert
        default:
            stopTransfer()
        }
    }
    
    @objc func beginTransfer() {
//        HttpSender.get(APIManage.dynamicShare.svipInfo).completion { res in
//            if res.code != 0 || res.data == nil {
//                Toast.showError(txt: res.msg)
//                return
//            }
//            let js = JSON(res.data!)
//
//            let vipStatus = js["vipStatus"].intValue // 超级会员的vip状态， 0 非会员，1 会员，2 试用会员，3 会员过期，4 试用会员过期，5 超级会员，6 超级会员和会员过期  ，7 超级会员过期会员未过期
//            if vipStatus == 1 || vipStatus == 5 || vipStatus == 7 {
                guard let vc = currentViewController() as? TransferGoodsViewController else { return }
                vc.catchGoods.loadSingleGoods()
                

//            }
//        }
    }
    
    func cancelTransfer() {
        btnStopTransder.setTitle("正在取消...", for: .normal)
        guard let vc = currentViewController() as? TransferGoodsViewController else { return }
        vc.catchGoods.catchStatus = .cancel
    }
    
    func stopTransfer() {
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
        } completion: { _ in
            guard let vc = self.currentViewController() as? TransferGoodsViewController else { return }
            vc.logOut()
            vc.back(animate: false)
        }
    }
    
    @objc func gotoCheck(sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        if title == "去查看" {
            guard let vc = currentViewController() as? TransferGoodsViewController else { return }
            vc.logOut()

        } else {
            guard let vc = currentViewController() as? TransferGoodsViewController else { return }
            vFailView.removeFromSuperview()
            vCapacityOverFailView.removeFromSuperview()
            vPrepareView.isHidden = false
            progressBar.setProgress(0, animated: false)
            vc.catchGoods.retry()
        }
    }
    
    @objc func gotoBatchEdit(sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        if title == "批量编辑" {
            guard let vc = currentViewController() as? TransferGoodsViewController else { return }
            vc.logOut()
        }
    }
    
 
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var vContent: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    lazy var imgHead: UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = 40
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    lazy var imgPlatform: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    lazy var lblTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont.pingfangMedium(size: 18)
        v.textColor = .black
        return v
    }()
    
    
    lazy var btnBeginTransder: UIButton = {
        let v = UIButton()
//        v.setTitle("开始搬家", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        v.setBackgroundColor(color: .green, forState: .normal)
        v.setBackgroundColor(color: .green, forState: .disabled)
        v.setBackgroundColor(color: .green.withAlphaComponent(0.6), forState: .highlighted)
        v.layer.cornerRadius = 20
        v.isEnabled = false
        v.addTarget(self, action: #selector(beginTransfer), for: .touchUpInside)
        
        return v
    }()
    
    lazy var lblTransferNum: UILabel = {
        let v = UILabel()
        v.font = UIFont.pingfangRegular(size: 16)
        v.textColor = .gray
        return v
    }()
    
    lazy var lblTransferProcess: UILabel = {
        let v = UILabel()
        v.font = UIFont.pingfangRegular(size: 16)
        v.textColor = .gray
        return v
    }()
    
    lazy var progressBar: UIProgressView = {
        let v = UIProgressView()
        v.progressTintColor = .green
        v.backgroundColor = .gray
        v.layer.cornerRadius = 6
        v.clipsToBounds = true
        v.layer.sublayers?[1].cornerRadius = 6
        v.subviews[1].clipsToBounds = true
        return v
    }()
    
    lazy var vTransferHint: UIView = {
        let v = UIView()
        let img = UIImageView(image: UIImage(named: "icon_transfer_warning"))
        v.addSubview(img)
        img.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.height.width.equalTo(16)
        }
        let lbl = UILabel()
        lbl.text = "请防止手机熄屏，不要将此页面切换到后台"
        lbl.textColor = .yellow
        lbl.font = UIFont.pingfangRegular(size: 12)
        v.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalTo(img)
            make.left.equalTo(img.snp.right).offset(4)
        }
        return v
    }()
    
    lazy var btnStopTransder: UIButton = {
        let v = UIButton()
        v.setTitle("结束搬家", for: .normal)
        v.setTitleColor(.gray, for: .normal)
        v.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        v.setBackgroundColor(color: .lightText.withAlphaComponent(0.03), forState: .normal)
        v.setBackgroundColor(color: .lightText.withAlphaComponent(0.1), forState: .highlighted)
        v.layer.cornerRadius = 20
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        return v
    }()
    
    lazy var vPrepareView: UIView = {
        let v = UIView()
        v.addSubview(imgHead)
        imgHead.snp.makeConstraints { make in
            make.centerX.equalTo(v)
            make.top.equalTo(0)
            make.width.height.equalTo(80)
        }
        
        let vTitle = UIView()
        vTitle.addSubview(imgPlatform)
        imgPlatform.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.height.equalTo(28)
        }
        vTitle.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(imgPlatform.snp.right).offset(4)
            make.centerY.equalTo(vTitle)
            make.right.equalTo(0)
        }
        
        v.addSubview(vTitle)
        vTitle.snp.makeConstraints { make in
            make.centerX.equalTo(v)
            make.height.equalTo(28)
            make.top.equalTo(imgHead.snp.bottom).offset(16)
        }
        
        v.addSubview(btnBeginTransder)
        btnBeginTransder.snp.makeConstraints { make in
            make.centerX.equalTo(v)
            make.top.equalTo(vTitle.snp.bottom).offset(256)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        v.addSubview(lblTransferNum)
        lblTransferNum.snp.makeConstraints { make in
            make.top.equalTo(btnBeginTransder.snp.bottom).offset(16)
            make.centerX.equalTo(v)
            make.bottom.equalTo(0)
        }
        
        return v
    }()
    
    lazy var vSuccessView: UIView = {
        let v = UIView()
        let img = UIImageView(image: UIImage(named: "img_capture_success"))
        v.addSubview(img)
        img.snp.makeConstraints { make in
            make.centerX.equalTo(v)
            make.top.equalTo(0)
            make.width.height.equalTo(120)
        }
        let lbl1 = UILabel()
        lbl1.text = "搬家成功"
        lbl1.font = UIFont.pingfangMedium(size: 16)
        lbl1.tag = 30
        lbl1.textColor = .gray
        v.addSubview(lbl1)
        lbl1.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(16)
            make.centerX.equalTo(v)
        }
        let lbl2 = UILabel()
        lbl2.text = resultMessage
        lbl2.font = UIFont.pingfangRegular(size: 14)
        lbl2.numberOfLines = 0
        lbl2.tag = 31
        lbl2.textColor = .gray
        lbl2.textAlignment = .center
        v.addSubview(lbl2)
        lbl2.snp.makeConstraints { make in
            make.top.equalTo(lbl1.snp.bottom).offset(8)
            make.centerX.equalTo(v)
        }
        let btnCheckMore = UIButton()
        btnCheckMore.setTitle("去查看", for: .normal)
        btnCheckMore.setTitleColor(.white, for: .normal)
        btnCheckMore.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnCheckMore.setBackgroundColor(color: .green, forState: .normal)
        btnCheckMore.setBackgroundColor(color: .green.withAlphaComponent(0.6), forState: .highlighted)
        btnCheckMore.layer.cornerRadius = 20
        btnCheckMore.tag = 32
        btnCheckMore.addTarget(self, action: #selector(gotoCheck(sender:)), for: .touchUpInside)
        v.addSubview(btnCheckMore)
        btnCheckMore.snp.makeConstraints { make in
            make.top.equalTo(lbl2.snp.bottom).offset(194)
            make.centerX.equalTo(v)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        let btnEditBatch = UIButton()
        btnEditBatch.setTitle("批量编辑", for: .normal)
        btnEditBatch.setTitleColor(.gray, for: .normal)
        btnEditBatch.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnEditBatch.setBackgroundColor(color: .gray, forState: .normal)
        btnEditBatch.setBackgroundColor(color: .lightText.withAlphaComponent(0.1), forState: .highlighted)
        btnEditBatch.layer.cornerRadius = 20
        btnEditBatch.tag = 33
        btnEditBatch.addTarget(self, action: #selector(gotoBatchEdit(sender:)), for: .touchUpInside)
        v.addSubview(btnEditBatch)
        btnEditBatch.snp.makeConstraints { make in
            make.top.equalTo(btnCheckMore.snp.bottom).offset(16)
            make.centerX.equalTo(v)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalTo(0)
        }
        return v
    }()
    
    lazy var vFailView: UIView = {
        let v = UIView()
        let img = UIImageView(image: UIImage(named: "img_capture_fail"))
        v.addSubview(img)
        img.snp.makeConstraints { make in
            make.centerX.equalTo(v)
            make.top.equalTo(0)
            make.width.equalTo(171)
            make.height.equalTo(99)
        }
        let lbl1 = UILabel()
        lbl1.tag = 20
        lbl1.font = UIFont.pingfangMedium(size: 16)
        lbl1.textColor = .gray
        v.addSubview(lbl1)
        lbl1.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(16)
            make.centerX.equalTo(v)
        }
        let lbl2 = UILabel()
        lbl2.tag = 21
        lbl2.font = UIFont.pingfangRegular(size: 14)
        lbl2.numberOfLines = 0
        lbl2.textColor = .gray
        lbl2.textAlignment = .center
        v.addSubview(lbl2)
        lbl2.snp.makeConstraints { make in
            make.top.equalTo(lbl1.snp.bottom).offset(8)
            make.centerX.equalTo(v)
        }
        let btnCheckMore = UIButton()
        btnCheckMore.tag = 22
        btnCheckMore.setTitleColor(.white, for: .normal)
        btnCheckMore.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnCheckMore.setBackgroundColor(color: .green, forState: .normal)
        btnCheckMore.setBackgroundColor(color: .green.withAlphaComponent(0.6), forState: .highlighted)
        btnCheckMore.layer.cornerRadius = 20
        btnCheckMore.addTarget(self, action: #selector(gotoCheck(sender:)), for: .touchUpInside)
        v.addSubview(btnCheckMore)
        btnCheckMore.snp.makeConstraints { make in
            make.top.equalTo(lbl2.snp.bottom).offset(194)
            make.centerX.equalTo(v)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        let btnEditBatch = UIButton()
        btnEditBatch.tag = 23
        btnEditBatch.setTitleColor(.gray, for: .normal)
        btnEditBatch.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnEditBatch.setBackgroundColor(color: .gray, forState: .normal)
        btnEditBatch.setBackgroundColor(color: .lightText.withAlphaComponent(0.1), forState: .highlighted)
        btnEditBatch.layer.cornerRadius = 20
        btnEditBatch.addTarget(self, action: #selector(gotoBatchEdit(sender:)), for: .touchUpInside)
        v.addSubview(btnEditBatch)
        btnEditBatch.snp.makeConstraints { make in
            make.top.equalTo(btnCheckMore.snp.bottom).offset(16)
            make.centerX.equalTo(v)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalTo(0)
        }
        return v
    }()
    /// 容量超出, 导致中断的视图
    lazy var vCapacityOverFailView: UIView = {
        
        let v = UIView()
        
        // 顶部 3/5 区域
        let topView = UIView()
        v.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalTo(v)
            make.height.equalTo(v.snp_height).multipliedBy(0.6)
        }
        // 顶部区域视图绘制
        let topCenterView = UIView()
        topView.addSubview(topCenterView)
        topCenterView.snp.makeConstraints { make in
            make.left.right.equalTo(topView)
            make.centerY.equalTo(topView)
            make.height.equalTo(186)
        }
        
        let imgV = UIImageView(image: UIImage(named: "img_capture_fail"))
        topCenterView.addSubview(imgV)
        imgV.snp.makeConstraints { make in
            make.top.equalTo(topCenterView).offset(13)
            make.width.equalTo(171)
            make.height.equalTo(99)
            make.centerX.equalTo(topCenterView)
        }
        
        let lbl1 = UILabel()
        lbl1.tag = 20
        lbl1.font = UIFont.pingfangMedium(size: 16)
        lbl1.textColor = .gray
        topCenterView.addSubview(lbl1)
        lbl1.snp.makeConstraints { make in
            make.top.equalTo(imgV.snp.bottom).offset(24)
            make.centerX.equalTo(v)
        }
        
        let lbl2 = UILabel()
        lbl2.tag = 21
        lbl2.font = UIFont.pingfangRegular(size: 14)
        lbl2.numberOfLines = 0
        lbl2.textColor = .gray
        lbl2.textAlignment = .center
        topCenterView.addSubview(lbl2)
        lbl2.snp.makeConstraints { make in
            make.top.equalTo(lbl1.snp.bottom).offset(8)
            make.centerX.equalTo(v)
        }
        
        // 底部 2/5 区域
        let bottomView = UIView()
        v.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(v)
            make.height.equalTo(v.snp_height).multipliedBy(0.4)
        }
        
        // 顶部区域视图绘制
        let bottomCenterView = UIView()
        bottomView.addSubview(bottomCenterView)
        bottomCenterView.snp.makeConstraints { make in
            make.left.right.equalTo(bottomView)
            make.centerY.equalTo(bottomView)
            make.height.equalTo(96)
        }
        
        let btnCheckMore = UIButton()
        btnCheckMore.tag = 22
        btnCheckMore.setTitleColor(.white, for: .normal)
        btnCheckMore.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnCheckMore.setBackgroundColor(color: .green, forState: .normal)
        btnCheckMore.setBackgroundColor(color: .green.withAlphaComponent(0.6), forState: .highlighted)
        btnCheckMore.layer.cornerRadius = 20
        btnCheckMore.addTarget(self, action: #selector(gotoCheck(sender:)), for: .touchUpInside)
        bottomCenterView.addSubview(btnCheckMore)
        btnCheckMore.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalTo(bottomCenterView)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        let btnEditBatch = UIButton()
        btnEditBatch.tag = 23
        btnEditBatch.setTitleColor(.gray, for: .normal)
        btnEditBatch.titleLabel?.font = UIFont.pingfangMedium(size: 14)
        btnEditBatch.setBackgroundColor(color: .gray, forState: .normal)
        btnEditBatch.setBackgroundColor(color: .lightText.withAlphaComponent(0.1), forState: .highlighted)
        btnEditBatch.layer.cornerRadius = 20
        btnEditBatch.addTarget(self, action: #selector(gotoBatchEdit(sender:)), for: .touchUpInside)
        bottomCenterView.addSubview(btnEditBatch)
        btnEditBatch.snp.makeConstraints { make in
            make.top.equalTo(btnCheckMore.snp.bottom).offset(16)
            make.centerX.equalTo(bottomCenterView)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        return v
    }()
}
