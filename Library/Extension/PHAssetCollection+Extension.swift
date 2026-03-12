//
//  PHAssetCollection.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
import Photos

enum AlbumError: LocalizedError, Equatable {
    /// 相册写入权限被拒绝/受限
    case permissionDenied
    /// 相册创建操作失败（performChangesAndWait 抛出异常）
    case createFailed(String)
    /// 创建相册后获取不到占位符（placeholder 为 nil）
    case placeholderNotFound
    /// 创建相册后无法获取新相册实例
    case collectionFetchFailed
    /// 未知错误
    case unknown(String)
    
    // 实现 LocalizedError，返回用户可读的错误描述
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "相册写入权限被拒绝，请在设置中开启"
        case .createFailed(let msg):
            return "创建相册失败：\(msg)"
        case .placeholderNotFound:
            return "创建相册后未获取到占位符，无法定位新相册"
        case .collectionFetchFailed:
            return "创建相册后，无法获取新相册实例"
        case .unknown(let msg):
            return "未知错误：\(msg)"
        }
    }
}

extension PHAssetCollection {
    /// 查找/创建指定名称的相册（返回 Result 类型，带精准错误信息）
    /// - Parameter name: 相册名（nil/空则返回 .failure(.emptyAlbumName)）
    /// - Returns: Result<PHAssetCollection, CustomAlbumError>
    @discardableResult
    
    static func named(_ name: String) -> Result<PHAssetCollection, AlbumError> {
        // 1. 校验相册名：空则返回对应错误
            
        // 2. 检查相册写入权限（必须前置，否则创建失败）
        let permissionStatus: PHAuthorizationStatus
        if #available(iOS 11.0, *) {
            permissionStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            permissionStatus = PHPhotoLibrary.authorizationStatus()
        }
                
        guard permissionStatus == .authorized else {
            return .failure(.permissionDenied)
        }
                
        // 3. 查找已有相册
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                
        if let existingCollection = collectionFetchResult.firstObject {
            return .success(existingCollection)
        }
                
        // 4. 无则同步创建新相册（捕获异常）
        var collectionPlaceholder: PHObjectPlaceholder?
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                collectionPlaceholder = createRequest.placeholderForCreatedAssetCollection
            }
        } catch {
            return .failure(.createFailed(error.localizedDescription))
        }
                
        // 5. 校验占位符是否存在
        guard let placeholder = collectionPlaceholder else {
            return .failure(.placeholderNotFound)
        }
                
        // 6. 获取刚创建的相册实例
        let newCollectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
        guard let newCollection = newCollectionFetchResult.firstObject else {
            return .failure(.collectionFetchFailed)
        }
                
        // 7. 成功返回新相册
        return .success(newCollection)
    }
            
    // 【可选】异步版本（推荐，避免主线程阻塞）
    /// 异步查找/创建指定名称的相册（不阻塞主线程）
    /// - Parameters:
    ///   - name: 相册名
    ///   - completion: 回调（主线程），返回 Result<PHAssetCollection, CustomAlbumError>
    static func namedAsync(_ name: String, completion: @escaping (Result<PHAssetCollection, AlbumError>) -> Void) {
        DispatchQueue.global().async {
            let result = self.named(name)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    var photoAssets: [PHAsset] {
        var tmp = [PHAsset]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        result.enumerateObjects { asset, _, _ in
            tmp.append(asset)
        }
        return tmp
    }
    
    func clearPhotos(completed: @escaping ((_ finish: Bool, _ error: Swift.Error?) -> Void)) {
//        let count = 10
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        options.includeHiddenAssets = true
//        options.includeAllBurstAssets = true
//        options.includeAssetSourceTypes = [.typeCloudShared,
//                                           .typeiTunesSynced,
//                                           .typeUserLibrary]
//        options.fetchLimit = count
        
//        let fetchRequest = PHAsset.fetchAssets(with: options)
        
        PHPhotoLibrary.shared().performChanges({
//            var assets = [PHAsset]()

//            fetchRequest.enumerateObjects({ (asset, _, _) in
//                let canDelete = asset.canPerform(PHAssetEditOperation.delete)
//                if canDelete {
//                    assets.append(asset)
//                }
//            })

            PHAssetChangeRequest.deleteAssets(self.photoAssets as NSArray)
        }) { finished, error in
            DispatchQueue.main.async {
                completed(finished, error)
            }
        }
        
//        PHPhotoLibrary.shared().performChanges({
//            guard let request = PHAssetCollectionChangeRequest(for: self) else {
//                return
//            }
//            request.removeAssets(self.photoAssets as NSArray)
//        }) { (result, error) in
//            kbLog.info("清理图片结果\(result)")
//            if error != nil{
//                kbLog.info(error!.localizedDescription)
//            }
//        }
    }
    
    var videoCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
