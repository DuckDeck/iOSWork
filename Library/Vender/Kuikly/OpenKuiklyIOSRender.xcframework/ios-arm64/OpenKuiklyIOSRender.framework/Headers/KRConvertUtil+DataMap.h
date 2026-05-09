//
//  KRConvertUtil+DataMap.h
//  KuiklyIOSRender
//
//  Created by Mac on 2023/10/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "KRConvertUtil.h"
NS_ASSUME_NONNULL_BEGIN
@class JSValue;
@class JSContext;
#define  ToOCObject(jsValue) ([KRConvertUtil jsValueToOCObject:jsValue])
@interface KRConvertUtil (DataMap)

+ (NSData *)jsValueToNSData:(JSValue *)jsValue;
+ (NSObject *)jsValueToOCObject:(JSValue *)jsValue;
+ (BOOL)isInt8Array:(JSValue *)jsValue;
+ (NSMutableArray *)jsValueToArray:(JSValue *)jsValue;
+ (id)nativeObjectToJSValue:(id)ocObject context:(JSContext *)context;
+ (NSObject *)nsDataToJSValue:(NSData *)data context:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
