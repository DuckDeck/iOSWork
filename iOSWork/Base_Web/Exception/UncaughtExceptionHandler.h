//
//  UncaughtExceptionHandler.h
//  iOSWork
//
//  Created by Stan Hu on 2021/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}
+(void)InstallUncaughtExceptionHandler;
@end

NS_ASSUME_NONNULL_END
