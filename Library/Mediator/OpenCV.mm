//
//  OpenCV.m
//  iOSWork
//
//  Created by Stan Hu on 2021/11/28.
//

#import "OpenCV.h"
using namespace cv;

@interface OpenCV(){
    cv::CascadeClassifier icon_cascade;//分类器
    BOOL isSuccessLoadXml;
}
@end
@implementation OpenCV
static VideoCapture  cap;
static NSString* currentPath;
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"lbpcascade_frontalface" ofType:@"xml"];
        cv::String fileName = [bundlePath cStringUsingEncoding:NSUTF8StringEncoding];
        
        BOOL isSuccessLoadFile = icon_cascade.load(fileName);
        isSuccessLoadXml = isSuccessLoadFile;
        if (isSuccessLoadFile) {
            NSLog(@"Load success.......");
        }else{
            NSLog(@"Load failed......");
        }
    }
    return self;
}



- (UIImage *)RegImage:(CMSampleBufferRef)buff{
    if(!isSuccessLoadXml){
        return nil;
    }
    
    [NSThread sleepForTimeInterval:0.5];
    cv::Mat imgMat;
    
    
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(buff);
    
    //锁定内存
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    // get the address to the image data
    void *imgBufAddr = CVPixelBufferGetBaseAddress(imgBuf);
    
    // get image properties
    int w = (int)CVPixelBufferGetWidth(imgBuf);
    int h = (int)CVPixelBufferGetHeight(imgBuf);
    
    // create the cv mat
    cv::Mat mat(h, w, CV_8UC4, imgBufAddr, 0);
    //    //转换为灰度图像
    //    cv::Mat edges;
    //    cv::cvtColor(mat, edges, CV_BGR2GRAY);
    
    //旋转90度
    cv::Mat transMat;
    cv::transpose(mat, transMat);
    
    //翻转,1是x方向，0是y方向，-1位Both
   
    cv::flip(transMat, imgMat, 1);
    
    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
    
    
    
    cv::cvtColor(imgMat, imgMat, cv::COLOR_BGR2GRAY);
    UIImage *tempImg = MatToUIImage(imgMat);
    
    //获取标记的矩形
    NSArray *rectArr = [self getTagRectInLayer:imgMat];
    
    NSLog(@"识别到%lu个目标",(unsigned long)[rectArr count]);
    
    //转换为图片
    UIImage *rectImg = [OpenCV imageWithColor:[UIColor redColor] size:tempImg.size rectArray:rectArr];
    
    return rectImg;
}


-(UIImage *) RegImage2:(UIImage* )img{
    if(!isSuccessLoadXml){
        return nil;
    }
    
    [NSThread sleepForTimeInterval:0.5];
    cv::Mat imgMat;
    
    UIImageToMat(img, imgMat);
        
    cv::cvtColor(imgMat, imgMat, cv::COLOR_BGR2GRAY);
    UIImage *tempImg = MatToUIImage(imgMat);
    
    //获取标记的矩形
    NSArray *rectArr = [self getTagRectInLayer:imgMat];
    
    NSLog(@"识别到%lu个目标",(unsigned long)[rectArr count]);
    
    //转换为图片
    UIImage *rectImg = [OpenCV imageWithColor:[UIColor redColor] size:tempImg.size rectArray:rectArr];
    
    return rectImg;
}

-(NSArray *)getTagRectInLayer:(cv::Mat) inputMat{
    if (inputMat.empty()) {
        return nil;
    }
    //图像均衡化
    cv::equalizeHist(inputMat, inputMat);
    //定义向量，存储识别出的位置
    std::vector<cv::Rect> glassess;
    //分类器识别
    icon_cascade.detectMultiScale(inputMat, glassess, 1.1, 3, 0);
    //转换为Frame，保存在数组中
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:glassess.size()];
    for (NSInteger i = 0; i < glassess.size(); i++) {
        CGRect rect = CGRectMake(glassess[i].x, glassess[i].y, glassess[i].width,glassess[i].height);
        NSValue *value = [NSValue valueWithCGRect:rect];
        [marr addObject:value];
    }
    return marr.copy;
}


+(UIImage *)toBinaryImage:(UIImage *)image{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    cv::Mat bin;
    cv::threshold(gray, bin, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    UIImage *binImg = MatToUIImage(bin);
    return binImg;
}
+(NSArray *)getVideoImage:(NSString *)path{
    
    if (![path isEqualToString:currentPath] && !cap.isOpened()){
        currentPath = path;
        cap.open(std::string(path.UTF8String));
    }
    if (cap.isOpened()){
        Mat originFrame, frame;
        if(cap.read(frame)){
            frame.copyTo(originFrame);
            cvtColor(frame, frame, CV_RGB2GRAY);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            adaptiveThreshold(frame, frame, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, 5, 2);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            threshold(frame, frame, 200, 255, THRESH_BINARY);
            bitwise_not(frame, frame);
            Mat ken = getStructuringElement(MORPH_RECT, cv::Size(3,3));
            morphologyEx(frame, frame, MORPH_OPEN, ken);
            ken.release();
            bitwise_not(frame, frame);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            
            return @[MatToUIImage(originFrame),MatToUIImage(frame)];
        }
        else{
            cap.release();
        }
       
    }
    return NULL;
}

+ (UIImage *)imageWithColor:(UIColor *)rectColor size:(CGSize)size rectArray:(NSArray *)rectArray{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // 1.开启图片的图形上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    // 2.获取
    CGContextRef cxtRef = UIGraphicsGetCurrentContext();
    
    // 3.矩形框标记颜色
    //获取目标位置
    for (NSInteger i = 0; i < rectArray.count; i++) {
        NSValue *rectValue = rectArray[i];
        CGRect targetRect = rectValue.CGRectValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:5];
        //加路径添加到上下文
        CGContextAddPath(cxtRef, path.CGPath);
        [rectColor setStroke];
        [[UIColor clearColor] setFill];
        //渲染上下文里面的路径
        /**
         kCGPathFill,   填充
         kCGPathStroke, 边线
         kCGPathFillStroke,  填充&边线
         */
        CGContextDrawPath(cxtRef,kCGPathFillStroke);
    }
    
    //填充透明色
    CGContextSetFillColorWithColor(cxtRef, [UIColor clearColor].CGColor);
    
    CGContextFillRect(cxtRef, rect);
    
    // 4.获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 6.返回图片
    return img;
}


@end
