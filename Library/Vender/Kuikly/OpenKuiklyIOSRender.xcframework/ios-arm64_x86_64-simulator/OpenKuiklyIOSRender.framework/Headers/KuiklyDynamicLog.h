//
//  KuiklyDynamicLog.h
//  ShiplyMacUpgrade
//
//  Created by Shiply on 2025/8/8.
//  Copyright © 2025 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 日志级别
typedef NS_ENUM(NSInteger, KuiklyDynamicLogLevel) {
    KuiklyDynamicLogLevelDebug = 0,
    KuiklyDynamicLogLevelInfo,
    KuiklyDynamicLogLevelWarn,
    KuiklyDynamicLogLevelError
};

// 日志回调协议
@protocol KuiklyDynamicLogProtocol <NSObject>
@optional
- (void)onLogMessage:(NSString *)fullMessage logLevel:(KuiklyDynamicLogLevel)logLevel;
@end

// 统一日志接口
@interface KuiklyDynamicLog : NSObject

// 日志标签
@property (class, nonatomic, copy, readonly) NSString *logTag;

// 设置日志级别
+ (void)setLogLevel:(KuiklyDynamicLogLevel)level;

// 设置日志回调
+ (void)setLogCallback:(nullable id<KuiklyDynamicLogProtocol>)callback;

// 日志方法（带格式）
+ (void)debug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void)info:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void)warn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void)error:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 带上下文的日志方法
+ (void)debug:(NSString *)message context:(nullable NSDictionary *)context;
+ (void)info:(NSString *)message context:(nullable NSDictionary *)context;
+ (void)warn:(NSString *)message context:(nullable NSDictionary *)context;
+ (void)error:(NSString *)message context:(nullable NSDictionary *)context;

@end

// MARK: - 宏定义，自动添加文件名和行号
#define KuiklyDynamicLogDebug(format, ...) \
    [KuiklyDynamicLog debug:@"[%s:%d] " format, __FILE__, __LINE__, ##__VA_ARGS__]

#define KuiklyDynamicLogInfo(format, ...) \
    [KuiklyDynamicLog info:@"[%s:%d] " format, __FILE__, __LINE__, ##__VA_ARGS__]

#define KuiklyDynamicLogWarn(format, ...) \
    [KuiklyDynamicLog warn:@"[%s:%d] " format, __FILE__, __LINE__, ##__VA_ARGS__]

#define KuiklyDynamicLogError(format, ...) \
    [KuiklyDynamicLog error:@"[%s:%d] " format, __FILE__, __LINE__, ##__VA_ARGS__]

// 带配置信息的宏定义
#define KuiklyDynamicLogDebugWithConfig(config, format, ...) \
    [KuiklyDynamicLog debug:@"[%s:%d][%@] " format, __FILE__, __LINE__, (config) ? [config description] : @"nil", ##__VA_ARGS__]

#define KuiklyDynamicLogInfoWithConfig(config, format, ...) \
    [KuiklyDynamicLog info:@"[%s:%d][%@] " format, __FILE__, __LINE__, (config) ? [config description] : @"nil", ##__VA_ARGS__]

#define KuiklyDynamicLogWarnWithConfig(config, format, ...) \
    [KuiklyDynamicLog warn:@"[%s:%d][%@] " format, __FILE__, __LINE__, (config) ? [config description] : @"nil", ##__VA_ARGS__]

#define KuiklyDynamicLogErrorWithConfig(config, format, ...) \
    [KuiklyDynamicLog error:@"[%s:%d][%@] " format, __FILE__, __LINE__, (config) ? [config description] : @"nil", ##__VA_ARGS__]

NS_ASSUME_NONNULL_END
