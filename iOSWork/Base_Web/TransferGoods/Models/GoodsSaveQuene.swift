//
//  GoodsSaveQuene.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/8/10.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

protocol SaveGoodsDelegate: NSObjectProtocol {
    func getShopInfo() -> TransferShopInfo.ShopInfo
    func finishSave(index: Int)
    func stop()
    func fail(err: CatchedGoods.FailError)
}

class GoodsSaveQueue: Operation {
    weak var delegate: SaveGoodsDelegate?
    var goods: CatchedGoods!
    var index: Int!
    var imageUploadQuene = SKOperationQueue(qualityOfService: .default, maxConcurrentOperationCount: 4, underlyingQueue: nil, name: nil, startSuspended: false)
    var observation: NSKeyValueObservation?
    private var _finished: Bool = false
    var request: DataRequest?
    override private(set) var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    private var _isCancelled: Bool = false

    override private(set) var isCancelled: Bool {
        get { return _isCancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _isCancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    convenience init(goods: CatchedGoods, index: Int, delete: SaveGoodsDelegate) {
        self.init()
        self.goods = goods
        self.index = index
        self.delegate = delete
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        print("搬家---------开始商品搬家队列")
        upload()
    }
    
    func upload() {
        if goods.imgs.count > 9 {
            let tmp = goods.imgs[9..<goods.imgs.count]
            goods.imgs = Array(goods.imgs[0..<9])
            goods.detailImg?.insert(contentsOf: tmp, at: 0)
        }
        
        let group = DispatchGroup()
        var imgUpload = [String].init(repeating: "", count: goods.imgs.count)
        // 上传图片
        for item in goods.imgs.enumerated() {
            let imgQuene = ImageUploadQuene(url: item.element, isVideo: false, index: item.offset) { _, index, url, mediaInfoDict, error in
                if url != nil {
                    imgUpload[index] = url!
                    if mediaInfoDict.count > 0 {
                        self.goods.imgsInfo[url!] = mediaInfoDict
                    }
                } else if error?.code == -55 { //该图片有问题，过滤
                    
                } else {
                    self.goods.catchFail = .qiniuConvertFail("搬家--图片上传七牛云失败，\(error?.localizedDescription ?? "")")
                }
            }
            imageUploadQuene.addOperation(imgQuene)
        }
        // 上传视频
        if !goods.video.isEmpty {
            let imgQuene = ImageUploadQuene(url: goods.video, isVideo: true, index: 0) { _, _, url, mediaInfoDict, error in
                if url != nil {
                    self.goods.video = url!
                    if mediaInfoDict.count > 0 {
                        self.goods.videoInfo[url!] = mediaInfoDict
                    }
                } else {
                    self.goods.video = ""
                    self.goods.catchFail = .qiniuConvertFail("搬家--视频上传七牛云失败，\(error?.localizedDescription ?? "")")
                }
            }
            imageUploadQuene.addOperation(imgQuene)
        }
        // 上传视频封面
        if !goods.videoCover.isEmpty {
            let imgQuene = ImageUploadQuene(url: goods.videoCover, isVideo: false, index: 0) { _, _, url, _, _ in
                if url != nil {
                    self.goods.videoCover = url!
                } else {
                    self.goods.videoCover = ""
                }
            }
            imageUploadQuene.addOperation(imgQuene)
        }
        // 上传图片详情
        var tmpImgs: [String]?
        if let detailImgs = goods.detailImg, detailImgs.count > 0 {
            tmpImgs = [String].init(repeating: "", count: detailImgs.prefix(27).count)
            for item in detailImgs.prefix(27).enumerated() {
                let imgQuene = ImageUploadQuene(url: item.element, isVideo: false, index: item.offset) { _, index, url, mediaInfoDict, error in
                    if url != nil {
                        tmpImgs?[index] = url!
                        if mediaInfoDict.count > 0 {
                            self.goods.detailImgInfo[url!] = mediaInfoDict
                        }
                    } else if error?.code == -55 { //该图片有问题，过滤
                        
                    } else {
                        self.goods.catchFail = .qiniuConvertFail("搬家--图片上传七牛云失败，\(error?.localizedDescription ?? "")")
                    }
                }
                imageUploadQuene.addOperation(imgQuene)
            }
        }
        
        // 上传SKU图片
        var skuImg = [String: String]()
        if let skus = goods.catchGoodsSku?.skus {
            for item in skus where !item.img.isEmpty {
                skuImg[item.img] = ""
            }
            for item in skuImg {
                let imgQuene = ImageUploadQuene(url: item.key, isVideo: false, index: 0) { originUrl, _, url, _, error in
                    if url != nil {
                        skuImg[originUrl] = url!
                    } else {
                        self.goods.catchFail = .qiniuConvertFail("搬家--视频上传七牛云失败，\(error?.localizedDescription ?? "")")
                    }
                }
                imageUploadQuene.addOperation(imgQuene)
            }
        }
        
        observation = imageUploadQuene.observe(\.operationCount, options: [.new], changeHandler: { _, change in
            print("下载数据变更\(change.newValue)")
            if change.newValue! == 0 {
                if self.goods.catchFail != nil {
                    self.goods.isUploading = false
                    self.delegate?.fail(err: self.goods.catchFail!)
                    self.isFinished = true
                    return
                }
                imgUpload = imgUpload.filter({ s in // 过滤空的
                    return !s.isEmpty
                })
                self.goods.imgs = imgUpload
                tmpImgs = tmpImgs?.filter({ s in // 过滤空的
                    return !s.isEmpty
                })
                if let t = tmpImgs, t.count > 0 {
                    self.goods.detailImg = t
                }
                
                let count = self.goods.catchGoodsSku?.skus?.count ?? 0
                if count > 0 {
                    for i in 0..<count {
                        let newUrl = skuImg[self.goods.catchGoodsSku!.skus![i].img] ?? ""
                        self.goods.catchGoodsSku?.skus?[i].img = newUrl
                    }
                }
                self.save()
            }
        })
    }
    
    func save() {
        var para = [String: Any]()
        
        para["title"] = goods.title
        para["main_imgs"] = goods.imgs.jsonString ?? ""
        if let count = goods.detailImg?.count, count > 0 {
            var arrDetail = [GoodsDetail]()
            if !goods.detailTitle.isEmpty {
                var detail = GoodsDetail()
                detail.resourceType = 3
                detail.description = goods.detailTitle
                arrDetail.append(detail)
            }
            for i in 0..<count {
                var detail = GoodsDetail()
                detail.resourceType = 1
                detail.description = goods.detailImg![i]
                detail.sortNumber = i
                if goods.detailImgInfo.count > 0 {
                    if let detailImgInfoKey = goods.detailImg?[i] {
                        let detailImgInfoDict = goods.detailImgInfo[detailImgInfoKey]
                        detail.mediaInfo = GoodsMediaInfo()
                        detail.mediaInfo?.width = detailImgInfoDict?["height"]
                        detail.mediaInfo?.height = detailImgInfoDict?["height"]
                        detail.mediaInfo?.size = detailImgInfoDict?["size"]
                        detail.mediaInfo?.qualityType = detailImgInfoDict?["qualityType"]
                    }
                }
                arrDetail.append(detail)
            }
            para["commodityDetailList"] = arrDetail.jsonString ?? ""
        }
       
    
      
    }
    
    override func cancel() {
        goods.catchFail = .chanFail
        if isExecuting {
            request?.cancel()
            isFinished = true
        } else {
            isCancelled = true
        }
    }
}
