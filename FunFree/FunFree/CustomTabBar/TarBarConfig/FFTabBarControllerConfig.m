//
//  FFTabBarControllerConfig.m
//  sweetlove
//
//  Created by tang on 16/11/24.
//  Copyright © 2016年 TangFeng. All rights reserved.
//

#import "FFTabBarControllerConfig.h"
#import "FFCustomNavigationController.h"
#import "FFHomeViewController.h"
#import "FFMineViewController.h"
#import "FFSettingViewController.h"

@interface FFTabBarControllerConfig ()

@property (nonatomic, readwrite, strong) FFTabBarController *tabBarController;

@end

@implementation FFTabBarControllerConfig

- (FFTabBarController *)tabBarController {

    if (_tabBarController == nil) {

        FFTabBarController *tabBarController =
            [FFTabBarController tabBarControllerWithViewControllers:self.viewControllers
                                              tabBarItemsAttributes:self.tabBarItemsAttributesForController];

        [self customizeTabBarAppearance:tabBarController];

        _tabBarController = tabBarController;
    }

    return _tabBarController;
}

#pragma mark : private method

- (NSArray *)viewControllers {

    FFHomeViewController *homeVc = [[FFHomeViewController alloc] init];

    UINavigationController *homeNav = [[FFCustomNavigationController alloc] initWithRootViewController:homeVc];

    // other
    FFSettingViewController *otherVc = [[FFSettingViewController alloc] init];

    UINavigationController *otherNav = [[FFCustomNavigationController alloc] initWithRootViewController:otherVc];
    // mine
    FFMineViewController *mineVc = [[FFMineViewController alloc] init];

    UINavigationController *mineNav = [[FFCustomNavigationController alloc] initWithRootViewController:mineVc];

    NSArray *viewControllers = @[ homeNav, otherNav, mineNav ];

    return viewControllers;
}
- (NSArray *)tabBarItemsAttributesForController {

    NSDictionary *dict1 = @{
        FFTabBarTitle : @"主页",
        FFTabBarItemImage : @"shopping",
        FFTabBarItemSelectedImage : @"choose_shopping",
    };

    NSDictionary *dict3 = @{
        FFTabBarTitle : @"设置",
        FFTabBarItemImage : @"change",
        FFTabBarItemSelectedImage : @"choose_change",
    };

    NSDictionary *dict4 = @{
        FFTabBarTitle : @"个人中心",
        FFTabBarItemImage : @"mine",
        FFTabBarItemSelectedImage : @"choose_mine",
    };

    NSArray *tabBarItemsAttributes = @[ dict1, dict3, dict4 ];
    return tabBarItemsAttributes;
}

/**
 *  更多TabBar自定义设置：比如：tabBarItem
 * 的选中和不选中文字和背景图片属性、tabbar 背景图片属性等等
 */
- (void)customizeTabBarAppearance:(FFTabBarController *)tabBarController {
    // Customize UITabBar height
    // 自定义 TabBar 高度
    tabBarController.tabBarHeight = 49.f;
    if ([UIScreen mainScreen].bounds.size.height == 812) {
        tabBarController.tabBarHeight = 83.0;
    }

    // set the text color for unselected state
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];

    // set the text color for selected state
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor greenColor];

    // set the text Attributes
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];

    // Set the dark color to selected tab (the dimmed background)
    // TabBarItem选中后的背景颜色
    // [self customizeTabBarSelectionIndicatorImage];

    // update TabBar when TabBarItem width did update
    // If your app need support UIDeviceOrientationLandscapeLeft or
    // UIDeviceOrientationLandscapeRight， remove the comment '//'
    // 如果你的App需要支持横竖屏，请使用该方法移除注释 '//'
    // [self updateTabBarCustomizationWhenTabBarItemWidthDidUpdate];

    // set the bar shadow image
    // This shadow image attribute is ignored if the tab bar does not also have a
    // custom background image.So at least set somthing.
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    //    [[UITabBar appearance] setShadowImage:[UIImage
    //    imageNamed:@"tapbar_top_line"]];

    // set the bar background image
    // 设置背景图片
    // UITabBar *tabBarAppearance = [UITabBar appearance];
    // [tabBarAppearance setBackgroundImage:[UIImage
    // imageNamed:@"tabbar_background"]];

    // remove the bar system shadow image
    // 去除 TabBar 自带的顶部阴影
    // [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

// 如果你的App需要支持横竖屏，请使用该方法移除注释 '//'

- (void)updateTabBarCustomizationWhenTabBarItemWidthDidUpdate {
    void (^deviceOrientationDidChangeBlock)(NSNotification *) = ^(NSNotification *notification) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) {
            NSLog(@"Landscape Left or Right !");
        } else if (orientation == UIDeviceOrientationPortrait) {
            NSLog(@"Landscape portrait!");
        }
        [self customizeTabBarSelectionIndicatorImage];
    };
    [[NSNotificationCenter defaultCenter] addObserverForName:FFTabBarItemWidthDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:deviceOrientationDidChangeBlock];
}

- (void)customizeTabBarSelectionIndicatorImage {
    /// Get initialized TabBar Height if exists, otherwise get Default TabBar
    /// Height.
    UITabBarController *tabBarController = [self tsz_tabBarController] ?: [[UITabBarController alloc] init];
    CGFloat tabBarHeight = tabBarController.tabBar.frame.size.height;
    CGSize selectionIndicatorImageSize = CGSizeMake(FFTabBarItemWidth, tabBarHeight);
    // Get initialized TabBar if exists.
    UITabBar *tabBar = [self tsz_tabBarController].tabBar ?: [UITabBar appearance];
    [tabBar
        setSelectionIndicatorImage:[[self class] imageWithColor:[UIColor redColor] size:selectionIndicatorImageSize]];
}

// color 转uiimage

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0)
        return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width + 1, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
