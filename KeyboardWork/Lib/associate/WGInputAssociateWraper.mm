//
//  InputAssociateWraper.m
//  WeAblum
//
//  Created by chen liang on 2020/11/24.
//  Copyright © 2020 WeAblum. All rights reserved.
//

#import "WGInputAssociateWraper.h"
#include "InputAssociate.hpp"

@interface WGInputAssociateWraper()
@property (nonatomic, assign) InputAssociateManager *manager;
@end


@implementation WGInputAssociateWraper

+ (instancetype)warp {
    static WGInputAssociateWraper *warp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        warp = [[WGInputAssociateWraper alloc] init];
    });
    return warp;
}

- (instancetype)init {
    self = [super init];
    [self assoicateEnable];
    return self;
}

- (void)dealloc {
    [self clear];
}


- (void)clear {
    if (self.manager != nullptr) {
        delete self.manager;
        self.manager = nullptr;
    }
}
- (void)executeTime:(void(^)())block {
    NSDate *start = [[NSDate alloc] init];
    block();
    NSDate *end = [[NSDate alloc] init];
    NSLog(@"the execute time %f", (end.timeIntervalSince1970 * 1000 - start.timeIntervalSince1970 * 1000));
}

- (void)assoicateEnable {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *dict_path = [NSString stringWithFormat:@"%@/%@",path,@"jieba.dict.utf8"];
    NSString *hmm_path = [NSString stringWithFormat:@"%@/%@",path,@"hmm_model.utf8"];
    NSString *user_dict_path = [NSString stringWithFormat:@"%@/%@",path,@"user.dict.utf8"];
    NSString *idf_path = [NSString stringWithFormat:@"%@/%@",path,@"idf.utf8"];
    const char *stop_word_path = [[NSString stringWithFormat:@"%@/%@",path,@"stop_words.utf8"] fileSystemRepresentation];
    NSString *dat_cache_path = [NSString stringWithFormat:@"%@/%@",path,@"jieba.dict.utf8.cad346b82a217a06f2713f6efba49e04.1.dat_cache"];
    self.manager = new InputAssociateManager();
    [self executeTime:^{
        self.manager->enable_jieba(dict_path.UTF8String, hmm_path.UTF8String, user_dict_path.UTF8String, idf_path.UTF8String, stop_word_path, dat_cache_path.UTF8String);
    }];
}

- (NSArray<NSString *> *)get_associate_list_by:(NSString *)input {
    NSMutableArray *res = @[].mutableCopy;
    [self executeTime:^{
        std::vector<std::string> values = self.manager->get_associate_list(input.UTF8String);
        for (int index = 0; index < values.size(); index ++) {
            std::string assoicate = values.at(index);
            NSString *str = [NSString stringWithUTF8String:assoicate.c_str()];
            [res addObject:str];
        }
    }];
    return res;
}

- (NSArray<NSString *> *)get_split_list_by:(NSString *)input {
    NSMutableArray *res = @[].mutableCopy;
    [self executeTime:^{
        std::vector<std::string> values = self.manager->get_split_list(input.UTF8String);
        for (int index = 0; index < values.size(); index ++) {
            std::string assoicate = values.at(index);
            NSString *str = [NSString stringWithUTF8String:assoicate.c_str()];
            [res addObject:str];
        }
    }];
    return res;
}

- (void)input_test {
    self.manager->get_associate_list(@"你好".UTF8String);
}

@end
