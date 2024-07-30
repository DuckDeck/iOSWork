// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

//
//  LogUtil.m
//  iOSDemo
//
//  Created by caoshaokun on 16/11/30.
//  Copyright © 2016年 caoshaokun. All rights reserved.
//

#import "LogUtil.h"
#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger.h>
#import <sys/xattr.h>
#import "SSZipArchive.h"
#import <UIKit/UIKit.h>
#import "CommonUtils.h"

@implementation LogUtil
+(void)initXlogger: (XloggerType)debugLevel releaseLevel: (XloggerType)releaseLevel path: (NSString*)path prefix: (const char*)prefix{
    NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:path];
    
    NSURL* URL = [NSURL fileURLWithPath:logPath];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
   
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error]; // 设置不备份到iCloud
    // set do not backup for logpath
    const char* attrName = "io.jinkey";
    u_int8_t attrValue = 1;
    setxattr([logPath UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
    #if DEBUG

    xlogger_SetLevel((TLogLevel)debugLevel);
    mars::xlog::appender_set_console_log(true);
    #else
   
    xlogger_SetLevel((TLogLevel)releaseLevel);
    appender_set_console_log(false);
    #endif
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [logPath UTF8String];
    config.nameprefix_ = prefix;
    config.compress_mode_ = mars::xlog::kZlib;
    config.pub_key_ = [@"b11894e1a0540dc2df4e4a994fce26569095bad2c34e1f17376b257b4d1b4a4fec9081cf0cacb9e7f67003e9973f81264f253ee586ec65f3efca1ac22ae542d1" UTF8String];
    //352053949d33311161e936a96b8c3534019dd5f1af024054e5571b8f7f73b296  private key
    mars::xlog::appender_open(config);
}

+(void)deinitXlogger {
    mars::xlog::appender_close();
}


+(void)flushLog{
    mars::xlog::appender_flush_sync();
}

@end
