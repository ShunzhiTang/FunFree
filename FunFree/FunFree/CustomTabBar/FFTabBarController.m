//
//  FFTabBarController.m
//  sweetlove
//
//  Created by tang on 16/11/24.
//  Copyright © 2016年 TangFeng. All rights reserved.
//

#import "FFTabBarController.h"
#import "FFCustomTabBar.h"
#import <objc/runtime.h>

// 变量的初始化
NSString *const FFTabBarTitle = @"FFTabBarTitle";
NSString *const FFTabBarItemImage = @"FFTabBarItemImage";
NSString *const FFTabBarItemSelectedImage = @"FFTabBarItemSelectedImage";

// TabBarItem的数量
NSUInteger FFTabBarItemdsCount = 0;
// 一个模仿新浪微博的按钮的宽度
CGFloat FFPlusButtonWidth = 0;
CGFloat FFTabBarItemWidth = 0.0;

NSString *const FFTabBarItemWidthDidChangeNotification = @"FFTabBarItemWidthDidChangeNotification";

#pragma mark : 项目内部的一个类

@interface NSObject (FFTabBarControllerItemInternal)

/**
  设置tabBarController

 @param tabBarController void
 */
- (void)tsz_setTabBarController:(FFTabBarController *)tabBarController;

@end

@interface FFTabBarController () <UITabBarControllerDelegate>

// 观察可交换ImageView默认偏移

@property (nonatomic, assign, getter=isObservingSwappableImageViewDefaultOffset)
    BOOL observingSwappableImageViewDefaultOffset;

@end

@implementation FFTabBarController

@synthesize viewControllers = _viewControllers;

#pragma mark : Life Cycle 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    // 处理tabBar ， 使用自定义tabBar

    [self setUpTabBar];

    // KVO 注册监听
    self.delegate = self;
}

- (void)viewWillLayoutSubviews {

    if (!self.tabBarHeight) {
        return;
    }

    // 设置tabBar的frame
    self.tabBar.frame = ({

        CGRect frame = self.tabBar.frame;

        CGFloat tabBarHeight = self.tabBarHeight;
        frame.size.height = tabBarHeight;
        frame.origin.y = self.view.frame.size.height - tabBarHeight;

        frame;
    });
}

#pragma mark : FFTabBarController 的 public methods

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {

    if (self = [super init]) {

        _tabBarItemsAttributes = tabBarItemsAttributes;
        self.viewControllers = viewControllers;
    }

    return self;
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {

    FFTabBarController *tabBarController = [[FFTabBarController alloc] initWithViewControllers:viewControllers
                                                                         tabBarItemsAttributes:tabBarItemsAttributes];

    return tabBarController;
}

+ (NSUInteger)allItemsInTabBarCount {

    NSUInteger allItemsInTabBarCount = FFTabBarItemdsCount;

    return allItemsInTabBarCount;
}

- (id<UIApplicationDelegate>)appDelegate {

    return [UIApplication sharedApplication].delegate;
}

- (UIWindow *)rootWindow {

    UIWindow *resultWindow = nil;

    do {

        if ([self.appDelegate respondsToSelector:@selector(window)]) {
            resultWindow = [self.appDelegate window];
        }

        if (resultWindow) {
            break;
        }

    } while (NO);

    return resultWindow;
}

#pragma FFTabBarController 的private method

/**
    处理tabBar ， 使用自定义tabBar
 */
- (void)setUpTabBar {

    // warning  利用 KVC 把系统的 tabBar 类型改为自定义类型。

    [self setValue:[[FFCustomTabBar alloc] init] forKey:@"tabBar"];
}

- (void)setViewControllers:(NSArray *)viewControllers {

    if (_viewControllers && _viewControllers.count) {

        for (UIViewController *viewController in _viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }

    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {

        _viewControllers = [viewControllers copy];

        FFTabBarItemdsCount = [viewControllers count];

        FFTabBarItemWidth = ([UIScreen mainScreen].bounds.size.width) / (FFTabBarItemdsCount);

        NSUInteger idx = 0;

        for (UIViewController *viewController in self.viewControllers) {

            NSString *title = nil;
            NSString *normalImageName = nil;
            NSString *selectedImageName = nil;

            title = _tabBarItemsAttributes[idx][FFTabBarTitle];
            normalImageName = _tabBarItemsAttributes[idx][FFTabBarItemImage];
            selectedImageName = _tabBarItemsAttributes[idx][FFTabBarItemSelectedImage];

            // 增加子控制器
            [self addOneChildViewController:viewController
                                  WithTitle:title
                            normalImageName:normalImageName
                          selectedImageName:selectedImageName];

            // 在这里添加的时间就是使用的运行时去处理的，改变运行时执行（tabBarController）的方法
            // ，用tsz_tabBarController去代替进行关联

            [viewController tsz_setTabBarController:self];

            idx++;
        }

    } else {

        for (UIViewController *viewController in _viewControllers) {

            [viewController tsz_setTabBarController:nil];
        }

        _viewControllers = nil;
    }
}

/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param normalImageName   图片
 *  @param selectedImageName 选中图片
 */

- (void)addOneChildViewController:(UIViewController *)viewController
                        WithTitle:(NSString *)title
                  normalImageName:(NSString *)normalImageName
                selectedImageName:(NSString *)selectedImageName {

    viewController.tabBarItem.title = title;

    if (normalImageName) {

        UIImage *normalImage = [UIImage imageNamed:normalImageName];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        viewController.tabBarItem.image = normalImage;
    }

    if (selectedImageName) {

        UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
        // 渲染模式
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        viewController.tabBarItem.selectedImage = selectedImage;
    }

    // tabBarItem 的内外边距

    // viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    // 定制 image 的 insets
    if (self.shouldCustomizeImageInsets) {

        viewController.tabBarItem.imageInsets = self.imageInsets;
    }

    if (self.shouldCustomizeTitlePositionAdjustment) {

        viewController.tabBarItem.titlePositionAdjustment = self.titlePositionAdjustment;
    }

    [self addChildViewController:viewController];
}

- (BOOL)shouldCustomizeImageInsets {
    BOOL shouldCustomizeImageInsets = self.imageInsets.top != 0.f || self.imageInsets.left != 0.f ||
                                      self.imageInsets.bottom != 0.f || self.imageInsets.right != 0.f;
    return shouldCustomizeImageInsets;
}

- (BOOL)shouldCustomizeTitlePositionAdjustment {
    BOOL shouldCustomizeTitlePositionAdjustment =
        self.titlePositionAdjustment.horizontal != 0.f || self.titlePositionAdjustment.vertical != 0.f;
    return shouldCustomizeTitlePositionAdjustment;
}

#pragma mark - KVO Method

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
    shouldSelectViewController:(UIViewController *)viewController {

    return YES;
}

@end

#pragma mark : --FFTabBarControllerItemInternal

@implementation NSObject (FFTabBarControllerItemInternal)

- (void)tsz_setTabBarController:(FFTabBarController *)tabBarController {

    // 使用运行时进行关联

    objc_setAssociatedObject(self, @selector(tsz_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end

// 下面的这个 类的方法

@implementation NSObject (FFTabBarController)

- (FFTabBarController *)tsz_tabBarController {

    FFTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(tsz_tabBarController));

    if (tabBarController) {

        return tabBarController;
    }

    // 当前的控制器就是parentViewController 就显示这个tabBarItem

    if ([self isKindOfClass:[UIViewController class]] && [(UIViewController *)self parentViewController]) {

        tabBarController = [[(UIViewController *)self parentViewController] tsz_tabBarController];

        return tabBarController;
    }

    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);

    UIWindow *window = delegate.window;

    if ([window.rootViewController isKindOfClass:[FFTabBarController class]]) {

        tabBarController = (FFTabBarController *)window.rootViewController;
    }

    return tabBarController;
}

@end
