//
//  PatchViewController.m
//  iOSWork
//
//  Created by Stan Hu on 2021/11/16.
//

#import "PatchViewController.h"
#import "diff.h"
@interface PatchViewController ()
@property (strong,nonatomic) UITextField* txt;

@end

@implementation PatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"差分" style:UIBarButtonItemStylePlain target:self action:@selector(createDiffPackage)],[[UIBarButtonItem alloc] initWithTitle:@"合并" style:UIBarButtonItemStylePlain target:self action:@selector(joinPackage)]];
    
     _txt = [UITextField new];
    _txt.frame = CGRectMake(10, 150, 200, 100);
    _txt.layer.borderWidth = 1;
    [self.view addSubview:_txt];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _txt.text = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)createDiffPackage{
    
    testPrintf();
    
    const char *argv[4];
    argv[0] = "bsdiff";
    // oldPath
    NSString *path1 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"old.zip"];
    argv[1] = [path1 UTF8String];
    // new path
    NSString *path2 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"new.zip"];
    argv[2] = [path2 UTF8String];
    argv[3] = [[self createFile:@"diff_Test"] UTF8String];
    int result = BsdiffUntils_bsdiff(4, argv);
    if (result == 0) {
        NSLog(@"成功生成差分文件,路径是%s",argv[3]);
    }
}

-(void)joinPackage{
    const char *argv[4];
    argv[0] = "bspatch";
    // oldPath
    NSString *path1 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"old.zip"];
    argv[1] = [path1 UTF8String];
    // patch new path
    argv[2] = [[self createFile:@"test.zip"] UTF8String];
    argv[3] = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"diff_Test"] UTF8String];
    int result = BsdiffUntils_bspatch(4, argv);
    if (result == 0) {
        NSLog(@"成功合并差分文件,路径是%s",argv[2]);
    }
}

-(NSString* )createFile:(NSString*)file{
    NSString* tem = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* filePath = [tem stringByAppendingPathComponent:file];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (!isExist) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return  filePath;
}


//下面是swift的调用方式
//func patch() {
//    let path1 = Bundle.main.path(forResource: "old", ofType: "zip")
//    let strs = ["bspatch",path1,createPath(file: "test.zip"),"\(NSTemporaryDirectory())diff_Test"]
//    var args = strs.map{strdup($0)}
//    defer {
//        args.forEach{$0?.deallocate()}
//    }
//    let result = BsdiffUntils_bspatch(4, &args)
//    print(result)
//}
//
//func createPath(file:String) -> String {
//    let tmp = NSTemporaryDirectory()
//    let filePath = "\(tmp)\(file)"
//    if !FileManager.default.fileExists(atPath: filePath) {
//        FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
//    }
//    return filePath
//}


@end
