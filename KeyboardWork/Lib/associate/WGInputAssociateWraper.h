//
//  InputAssociateWraper.h
//  WeAblum
//
//  Created by chen liang on 2020/11/24.
//  Copyright © 2020 WeAblum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WGInputAssociateWraper : NSObject

+ (instancetype)warp;
- (void)clear;
- (void)input_test;
- (NSArray <NSString *> *)get_associate_list_by:(NSString *)input;
- (NSArray <NSString *> *)get_split_list_by:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
