//
//  KuiklyRenderViewControllerDelegator.h
//  KuiklyProject
//
//  Created by tomqiu on 2022/7/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "KuiklyRenderViewControllerBaseDelegator.h"
#import "KuiklyContextMode.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * @brief 接入层对接的页面级粒度入口类，KuiklyRenderViewController对应的真正实现类，如要对接view粒度，请查看使用KuiklyView.h
 */
@interface KuiklyRenderViewControllerDelegator : KuiklyRenderViewControllerBaseDelegator

/*
 * @brief 创建实例对应的初始化方法.
 * @param pageName 页面名 （对应的值为kotlin侧页面注解 @Page("xxxx")中的xxx名）
 * @param params 页面对应的参数（kotlin侧可通过pageData.params获取）
 * @param frameworkName kuikly kmm工程打包的framework名字，如shared.framework,则传入 @"shared"（注：也可以通过fetchContextCode接口传入）
 * @param hotReloadIp 热重载模式下的本地代理电脑ip地址，如果为模拟器，该ip则为空字符串(注：若不开启热重载，该参则传入nil值)
 * @return 返回KuiklyRenderViewControllerDelegator实例
 */
- (instancetype)initWithModuleName:(NSString * _Nullable)moduleName
                          pageName:(NSString *)pageName
                          pageData:(NSDictionary *)pageData
                     frameworkName:(NSString * _Nullable)frameworkName
                       hotReloadIp:(NSString * _Nullable)ip;

- (instancetype)initWithPageName:(NSString *)pageName
                        pageData:(NSDictionary *)pageData;

- (instancetype)initWithModuleName:(NSString * _Nullable)moduleName
                          pageName:(NSString *)pageName
                          pageData:(NSDictionary *)pageData
                     frameworkName:(NSString * _Nullable)frameworkName;

- (instancetype)initWithModuleName:(NSString * _Nullable)moduleName
                          pageName:(NSString *)pageName
                          pageData:(NSDictionary *)pageData;

- (instancetype)initWithPageName:(NSString *)pageName
                        pageData:(NSDictionary *)pageData
                     hotReloadIp:(NSString * _Nullable)ip;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@protocol KuiklyRenderViewControllerDelegatorDelegate<KuiklyRenderViewControllerBaseDelegatorDelegate>
@optional
/*
 * @breif contextCode环境代码对应的url，可为本地path或者远程url; jsc 的异常信息需要这个；不影响脚本的执行，仅为了提取异常信息
 */
- (NSURL *)contextUrl;

/*
 * @breif assetsPathUrl assert资源在js产物模式下，由于是后下载，故通过该路径来传递assert资源的路径。注意该目录下，应该有common目录，和对应的pagename目录
 */
- (NSURL *)assetsPathUrl;

/*
 * @brief JS模式下是否使用Hermes JS引擎（默认使用JSC引擎）
 * @return 是否启动Hermes引擎
 *
 * 注意，使用hermes hbc时，`fetchContextCodeWithPageName`需传入base64编码的string
 */
- (BOOL)shouldUseHermesEngine:(NSString *)pageName;

/*
 * @brief JS HotReload模式下是否加载Hermes hbc文件（默认使用js文件）
 * @return 是否加载hbc文件
 * 一般情况下无需设置，推荐hermes调试时使用js文件
 */
- (BOOL)useHermesHBCForHotReload:(NSString *)pageName;

@end


NS_ASSUME_NONNULL_END

