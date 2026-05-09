//
//  KuiklyContextParam.h
//  KuiklyIOSRender
//
//  Created by luoyibu on 2023/7/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KuiklyRenderContextProtocol.h"
#import "KuiklyContextParam.h"

NS_ASSUME_NONNULL_BEGIN

extern const KuiklyContextMode KuiklyContextMode_JS;

// Kuikly JS接入模式上下文
@interface KuiklyContextModeJS : KuiklyBaseContextMode

/// useHermesEngine 是否使用Hermes引擎
@property (nonatomic, assign) BOOL useHermesEngine;

// contextUrl 环境代码对应的url，可为本地path或者远程url; jsc 的异常信息需要这个；不影响脚本的执行，仅丰富异常信息
@property (nonatomic, strong) NSURL *contextUrl;

// assetsPathUrl assert资源在js产物模式下，由于是后下载，故通过该路径来传递assert资源的路径。注意该目录下，应该有common目录，和对应的pagename目录
@property (nonatomic, strong) NSURL *assetsPathUrl;

// 创建Kuikly JS接入模式实例，实例的modeID为KuiklyContextMode_JS
- (instancetype)initJSMode;

@end

NS_ASSUME_NONNULL_END
