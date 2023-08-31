//
//  ObjcTry.m
//  iOSWork
//
//  Created by Stan Hu on 2023/8/31.
//

#import "ObjcTry.h"

@implementation ObjcTry
+ (void)tryOcException:(void (^)(void))tryBlock catchBlock:(void (^)(NSException * _Nonnull))catchBlock finally:(void (^)(void))finallyBlock {
    @try {
        tryBlock? tryBlock() : nil;
    } @catch (NSException *exception) {
        catchBlock ? catchBlock(exception) : nil;
    } @finally {
        finallyBlock ? finallyBlock() : nil;
    }
}
@end
