//
//  KuiklyRenderJSContextHandler.h
//  KuiklyKotlinProject
//
//  Created by tomqiu on 2022/7/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KuiklyRenderContextProtocol.h"

/// Kotlin侧报错通知
FOUNDATION_EXPORT NSNotificationName const _Nonnull KRContextErrorNotificationName;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief JS执行环境的实现者
 */
@interface KuiklyRenderJSContextHandler : NSObject<KuiklyRenderContextProtocol>

@end

NS_ASSUME_NONNULL_END
