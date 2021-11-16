//
//  GCD.m
//  Console
//
//  Created by Stan Hu on 25/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "GCD.h"

@implementation GCD
-(void)testGCDGroup {
    dispatch_group_t g = dispatch_group_create();
    dispatch_queue_t q = dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"Will enter task1");
    dispatch_group_enter(g);
    dispatch_group_async(g, q, ^{
        [self task1];
        dispatch_group_leave(g);
    });
    NSLog(@"Will enter task2");
    dispatch_group_enter(g);
    dispatch_group_async(g, q, ^{
        [self task2];
        dispatch_group_leave(g);
    });
    
    NSLog(@"Come to notify");
    dispatch_group_notify(g, q, ^{
        NSLog(@"Enter notify");
        [self taskComplete];
    });
    NSLog(@"Pass notify");
}

-(void)task1 {
    NSLog(@"Enter sleep 10.");
    [NSThread sleepForTimeInterval:10];
    NSLog(@"Leave sleep 10.");
}

-(void)task2 {
    NSLog(@"Enter sleep 5.");
    [NSThread sleepForTimeInterval:5];
    NSLog(@"Leave sleep 5.");
}

-(void)taskComplete {
    NSLog(@"All task finished.");
}
-(void)testDoSomething{
    [self doSomeThingForFlag:1 finish:^{
        
    }];
    
    [self doSomeThingForFlag:2 finish:^{
        
    }];
    
    [self doSomeThingForFlag:3 finish:^{
        
    }];
    
    [self doSomeThingForFlag:4 finish:^{
        
    }];
}
- (void)doSomeThingForFlag:(NSInteger)flag finish:(void(^)(void))finish {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"do:%ld",(long)flag);
        sleep(2+arc4random_uniform(4));
        NSLog(@"finish:%ld",flag);
        if (finish) finish();
    });
}

-(void)testTaskSeq{
    NSLog(@"任务1");
   dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
   dispatch_queue_t queue2 = dispatch_queue_create("myQueue2", DISPATCH_QUEUE_CONCURRENT);
   dispatch_async(queue, ^{
       NSLog(@"任务2");
       dispatch_sync(queue2, ^{
           NSLog(@"任务3");
       });
       NSLog(@"任务4");
   });
   NSLog(@"任务5");

}
-(void)testSemaphore{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
   __block int a = 0;
    while (a < 5) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            a++;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"a的值是：%d",a);

}
@end
