//
//  KuiklyView.h
//  KuiklyProject
//
//  Created by tomqiu on 2022/7/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "KRUIKit.h" // [macOS]
#import "KuiklyRenderViewControllerDelegator.h"
#import "KuiklyBaseView.h"

NS_ASSUME_NONNULL_BEGIN

// KuiklyView代理
@protocol KuiklyViewDelegate;
/*
 * @brief View粒度入口类（业务可以使用该类作为kuikly接入层入口类）
 */
@interface KuiklyView : KuiklyBaseView

/*
 * @brief 创建实例对应的初始化方法（支持动态产物模块名）.
 * @param frame 初始化frame，该值建议size保持最终尺寸，避免触发二次layout(注:frame.size不能为zero)
 * @param moduleName 动态产物模块名，用于检查是否存在对应的动态产物
 * @param pageName 页面名 （对应的值为kotlin侧页面注解 @Page("xxxx")中的xxx名）
 * @param params 页面对应的参数（kotlin侧可通过pageData.params获取）
 * @param delegate 需要实现的代理(如：fetchContextCodeWithPageName方法)
 * @param frameworkName kuikly kmm工程打包的framework名字，如shared.framework,则传入 @"shared"（注：若为framework模式必传，js模式则需要实现KuiklyViewDelegate代理的fetchContextCode接口）
 * @param hotReloadIp 热重载模式下的本地代理电脑ip地址，如果为模拟器，该ip则为空字符串@""(注：若不开启热重载，该参则传入nil值)
 * @return 返回KuiklyView实例
 */
- (instancetype)initWithFrame:(CGRect)frame
                   moduleName:(NSString * _Nullable)moduleName
                     pageName:(NSString *)pageName
                     pageData:(NSDictionary *)pageData
                     delegate:(id<KuiklyViewDelegate>)delegate
                frameworkName:(NSString * _Nullable)frameworkName
                  hotReloadIp:(NSString * _Nullable)ip;

- (instancetype)initWithFrame:(CGRect)frame
                   moduleName:(NSString * _Nullable)moduleName
                     pageName:(NSString *)pageName
                     pageData:(NSDictionary *)pageData
                     delegate:(id<KuiklyViewDelegate>)delegate
                frameworkName:(NSString * _Nullable)frameworkName;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end



// KuiklyView代理
@protocol KuiklyViewDelegate <KuiklyRenderViewControllerDelegatorDelegate, KuiklyViewBaseDelegate>
// 查看KuiklyRenderViewControllerDelegatorDelegate
@end

NS_ASSUME_NONNULL_END
