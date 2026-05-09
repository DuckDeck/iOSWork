//
//  KuiklyRenderViewControllerDelegator+HotReload.h
//  KuiklyIOSRender
//
//  Created by tomqiu on 2023/4/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "KuiklyRenderViewControllerDelegator.h"

NS_ASSUME_NONNULL_BEGIN

@interface KuiklyRenderViewControllerDelegator (HotReload)

+ (NSString *)generateHotReloadUrlWithIp:(NSString *)ip;
- (BOOL)isHotReloadModeWithPageName:(NSString *)pageName pageData:(NSDictionary *)pageData;
- (void)hotReloadScriptWithUrl:(NSString *)url resultCallback:(KuiklyContextCodeCallback)callback;
@end

NS_ASSUME_NONNULL_END
