//
//  CatchGoodsEnum.swift
//  WeAblum
//
//  Created by Stan Hu on 2023/7/11.
//  Copyright © 2023 WeAblum. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


enum TransferGoodsPlatform :Int{ //
    case TaoBao = 0, Mall1688, TMall, KuaiShou, Douyin, PDD
    var homtUrl: String {
        switch self {
        case .TaoBao:
            return "https://myseller.taobao.com"
        case .Mall1688:
            return "https://work.1688.com/home/seller.htm"
        case .TMall:
            return "https://myseller.taobao.com/"
        case .KuaiShou:
            return "https://s.kwaixiaodian.com/zone/goods/list"
        case .Douyin:
            return "https://fxg.jinritemai.com/ffa/g/list"
        case .PDD:
            return "https://mms.pinduoduo.com/goods/goods_list"
        }
    }

    var icon: String {
        switch self {
        case .TaoBao:
            return "icon_capture_taobao"
        case .Mall1688:
            return "icon_capture_1688"
        case .TMall:
            return "icon_capture_tmall"
        case .KuaiShou:
            return "img_kuaishou_logo"
        case .Douyin:
            return "icon_capture_douyin"
        case .PDD:
            return "icon_capture_pdd"
        }
    }
    
    var platFormId: Int {
        switch self {
        case .TaoBao:
            return 2
        case .Mall1688:
            return 3
        case .TMall:
            return 1
        case .KuaiShou:
            return 5
        case .Douyin:
            return 4
        case .PDD:
            return 6
        }
    }
}

struct TransferShopInfo { // 搬家商店信息
    var platform: TransferGoodsPlatform = .TaoBao
    var shopId = ""
    var shopName = ""
    var shopIcon = ""
    var lastTransferGoodsId = ""
    var lastTransferTime = 0
    var arrGoods = [CatchedGoods]()
    var totalCount = 0
    var pageIndex = 0
    
    struct ShopInfo{
        var shopId = ""
        var shopName = ""
        var shopIcon = ""
        var platformId = 0
    }
    
    var shopInfo:ShopInfo{
        var tmp = ShopInfo()
        tmp.shopId = shopId
        tmp.shopName = shopName
        tmp.shopIcon = shopIcon
        tmp.platformId = platform.platFormId
        return tmp
    }
    
}

struct GoodsDetail: Codable {
    var resourceType = 0
    var description = ""
    var sortNumber = 1
    var mediaInfo :GoodsMediaInfo?
}

struct GoodsMediaInfo:Codable{
    var height: Int?
    var width: Int?
    var size: Int?
    var qualityType: Int?
}

struct PriceArr:Codable{
    var id = ""
    var priceType = "2"
    var value = 0.0
    var permission = 0
    var show = true
    var visible = true
}
// 抓取的商品
class CatchedGoods {
   
    var goodsId = ""
    var title = ""
    var imgs = [String]() // 商品图片
    var imgsInfo = [String: Dictionary<String, Int>]() //商品图片信息 key-value形式, 图片地址为key
    var detailImg: [String]? // 27张图的图片
    var detailImgInfo = [String: Dictionary<String, Int>]() //商品详情图片信息 key-value形式, 图片地址为key
    var detailVideo: [String:String]? // 27张图的视频
    var time = 0 // 创建时间
    var video = ""
    var videoInfo = [String: Dictionary<String, Int>]() //商品视频信息 key-value形式, 视频地址为key
    var videoCover = ""
    var price = ""          //没有规格只有一个价格
    var goodsNum = "" // 货号
    var detailTitle = ""
    var catchGoodsSku: CatchGoodsSku?
    var sourceUrl = ""
    var sourceType = 0 // 2 taobao,3 tmall,1 1688,10 other
    var tmpSku: [[CatchGoodsFormat]]?
    var index = 0
    
    var isUploading = false //是否正在上传商品
    var isCatched = false
    
    func clear(){
        imgs.removeAll()
        detailImg = nil
        detailVideo = nil
        catchGoodsSku = nil
        tmpSku = nil
        isCatched = false
        catchFail = nil
    }
    
    var catchFail: FailError?{
        didSet{
            if let c = catchFail,c.desc != "后继全部设置为失败"{
                Toast.showToast(msg:  c.desc)
            }
        }
    }
    
    var isGoodsNumValid: Bool {
        if goodsNum.count < 3 || goodsNum.count > 16 {
            return false
        }
        for s in goodsNum {
            if (s >= "\u{33}" && s <= "\u{126}") || (s >= "\u{4e00}" && s <= "\u{9fbb}") {
            } else {
                return false
            }
        }
        return true
    }

    enum FailError: Swift.Error {
        case webpageLoadFail(String)    //页面加载失败
        case htmlParseFail(error: Swift.Error)
        case qiniuConvertFail(String)
        case chanFail       // 先前有保存失败的商品，后续全部失败
        case saveGoodsFail(String)
        case saveFormatColorFail(String)
        case noVIP
        /// saveGoodsFailWithCode(失败的msg, 失败的errorCode)
        case saveGoodsFailWithCode(String, Int)
        var desc:String{
            switch self{
            case .webpageLoadFail(let url):
                return "\(url)加载失败"
            case .htmlParseFail(error: let err):
                return err.localizedDescription
            case .qiniuConvertFail(let err):
                return "七牛上传文件失败\(err)"
            case .saveGoodsFail(let err):
                return "保存商品失败\(err)"
            case .saveGoodsFailWithCode(let err, let errorCode):
                return "保存商品失败\(err)"
            case .saveFormatColorFail(let err):
                return "保存规格失败\(err)"
            case .chanFail:
                return "后继全部设置为失败"
            case .noVIP:
                return "用户非会员"
            }
        }
        
        var isVip:Bool{
            switch self{
            case .noVIP:
                return false
            default:
                return true
            }
        }
        
        var isOverCapacityFail: Bool {
            switch self {
            case .saveGoodsFailWithCode(let err, let errorCode):
                if errorCode == 2396015 {
                    return true
                }
                return false
            default:
                return false
            }
        }
        
    }
    
 
}

struct CatchGoodsSku {
    var colors: [CatchGoodsFormat]?
    var formats: [CatchGoodsFormat]?
    var skus: [CatchGoodsFormat]?
}

struct CatchGoodsFormat: Equatable, Hashable {
    var name = ""
    var stock: Int?
    var id = ""
    var img = ""
    var price = ""
    var originId = "" // 原始Id，用于淘宝等平板记录Id
    var type = 0 // 类型0 是 规格，1是颜色 2是混合
    var cname = ""
    var isPlanar: Bool { // 是否二维的
        return id.contains(";") || originId.contains(";")
    }
    
    var colorId: String? {
        if isPlanar {
            let t = id.split(separator: ";").first ?? ""
            return String(t)
        } else if type == 1 {
            return id
        }
        return nil
    }
    
    var formatId: String? {
        if isPlanar {
            let t = id.split(separator: ";").last ?? ""
            return String(t)
        } else if type == 0 {
            return id
        }
        return nil
    }
    
    var originColorId: String? {
        if isPlanar {
            let t = originId.split(separator: ";").first ?? ""
            return String(t)
        } else if type == 1 {
            return originId
        }
        return nil
    }
    
    var originFormatId: String? {
        if isPlanar {
            let t = originId.split(separator: ";").last ?? ""
            return String(t)
        } else if type == 0 {
            return originId
        }
        return nil
    }
    
    static func == (lhs: CatchGoodsFormat, rhs: CatchGoodsFormat)->Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
