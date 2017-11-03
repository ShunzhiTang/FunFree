//
//  FFTabBarController.h
//  sweetlove
//
//  Created by tang on 16/11/24.
//  Copyright © 2016年 TangFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    定义外部不可变的常量， 必须在.m 文件中进行初始化
 */

FOUNDATION_EXTERN NSString *const FFTabBarTitle;
FOUNDATION_EXTERN NSString *const FFTabBarItemImage;
FOUNDATION_EXTERN NSString *const FFTabBarItemSelectedImage;

// TabBarItem的数量
FOUNDATION_EXTERN NSUInteger FFTabBarItemdsCount;
// 一个模仿新浪微博的按钮的宽度
FOUNDATION_EXTERN CGFloat FFPlusButtonWidth;
FOUNDATION_EXTERN CGFloat FFTabBarItemWidth;

FOUNDATION_EXTERN NSString *const FFTabBarItemWidthDidChangeNotification;

@interface FFTabBarController : UITabBarController

/*!
     An array of the root view controllers displayed by the tab bar interface.

    一个tabBar界面显示的rootViewController的数组
 */
@property (nonatomic, readwrite, copy) NSArray<UIViewController *> *viewControllers;

/*!
 * The Attributes of items which is displayed on the tab bar.
    在tabBar上显示item的Attributes（属性）
 */

@property (nonatomic, readwrite, copy) NSArray<NSDictionary *> *tabBarItemsAttributes;

/**
    Customize UITabBar height
    定制的tabBar高度
 */
@property (nonatomic, assign) CGFloat tabBarHeight;

/*!
 * To set both UIBarItem image view attributes in the tabBar,
 * default is UIEdgeInsetsZero.
    tabBar 图片的内间距
 */
@property (nonatomic, readwrite, assign) UIEdgeInsets imageInsets;

/*!
 * To set both UIBarItem label text attributes in the tabBar,
 * use the following to tweak the relative position of the label within the tab
 button (for handling visual centering corrections if needed because of custom
 text attributes)

    tabBar 标题的位置调整
 */
@property (nonatomic, readwrite, assign) UIOffset titlePositionAdjustment;

#pragma mark : tabBar 的方法

/**
   初始化tabBar控制器的子控制器

 @param viewControllers 子控制器数组
 @param tabBarItemsAttributes tabBar item的属性
 @return  self
 */
- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes;

/**

  类方法
 初始化tabBar控制器的子控制器

 @param viewControllers 子控制器数组
 @param tabBarItemsAttributes tabBar item的属性
 @return self
 */
+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes;
/*!
 * Judge if there is plus button.
 */
//+ (BOOL)havePlusButton;

/*!
 * @attention Include plusButton if exists.
 */
+ (NSUInteger)allItemsInTabBarCount;

/**
 UIApplicationDelegate

 @return app delegate
 */
- (id<UIApplicationDelegate>)appDelegate;

/**

 主窗口
 @return rootWindow
 */

- (UIWindow *)rootWindow;

@end

#pragma mark : 一个重要的UITabBarController的extend 类

@interface NSObject (FFTabBarController)

/*!
 * If `self` is kind of `UIViewController`, this method will return the nearest
 ancestor in the view controller hierarchy that is a tab bar controller. If
 `self` is not kind of `UIViewController`, it will return the
 `rootViewController` of the `rootWindow` as long as you have set the
 `CYLTabBarController` as the  `rootViewController`. Otherwise return nil.
 (read-only)

    如果`self`是一种'UIViewController'，这个方法将返回视图控制器层次结构中最近的祖先，它是一个制表符条控制器。
 如果`self`不是一种`UIViewController`，只要你把`FFTabBarController`设置为`rootViewController`，它就会返回`rootWindow`的`rootViewController`。
 否则返回nil。 （只读）
 */

@property (nonatomic, readonly) FFTabBarController *tsz_tabBarController;

@end
