//
//  ClickImage.h
//  Library
//
//  Created by Stan Hu on 2023/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClickImage : UIImageView<UIScrollViewDelegate>{
    BOOL isChanged;
    CGRect defaultRect;
    UIImageView *Im;
    UIWindow *window;
    UIImage *fakeImage;
    UIViewController *clickViewController;
    UIView *snapView;
}
// !@brief 为YES时，点击图片有放大到全屏的动画效果，再次点击缩小到原始坐标动画效果
@property (nonatomic ,assign, setter = canClickIt:) BOOL canClick;
@property (nonatomic ,assign) float duration;//动画时间

// !@brief 设定点击时要加载的ViewController,加载方式和消失方式是presentViewController和dismissViewController
- (void)setClickToViewController:(UIViewController*)cViewController;

// !@brief 调用此方法移除子视图
+ (void)dismissClickView;
@end
//代理型，只提供简单功能
@interface UIImageView (Click)

// !@brief 为YES时，点击图片有放大到全屏的动画效果，再次点击缩小到原始坐标动画效果
@property (nonatomic ,assign, setter = canClickIt:) BOOL canClick;

@end


@interface UIButton (Click)

// !@brief 为YES时，点击图片有放大到全屏的动画效果，再次点击缩小到原始坐标动画效果
@property (nonatomic ,assign, setter = canClickIt:) BOOL canClick;

@end



NS_ASSUME_NONNULL_END
