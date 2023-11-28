//
//  ClickImage.m
//  Library
//
//  Created by Stan Hu on 2023/11/28.
//

#import "ClickImage.h"

CGRect goBackRect;
float goBackDuration;
UIScrollView* goBackgroundView;
UIImageView* goBackImageView;
UIImageView* goBackFakeImageView;
UIViewController* goBackViewController;
UIImageView *imageView;
@implementation ClickImage
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //fakeImage = [[UIImage alloc]init];
    }
    return self;
}
- (void)canClickIt:(BOOL)click {
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIt:)];
    if (click==YES) {
        
        [touch setNumberOfTapsRequired:1];
        self.userInteractionEnabled = YES;
        _duration = 0.3;
        [self addGestureRecognizer:touch];
    }
    else
    {
        [self removeGestureRecognizer:touch];
    }
}

- (void)tapIt:(UIGestureRecognizer*)sender {
    [self showImage:(UIImageView*)sender.view];
}

- (void)showImage:(UIImageView *)defaultImageView{
    if (self.image == nil) {
        return;
    }
    goBackDuration = _duration;
    UIImage *image = defaultImageView.image;
    window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [defaultImageView convertRect:defaultImageView.bounds toView:window]; //关键代码，坐标系转换
    goBackgroundView.backgroundColor = [UIColor blackColor];// colorWithRed:0 green:0 blue:0 alpha:0
    goBackgroundView.minimumZoomScale = 1;
    goBackgroundView.maximumZoomScale = 2.5;
    goBackgroundView.delegate =self;
    imageView = [[UIImageView alloc]initWithFrame:defaultRect];
    imageView.image = image;
    imageView.tag = 1;
    [goBackgroundView addSubview:imageView];
    [window addSubview:goBackgroundView];
    if (clickViewController!=nil) {
        //截图
        UIImageView *fakeImageView = [[UIImageView alloc]initWithFrame:defaultRect];
        [goBackgroundView addSubview:fakeImageView];
        if (!snapView) {
            snapView = clickViewController.view;
        }
        if(&UIGraphicsBeginImageContextWithOptions != NULL)
        {
            UIGraphicsBeginImageContextWithOptions(snapView.frame.size, NO, 0.0);
        } else {
           
        }
        [snapView.layer renderInContext:UIGraphicsGetCurrentContext()];
        fakeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        fakeImageView.image = fakeImage;
        [UIView animateWithDuration:_duration animations:^{
            imageView.alpha = 0;
            imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            fakeImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:(_duration/2) animations:^{
                goBackImageView = imageView;
                goBackFakeImageView = fakeImageView;
                goBackRect = defaultRect;
                
            } completion:^(BOOL finished) {
                goBackgroundView.alpha = 0;
                for (UIView* next = [self superview]; next; next = next.superview) {
                    UIResponder *nextResponder = [next nextResponder];
                    if ([nextResponder isKindOfClass:[UIViewController class]]) {
                        [((UIViewController*)nextResponder) presentViewController:clickViewController animated:NO completion:^{
                            ;
                        }];//可更改为UINavigation推入
                    }
                }
                goBackViewController = clickViewController;
            }];
        }];
    } else {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        [goBackgroundView addGestureRecognizer:tap];
        defaultImageView.alpha = 0;
        [UIView animateWithDuration:_duration animations:^{
            imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
            goBackgroundView.backgroundColor=[UIColor blackColor];
            
        } completion:^(BOOL finished) {
        }];
    }
}
+ (void)dismissClickView {
    UIView *snapView = goBackViewController.view;
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(snapView.frame.size, NO, 0.0);
    } else {
     
    }
    [snapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    goBackFakeImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    goBackgroundView.alpha = 1;
    [goBackViewController dismissViewControllerAnimated:NO completion:^{
        ;
    }];
    [UIView animateWithDuration:goBackDuration animations:^{
        goBackImageView.alpha = 1;
        goBackImageView.frame = goBackRect;
        goBackFakeImageView.frame = goBackRect;
    } completion:^(BOOL finished) {
        goBackViewController = nil;
        [goBackgroundView removeFromSuperview];
    }];
}

- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [goBackgroundView setZoomScale:1];
    [UIView animateWithDuration:_duration animations:^{
        imageView.frame = defaultRect;
        goBackgroundView.backgroundColor=[UIColor blackColor];
    } completion:^(BOOL finished) {
        self.alpha = 1;
        [goBackgroundView removeFromSuperview];
    }];
}

- (void)setClickToViewController:(UIViewController*)cViewController {
    clickViewController = cViewController;
}

-(UIView* ) viewForZoomingInScrollView:(UIScrollView *)scrollView //放大事件
{
    return imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat offsetX = (goBackgroundView.bounds.size.width > goBackgroundView.contentSize.width)?
    (goBackgroundView.bounds.size.width - goBackgroundView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (goBackgroundView.bounds.size.height > goBackgroundView.contentSize.height)?
    (goBackgroundView.bounds.size.height - goBackgroundView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(goBackgroundView.contentSize.width * 0.5 + offsetX,
                                   goBackgroundView.contentSize.height * 0.5 + offsetY);
}


@end
@implementation UIImageView (Click)
@dynamic canClick;
CGRect defaultFrame;
id dImageView;
UIScrollView *backgroundView;
UILabel *currentImageTitleLable;
UIImageView *imageView;
- (void)canClickIt:(BOOL)click {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIt:)];
    if (click) {
        [tap setNumberOfTapsRequired:1];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
    }
    else
    {
        [self removeGestureRecognizer:tap];
    }
    
}

- (void)tapIt:(UIGestureRecognizer*)sender {
    [UIImageView showImage:(UIImageView*)sender.view];
}
+ (void)showImage:(UIImageView *)defaultImageView{
    UIImage *image = defaultImageView.image;
    if (image == nil) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    backgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    //关键代码，坐标系转换
    defaultFrame = [defaultImageView convertRect:defaultImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0;
    dImageView = defaultImageView;
    imageView = [[UIImageView alloc]initWithFrame:defaultFrame];
    imageView.image = image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    if (currentImageTitleLable) {
        [backgroundView addSubview:currentImageTitleLable];
        
    }
    [UIView animateWithDuration:0.5 animations:^{
        defaultImageView.alpha = 0;
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

+ (void)hideImage:(UITapGestureRecognizer*)tap{
    
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = defaultFrame;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        ((UIImageView*)dImageView).alpha = 1;
        [backgroundView removeFromSuperview];
    }];
}

@end


@implementation UIButton (Click)
@dynamic canClick;
CGRect defaultFrame;
id dImageView;
UIScrollView *backgroundView;
UILabel *currentImageTitleLable;
UIImageView *imageView;
- (void)canClickIt:(BOOL)click {
    
    if (click) {
        [self addTarget:self action:@selector(tapIt:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self removeTarget:self action:@selector(tapIt:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)tapIt:(UIButton*)sender {
    [UIButton showImage:sender.imageView];
}
+ (void)showImage:(UIImageView *)defaultImageView{
    UIImage *image = defaultImageView.image;
    if (image == nil) {
        
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    backgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    //关键代码，坐标系转换
    defaultFrame = [defaultImageView convertRect:defaultImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0;
    dImageView = defaultImageView;
    imageView = [[UIImageView alloc]initWithFrame:defaultFrame];
    imageView.image = image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    if (currentImageTitleLable) {
        [backgroundView addSubview:currentImageTitleLable];
        
    }
    [UIView animateWithDuration:0.5 animations:^{
        defaultImageView.alpha = 0;
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

+ (void)hideImage:(UITapGestureRecognizer*)tap{
    
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = defaultFrame;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        ((UIImageView*)dImageView).alpha = 1;
        [backgroundView removeFromSuperview];
    }];
}



@end
