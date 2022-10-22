//
//  PHAssetCollection.swift
//  iOSWork
//
//  Created by ShadowEdge on 2022/10/22.
//

import Foundation
import Photos
extension PHAssetCollection{
    
    @discardableResult
    static func initWith(title:String)->(PHAssetCollection?,Error?){
        let colles = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var target:PHAssetCollection? = nil
        colles.enumerateObjects { col, index, p in
            if col.localizedTitle == title{
                target = col
            }
        }
        
        if target == nil{
            var idx = ""
            do{
                try PHPhotoLibrary.shared().performChangesAndWait {
                    idx = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title).placeholderForCreatedAssetCollection.localIdentifier
                }
                target = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [idx], options: nil).firstObject
                if target != nil{
                    return (target!,nil)
                }
                return (nil,NSError(domain: "创建\(title)相册失败", code: -1000))
            } catch {
                return (nil,error)
            }
            
            
        } else {
            return (target!,nil)
        }
    }
    
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    var photoAssets:[PHAsset]{
        var tmp = [PHAsset]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        result.enumerateObjects { asset, idx, _ in
            tmp.append(asset)
        }
        return tmp
    }
    
    func clearPhotos(completed:@escaping ((_ finish:Bool,_ error:Swift.Error?)->Void)){
        
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
        }) { (finished, error) in
            DispatchQueue.main.async {
                completed(finished,error)
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
