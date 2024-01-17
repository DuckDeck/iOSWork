//
//  BaseBridge.m
//  iOSWork
//
//  Created by Stan Hu on 2024/1/15.
//

#import "BaseBridge.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>
@implementation BaseBridge
-(NSArray<NSString *>*)getDnsAddress{
    NSMutableArray *DNSList = [NSMutableArray array];
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);
    if (result == 0) {
        for (int i=0;i < res->nscount;i++) {
            NSString *s = [NSString stringWithUTF8String:inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [DNSList addObject:s];
        }
    }
    res_ndestroy(res);
    free(res);
    return DNSList;
}
@end
