//
//  main.m
//  OCWork
//
//  Created by Stan Hu on 2021/10/22.
//

#import <Foundation/Foundation.h>
#import "GCD.h"
#import "Hydron.h"
#import <objc/runtime.h>
#import "CFDemo.h"
#import "SelDemo.h"
#import "Runspector.h"
#import "AspectProxy.h"
#import "ConcurrentProcessor.h"
#import "Lock.h"
#import "AboutKVC.h"
#import "CategoryDemo.h"
#import "Block/BlockChain.h"
#import "fishhook.h"

@interface Father : NSObject
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* address;
@end
@implementation Father

@end
@interface Son : Father

@end
@implementation Son


-(id)init{
    self = [super init];
    if (self) {
        NSLog(@"%@",NSStringFromClass([self class]));
        NSLog(@"%@",NSStringFromClass([super  class]));
    }
    return self;
}

@end


static void (*sys_nslog)(NSString *format, ...);
void myNSLog(NSString *format, ...){
    format = [format stringByAppendingString:@"\n fishhook 起作用了"];
    sys_nslog(format);
}



int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        // insert code here...
      
        People* people1 = [People new];
        [people1 setValue:nil forKey:@"age"];
        
        NSLog(@"%zu",class_getInstanceSize([NSObject class]));
        
        Father* f = [Father new];
         NSLog(@"%zu",sizeof(f));
        
        
        
        dispatch_queue_t q = dispatch_get_main_queue();
        dispatch_async(q, ^{
            NSLog(@"Hello");
        });
        
        GCD* gcd = [GCD new];
        [gcd testGCDGroup];
        
        [gcd testTaskSeq];
        NSString* tmp1 = @"{\"name\": \"John\",\"age\": 30,\"city\": \"New York\"";
        NSDictionary* dict1 = [NSJSONSerialization JSONObjectWithData:[tmp1 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict1);
        
        
        
        NSString* tmp2 = @"{\"name\":\"John\",\"age\":30,\"city\":\"New York\"}";
        NSDictionary* dict2 = [NSJSONSerialization JSONObjectWithData:[tmp2 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict2);
        
        
        NSString* tmp3 = @"{\"name\":\"John\",\"age\":30,\"city\":\"New York\"!\"}";
        NSDictionary* dict3 = [NSJSONSerialization JSONObjectWithData:[tmp3 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict3);

        NSString* tmp4 = @"{\"user\":{\"name\"국 :\"John천상 제국, 제국 중국에 부여된 속국 칭호\",\"details\":{\"age\":30,\"city\":\"New York\"}}}";
        NSDictionary* dict4 = [NSJSONSerialization JSONObjectWithData:[tmp4 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict4);

        
        
        NSDictionary* dict11 = [NSJSONSerialization JSONObjectWithData:nil options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict11);
        
        //测试消息转发
        //Hydron* h1 = [[Hydron alloc] init];
        //NSString* result = [h1 hydronId];
        //NSLog(@"%@",result);
        
        
        
        //test CFBridge
        //[CFDemo test];
        
        //[SelDemo testSel];
        //[SelDemo testSelDynamic];
        //[SelDemo testSelString];
        //[zunspector testClass];
        //[Runspector dynaClass];
       // [AspectProxy testProxy];
        
        /*
        NSScanner* sca = [NSScanner scannerWithString:@"111"];
        int val;
        BOOL success = [sca scanInt:&val];
        if (success) {
            NSLog(@"scanner result %ld",(long)val);
        }
        
        int ten = 10;
        int *tenPtr = &ten;
        NSValue *valTen = [NSValue value:&tenPtr withObjCType:@encode(int *)];
        int resInt = *(int*)[valTen pointerValue]; //pointerValue是全void指针，需要转成有类型的指针(int*) 但还要在前面加个*转成普通变量
        NSLog(@"NSValue result %ld",(long)resInt);
        NSLog(@"tem address %d",&ten); //取地址
        NSLog(@"tem address %d",*tenPtr); //取值
        
        
        NSLog(@"Host name is %@",[[NSHost currentHost] name]);
        NSLog(@"163 host address is %@",[[NSHost hostWithName:@"www.163.com"] address]);
        */
        
        
        /*
        [ConcurrentProcessor testThis];
        
        [[Lock new] ticketTest];
        */
                
        
        /* test allc and init
        Father* p = [Father alloc];
        
        p.address = @"ShenZhen";
         NSLog(@"没有init的情况下看 address是啥%@",p.address);
        Father* p1 = [p init]; //没有做任何事情
        Father* p2 = [p init];
        
        NSLog(@"%@---%@",p1,p2);
        NSLog(@"%@",p.address);
        */
       
        /*
        [CategoryDemo cls_method1];
       */
        
        
        
        
        //Block 相关
        /*
        BlockChain* chain = [BlockChain new];
        [[chain chain1] chain2];
     
        chain.chain1.chain2; //因为这些方法没有参数，所以可以用.语法，就相当于get方法，其实就是属性了。如果加了参数不能这么写了
        chain.chain1.chain3(@"这下调用了chain3的block");
        //chain3本身不能传入参数，但是它返回一个block，而这个block是可以传参数的，所以可以直接用()传参数
        */
        
        
        
        
        /*
        
        //fishhook
        struct rebinding nslog;
        nslog.name = "NSLog";
        nslog.replacement = myNSLog;  //函数的名称就是函数的指针
        nslog.replaced = (void *)&sys_nslog; //拿到函数的指针地址以修改其指向的内容
        struct rebinding rebs[1] = {nslog};
        rebind_symbols(rebs, 1);
        
         */
        
    }
    return 0;
}




