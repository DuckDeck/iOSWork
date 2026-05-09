//
//  KuiklyRenderJSContextHandler.h
//  KuiklyKotlinProject
//
//  Created by raycgwang on 2025/4/8.
//  Copyright © 2025 Tencent. All rights reserved.
//

#ifdef KUIKLY_HERMES_ENABLED

#import <Foundation/Foundation.h>
#import "KuiklyRenderContextProtocol.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief JS执行环境的实现者
 */
@interface KuiklyRenderJSHermesContextHandler : NSObject<KuiklyRenderContextProtocol>

@end

NS_ASSUME_NONNULL_END

#endif /* KUIKLY_HERMES_ENABLED */
