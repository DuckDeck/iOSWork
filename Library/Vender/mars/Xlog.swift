//
//  Xlog.swift
//  WeAblum
//
//  Created by Stan Hu on 2024/7/18.
//  Copyright © 2024 WeAblum. All rights reserved.
//

import Foundation
import SSZipArchive
import SwiftyJSON

func LOG_D(tag: String, content: String, file: String = #file, method: String = #function, line: Int = #line) {
    LogHelper.log(with: TLogLevel(rawValue: 1), moduleName: tag, fileName: file, lineNumber: Int32(line), funcName: method, message: content)
}

func LOG_I(tag: String, content: String, file: String = #file, method: String = #function, line: Int = #line) {
    LogHelper.log(with: TLogLevel(rawValue: 2), moduleName: tag, fileName: file, lineNumber: Int32(line), funcName: method, message: content)
}

func LOG_W(tag: String, content: String, file: String = #file, method: String = #function, line: Int = #line) {
    LogHelper.log(with: TLogLevel(rawValue: 3), moduleName: tag, fileName: file, lineNumber: Int32(line), funcName: method, message: content)
}

func LOG_E(tag: String, content: String, file: String = #file, method: String = #function, line: Int = #line) {
    LogHelper.log(with: TLogLevel(rawValue: 4), moduleName: tag, fileName: file, lineNumber: Int32(line), funcName: method, message: content)
}

@objcMembers class LogModule: NSObject {
    static let login = "登录"
    static let NetRequest = "网络请求"
    static let uploadImage = "上传图片"
    static let uploadVideo = "上传视频"
    static let downloadImage = "下载图片"
    static let downloadVideo = "下载视频"
    static let share = "分享"
    static let H5Bridge = "H5桥接"
    static let editGoods = "编辑商品"
    static let search = "搜索"
    static let homePage = "动态首页"
    static let homeAlbum = "个人主页"
    static let webview = "webview"
    static let dateStore = "数据存储"
    static let exception = "异常"
    static let deviceInfo = "设备信息"
    static let viewInfo = "视图信息"
    static let connectLog = "关联日志"
    static let live = "直播"
    static let other = "其他"
}

class XLog: NSObject {
    
    func writeDeviceInfo() {
        var infos = ["client_type": "ios", "platform": "app", "version": appVersion,
                     "internalVersion": UIDevice.internalVersion(),
                     "channel": UserData.shareInstance().getValueInGroup(withKey: "channel_config_key") ?? "enterprise",
                     "iOSVersion": UIDevice.current.systemVersion,
                     "domain_Name": CommonUtils.getBaseURL() ?? "https://www.wsxcme.com",
                     "userPhone_Name": UIDevice.current.name,
                     "device_Name": UIDevice.current.systemName,
                     "phone_Model": UIDevice.current.typeString,
                     "device_UUID": UIDevice.current.identifierForVendor?.uuidString ?? "无",
                     "currentIP": Store.GetString(key: "currentIP"),
                     "网络类型": UIDevice.networkInfo]
        if let token = WGAccountMgr.shared.curUser?.token, !token.isEmpty {
            infos["token"] = token
        }
        LOG_I(tag: "设备信息", content: "\(infos)")
    }

    func createLogZipFile() -> String {
        writeDeviceInfo()
        
        LogUtil.flushLog() // 把日志全部写进去
        
        let tmpPath = NSTemporaryDirectory()
        var logPaths = [String]()
        if let xLog = Self.xLogFiles {
            logPaths.append(contentsOf: xLog)
        }
        if let cLog = Self.cLogPath {
            logPaths.append(cLog)
        }
        if let log = Self.keyboardLogPath {
            logPaths.append(contentsOf: log)
        }
        if let log = Self.qiniuLogPath {
            logPaths.append(contentsOf: log)
        }
        if let log = Self.liveLogPath {
            logPaths.append(contentsOf: log)
        }

        if let previousLogFiles = try? FileManager.default.contentsOfDirectory(atPath: tmpPath).filter({ $0.hasPrefix("logs") && $0.hasSuffix(".zip") }).map({ tmpPath.appending($0) }) { // 移除原先的日志文件
            previousLogFiles.forEach { try? FileManager.default.removeItem(atPath: $0) }
        }

        let zipPath = tmpPath.appending("logs_\(DateTime.now.format("MM-dd_HH-mm")).zip")
        let res = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: logPaths)
        if res {
            return zipPath
        } else {
            LOG_E(tag: "异常", content: "SSZipArchive压缩日志文件失败")
        }

        return ""
    }

   @objc func updateLog() {
        // 如果存在1分钟内的日志，直接上传
        let tmpPath = NSTemporaryDirectory()
        var zipPath = tmpPath.appending("logs_\(DateTime.now.format("MM-dd_HH-mm")).zip")
        if !FileManager.default.fileExists(atPath: zipPath) {
            zipPath = createLogZipFile()
        }
        if zipPath.isEmpty {
            return
        }
        var token = WGAccountMgr.shared.token
        if let dict = CommonUtils.jwtDecode(withJwtString: token) as? [String: Any] {
            token = dict["token"] as? String ?? token
        }
        let dateStr = DateTime.now.format("yyyy-MM-dd_HH:mm:ss")
        let fileName = "\(token)_\(dateStr)"
        Toast.showLoading()
        HttpSender.post(APIManage.dynamicShare.QiNiuLogToken).completion { res in
            guard let data = res.data, res.code == 0 else {
                Toast.showError(txt: "获取七牛token失败")
                Toast.dismiss()
                return
            }
            let js = JSON(data)
            let token = js["sessionToken"].stringValue
            let path = js["folder"].stringValue
            let fullKeyPath = path.isEmpty ? fileName : "\(path)/\(fileName)"
            QNUploadManager.share().putFile(zipPath, key: fullKeyPath, token: token, complete: { info, _, _ in
                Toast.dismiss()
                guard info?.statusCode == 200 else {
                    Toast.showError(txt: "上传日志失败")
                    return
                }
                Toast.showToast(msg: "日志上传成功")
            }, option: QNUploadOption())
        }
    }

   @objc func shareLog() {
        // 如果存在1分钟内的日志，直接上传
        let tmpPath = NSTemporaryDirectory()
        var zipPath = tmpPath.appending("logs_\(DateTime.now.format("MM-dd_HH-mm")).zip")
        if !FileManager.default.fileExists(atPath: zipPath) {
            zipPath = createLogZipFile()
        }
        if zipPath.isEmpty {
            return
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: zipPath)) else { return }
        let items = [data, URL(fileURLWithPath: zipPath)] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        let vc = CommonUtils.getTopViewController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = vc?.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        activityVC.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
        UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { _, _, _, _ in
        }
    }

    /// xlog 目录
    @objc static var xLogFiles: [String]? {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        if path.isEmpty {
            LOG_I(tag: "异常", content: "获取xlog路径为空")
            return nil
        }
        path = path.appending("/xlog")
        do {
            return try FileManager.default.contentsOfDirectory(atPath: path).map { "\(path)/\($0)" }
        } catch {
            LOG_E(tag: "异常", content: "获取xlog文件异常\(error.localizedDescription)")
            return nil
        }
    }

    @objc static var cLogPath: String? {
        let path = (DDLog.allLoggers.first as? DDFileLogger)?.logFileManager.sortedLogFilePaths.first ?? ""
        if path.isEmpty {
            LOG_I(tag: "异常", content: "获取xlog路径为空")
            return nil
        }
        return path
    }

    @objc static var keyboardLogPath: [String]? {
        return KeyboardEnv.logPath
    }

    @objc static var qiniuLogPath: [String]? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        if path.isEmpty {
            LOG_I(tag: "异常", content: "获取七牛日志路径为空")
            return nil
        }
        path = path.appending("/Pili-ShortVideo/Logs")
        do {
            return try FileManager.default.contentsOfDirectory(atPath: path).map { "\(path)/\($0)" }
        } catch {
            LOG_E(tag: "异常", content: "获取七牛日志文件异常\(error.localizedDescription)")
            return nil
        }
    }

    @objc static var liveLogPath: [String]? {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        if path.isEmpty {
            LOG_I(tag: "异常", content: "获取直播日志路径为空")
            return nil
        }
        path = path.appending("/log")
        do {
            return try FileManager.default.contentsOfDirectory(atPath: path).map { "\(path)/\($0)" }
        } catch {
            LOG_E(tag: "异常", content: "获取直播日志文件异常\(error.localizedDescription)")
            return nil
        }
    }
}
