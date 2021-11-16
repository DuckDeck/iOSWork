//
//  RerangeBinaryViewController.m
//  iOSWork
//
//  Created by Stan Hu on 2021/11/16.
//

#import "RerangeBinaryViewController.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface RerangeBinaryViewController ()

@end

@implementation RerangeBinaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self test1];
    
    
    
    /// base64 转 uiimage ,前面 data:image/png;base64, 要去掉
    NSData* da = [[NSData alloc] initWithBase64EncodedString:@"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAIRlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABSgAwAEAAAAAQAAABQAAAAAQeed/gAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGV7hBwAAAe5JREFUOBGdlLFPVEEQhzkPUIho0MSIAUIoUCptbCxoLS1t8N9QCxogoaKAECoKCAUlIRa0FhiCASsSrYDCiDFGpUAkCsr3rW9eHnDcEX7Jdzs7uzs7O/v2SnXHdYluGf6Ctu0hFBVzwldpThpzYiXV4yxlNFSagC9f60QV2dzAHoQe+ATTsARFtdF5CvfhH0zCO/BkhwYyqGm7+yJchQnYhBlYAHUdZmEZHsE6fIB5eAiWxqB5unewt3Sc0Dj997AKo9AMITffgAeZIwUsHvsVA2+gE7qhA9QY/ABL0gqWZAQ88kvwpEkRrJ/eMGyDk7/CHnghTv4GXWBpdqAR3PQzfIR7MARTkPSa32eZbS0vg0dryvBoBjeQ/iugHFdPYEXDScrUzU79+d+c+fu7MPIrs11r9nnAJew5cMDd3eA8smT7cBtcnz4Z21uwBi/gJ5h5raAGMytv1kvrgy1Iauf3bWZfpFlm0V0XFmvYSL8FdjP/eTP0K3Btmh8B6SfHwYlWfy157HzzCBgO66Gsj4RfX1GOqaih9rEMDeRb9LjKidVU3MhTuTYlFxn6Em7CY/C2/ZBrBbV2vqZe8B/oC6SoZufAc/D6zTKOjFlVZnYNBuA7lKMW7hYZ+ZzCxqwq18VrOVXzuJCqEc4YzNceAZmjZj6lBpc+AAAAAElFTkSuQmCC" options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UIImage *i = [UIImage imageWithData:da];
            
    size_t t =  class_getInstanceSize([NSObject class]);

    
    
    
   CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
       NSLog(@"%@",observer);
       switch (activity) {
           case kCFRunLoopEntry:
               NSLog(@"RunLoop进入");
               break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"RunLoop将要处理Timer事件");
               break;
              case kCFRunLoopBeforeSources:
                NSLog(@"RunLoop将要处理Source");
               break;
               case kCFRunLoopBeforeWaiting:
                NSLog(@"RunLoop将要休息了");
           case kCFRunLoopAfterWaiting:
               NSLog(@"RunLoop将要醒来了");
               break;
           case kCFRunLoopExit:
                 NSLog(@"RunLoop退出");
                 break;
                     
           default:
               break;
       }
   });
    
//    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
//    CFRelease(observer);
    //上面是的主线程的，我们看看其他子线程的
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
        //如果只写上面这些是不行的，因为该线程没有启动runloop,所以任务事件也没有发生，就算调用run启动runloop也不会有任务回调，需要添加事件再调用 run 方法才行，
        [self performSelector:@selector(test1) withObject:nil afterDelay:2];
        [[NSRunLoop currentRunLoop] run]; //直接调用 run 并不会运行，因为里面没有modeitems，需要添加modeitems也就是任务才会执行
        
        CFRelease(observer);
        //最后runloop退出
    });
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self test2];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self test3];
}

- (void)test1 {
    NSLog(@"%s",__func__);
}

- (void)test2 {
    NSLog(@"%s",__func__);
}

- (void)test3 {
    NSLog(@"%s",__func__);
}

//正常情况下，这三个Test方法是在后面的，如果在order文件加上这三个方法。那么这三方法会排到前面来
//order file
/*
 -[RerangeBinaryViewController test1]
 -[RerangeBinaryViewController test2]
 -[RerangeBinaryViewController test3]
 */
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,uint32_t *stop) {
    static uint64_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
      *x = ++N;  // Guards should start from 1.
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    if (!*guard) return;  // Duplicate the guard check.

    void *PC = __builtin_return_address(0);
    
    Dl_info info;
    dladdr(PC, &info);
    printf("\nfname：%s \nfbase：%p \nsname：%s\nsaddr：%p \n",info.dli_fname,info.dli_fbase,info.dli_sname,info.dli_saddr);


    char PcDescr[1024];
    //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
    printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
}


@end
