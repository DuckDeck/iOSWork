//
//  KuiklyDynamic.h
//  KuiklyDynamic
//
//  Created by mellow on 2025/8/6.
//

#import <Foundation/Foundation.h>
#import <OpenKuiklyIOSRender/KuiklyDynamicLog.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 枚举类型

typedef NS_ENUM(NSInteger, KuiklyDynamicInstallResultType) {
    KuiklyDynamicInstallResultTypeSuccess = 0,
    KuiklyDynamicInstallResultTypeFetchNoPatch,
    KuiklyDynamicInstallResultTypeFetchLatestFail,
    KuiklyDynamicInstallResultTypeDynamicInfoInvalid,
    KuiklyDynamicInstallResultTypeDynamicAlreadyInstall,
    KuiklyDynamicInstallResultTypeDynamicDecryptFail,
    KuiklyDynamicInstallResultTypeDynamicInstallFail,
    KuiklyDynamicInstallResultTypeUnknownException,
    // 自定义下发通道
    KuiklyDynamicInstallResultTypeConfigParseFail,
    KuiklyDynamicInstallResultTypeDownloadFail,
    KuiklyDynamicInstallResultTypeDownloadSizeMismatch,
    KuiklyDynamicInstallResultTypeDownloadMD5Mismatch,
    KuiklyDynamicInstallResultTypeSignatureVerifyFail,
    KuiklyDynamicInstallResultTypeSuperseded
};

typedef NS_ENUM(NSInteger, KuiklyDynamicLoadResultType) {
    KuiklyDynamicLoadResultTypeSuccess = 0,
    KuiklyDynamicLoadResultTypeNotInitialized,
    KuiklyDynamicLoadResultTypeDynamicNotExist,
    KuiklyDynamicLoadResultTypeDynamicRemoved,
    KuiklyDynamicLoadResultTypeDynamicVersionNotExist,
    KuiklyDynamicLoadResultTypeUnknownException
};

#pragma mark - 数据模型

/**
 * 动态化初始化参数
 */
@interface KuiklyDynamicParams : NSObject

@property (nonatomic, strong, readonly) id context;
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, copy, readonly) NSString *model;
@property (nonatomic, copy, readonly) NSString *env;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *customParams;
@property (nonatomic, assign, readonly) BOOL enableCustomResDownload;
@property (nonatomic, assign, readonly) NSInteger maxConcurrentDownloads;
/** 设备 OS 版本（建议传 `[UIDevice currentDevice].systemVersion`）。传 `nil` 或空串时 SDK 兜底。 */
@property (nonatomic, copy, readonly) NSString *osVersion;

/** 便利构造器：默认 enableCustomResDownload=NO、maxConcurrentDownloads=2、osVersion 走 SDK 兜底 */
- (instancetype)initWithContext:(id)context
                          appId:(NSString *)appId
                         appKey:(NSString *)appKey
                         userId:(NSString *)userId
                     appVersion:(NSString *)appVersion
                   manufacturer:(NSString *)manufacturer
                          model:(NSString *)model
                            env:(NSString *)env
                   customParams:(NSDictionary<NSString *, NSString *> *)customParams;

/**
 * 便利构造器（常用）：只显式控制 osVersion。
 * enableCustomResDownload 默认 NO、maxConcurrentDownloads 默认 2。
 * @param osVersion 传 `nil` 或空串时 SDK 自动使用 `[UIDevice currentDevice].systemVersion` 兜底
 */
- (instancetype)initWithContext:(id)context
                          appId:(NSString *)appId
                         appKey:(NSString *)appKey
                         userId:(NSString *)userId
                     appVersion:(NSString *)appVersion
                   manufacturer:(NSString *)manufacturer
                          model:(NSString *)model
                            env:(NSString *)env
                   customParams:(nullable NSDictionary<NSString *, NSString *> *)customParams
                      osVersion:(nullable NSString *)osVersion;

/** 便利构造器：osVersion 走 SDK 兜底 */
- (instancetype)initWithContext:(id)context
                          appId:(NSString *)appId
                         appKey:(NSString *)appKey
                         userId:(NSString *)userId
                     appVersion:(NSString *)appVersion
                   manufacturer:(NSString *)manufacturer
                          model:(NSString *)model
                            env:(NSString *)env
                   customParams:(NSDictionary<NSString *, NSString *> *)customParams
         enableCustomResDownload:(BOOL)enableCustomResDownload
          maxConcurrentDownloads:(NSInteger)maxConcurrentDownloads;

/**
 * 全参构造器
 * @param osVersion 传 `nil` 或空串时 SDK 自动使用 `[UIDevice currentDevice].systemVersion` 兜底
 */
- (instancetype)initWithContext:(id)context
                          appId:(NSString *)appId
                         appKey:(NSString *)appKey
                         userId:(NSString *)userId
                     appVersion:(NSString *)appVersion
                   manufacturer:(NSString *)manufacturer
                          model:(NSString *)model
                            env:(NSString *)env
                   customParams:(NSDictionary<NSString *, NSString *> *)customParams
         enableCustomResDownload:(BOOL)enableCustomResDownload
          maxConcurrentDownloads:(NSInteger)maxConcurrentDownloads
                      osVersion:(nullable NSString *)osVersion;

@end

/**
 * 安装结果
 */
@interface KuiklyDynamicInstallResult : NSObject

@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, assign) int64_t version;
@property (nonatomic, assign) KuiklyDynamicInstallResultType resultType;
@property (nonatomic, copy) NSString *resultName;

- (BOOL)isSuccess;
- (BOOL)isAlreadyInstall;

@end

/**
 * 加载结果
 */
@interface KuiklyDynamicLoadResult : NSObject

@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *bundleDir;
@property (nonatomic, assign) int64_t version;
@property (nonatomic, assign) KuiklyDynamicLoadResultType resultType;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *config;

- (BOOL)isSuccess;

@end

typedef NS_ENUM(NSInteger, KuiklyDynamicModuleAction) {
    KuiklyDynamicModuleActionQueued = 0,
    KuiklyDynamicModuleActionAlreadyUpToDate,
    KuiklyDynamicModuleActionConfigInvalid
};

/**
 * 单个模块的状态
 */
@interface KuiklyDynamicModuleStatus : NSObject

@property (nonatomic, copy, readonly) NSString *moduleName;
@property (nonatomic, assign, readonly) KuiklyDynamicModuleAction action;

- (instancetype)initWithModuleName:(NSString *)moduleName action:(KuiklyDynamicModuleAction)action;

@end

/**
 * updateConfig 的即时评估结果
 */
@interface KuiklyDynamicUpdateConfigResult : NSObject

@property (nonatomic, strong, readonly) NSArray<KuiklyDynamicModuleStatus *> *moduleStatuses;

@end

#pragma mark - 回调协议

/**
 * 自定义下发全局安装监听协议
 * 注册后持续接收所有模块的异步安装结果（包括后台重试、冷启动恢复等）
 */
@protocol KuiklyDynamicCustomInstallDelegate <NSObject>

/**
 * 模块安装完成回调（已在主线程派发）
 * @param moduleName 模块名
 * @param success 是否成功
 * @param installResult 安装结果详情
 */
- (void)onModuleInstallComplete:(NSString *)moduleName
                        success:(BOOL)success
                  installResult:(KuiklyDynamicInstallResult *)installResult;

@end

/**
 * 检查更新回调协议
 */
@protocol KuiklyDynamicCheckUpdateDelegate <NSObject>

/**
 * 更新完成回调
 * @param success 是否成功
 * @param installResult 安装结果
 */
- (void)onCheckUpdateComplete:(BOOL)success installResult:(KuiklyDynamicInstallResult *)installResult;

@end

#pragma mark - 主要接口

/**
 * Kuikly动态化引擎
 */
@interface KuiklyDynamic : NSObject

/**
 * 单例实例
 */
+ (instancetype)shared;

/**
 * 初始化动态化引擎
 * @param params 初始化参数
 * @param logCallback 日志回调
 */
- (void)initializeWithParams:(KuiklyDynamicParams *)params
                 logCallback:(nullable id<KuiklyDynamicLogProtocol>)logCallback;

/**
 * 检查是否已初始化
 * @return 是否已初始化
 */
- (BOOL)isInitialized;

/**
 * 获取初始化参数
 * @return 初始化参数，未初始化时返回nil
 */
- (nullable KuiklyDynamicParams *)getParams;

/**
 * 检查更新
 * @param moduleName 模块名称
 * @param delegate 回调代理
 */
- (void)checkUpdateForModule:(NSString *)moduleName delegate:(nullable id<KuiklyDynamicCheckUpdateDelegate>)delegate;

/**
 * 加载动态资源
 * @param moduleName 模块名称
 * @return 加载结果
 */
- (KuiklyDynamicLoadResult *)loadDynamicResource:(NSString *)moduleName;

/**
 * 清理模块资源
 * @param moduleName 模块名称
 */
- (void)cleanModule:(NSString *)moduleName;

/**
 * 批量更新配置（自定义下发通道）
 * 传入 JSON 数组格式的配置字符串，SDK 会同步评估每个模块状态并返回即时结果，
 * 然后自动下载安装需要更新的模块，完成后通过全局监听器异步通知。
 * @param configJsonArray JSON 数组格式的配置字符串
 * @return 即时评估结果
 */
- (KuiklyDynamicUpdateConfigResult *)updateConfig:(NSString *)configJsonArray;

/**
 * 注册全局安装完成监听器，持续接收所有模块的异步安装结果
 * 可在 init 之前调用
 * @param delegate 监听代理
 */
- (void)addCustomInstallDelegate:(id<KuiklyDynamicCustomInstallDelegate>)delegate;

/**
 * 移除全局安装监听器
 * @param delegate 监听代理
 */
- (void)removeCustomInstallDelegate:(id<KuiklyDynamicCustomInstallDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
