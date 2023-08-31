//
//  ObjcTry.h
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ObjcTry : NSObject

+ (void)tryOcException:(nonnull void(^)(void))tryBlock catchBlock:(nullable void(^)( NSException * _Nonnull exception))catchBlock finally:(nullable void(^)(void))finallyBlock;
@end

NS_ASSUME_NONNULL_END

