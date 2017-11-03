//
//  UIViewController+FFTabBarControllerExtention.m
//  sweetlove
//
//  Created by tang on 16/11/24.
//  Copyright © 2016年 TangFeng. All rights reserved.
//

#import "UIViewController+FFTabBarControllerExtention.h"
#import "FFTabBarController.h"

@implementation UIViewController (FFTabBarControllerExtention)

- (UIViewController *)tsz_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index{
    
    // 先检查当前选中的控制器
    [self checkTabBarChildControllerValidityAtIndex:index];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    FFTabBarController *tabBarController = [self tsz_tabBarController];
    
    tabBarController.selectedIndex = index;
    UIViewController *selectedTabBarChildViewController = tabBarController.selectedViewController;
    // 是否是nav的对象
    BOOL isNavigationController = [[selectedTabBarChildViewController class] isSubclassOfClass:[UINavigationController class]];
    // 如果当前选中的是 navgationController 就返回UINavigationController 的第一个viewControiller
    if (isNavigationController) {
        
        return ((UINavigationController *)selectedTabBarChildViewController).viewControllers[0];
    }
    
    //返回选择的子控制器
    return selectedTabBarChildViewController;
}

- (void)tsz_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index completion:(FFPopSelectTabBarChildViewControllerCompletion)completion{
    
    UIViewController *selectedTabBarChildViewController = [self tsz_popSelectTabBarChildViewControllerAtIndex:index];
    
    // 主线程返回 当前选中的控制器
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        !completion ? :completion(selectedTabBarChildViewController);
        
    });
    
}


// 类类型
- (UIViewController *)tsz_popSelectTabBarChildViewControllerForClassType:(Class)classType{
    
    FFTabBarController *tabBarController = [self tsz_tabBarController];
    
    __block NSUInteger atIndex = NSNotFound;
    
    [tabBarController.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        id objVc = nil;
        
        BOOL isNavController = [[tabBarController.viewControllers[idx] class] isSubclassOfClass:[UINavigationController class]];
        
        if (isNavController) {
            
            objVc = ((UINavigationController *)obj).viewControllers[0];
        }else{
            
            objVc = obj;
            
        }
        
        if ([objVc isKindOfClass:classType]) {
            
            atIndex = idx;
            *stop   = YES;
            return ;
        }
        
        
    }];
    
    return [self tsz_popSelectTabBarChildViewControllerAtIndex:atIndex];
    
}

- (void)tsz_popSelectTabBarChildViewControllerForClassType:(Class)classType completion:(FFPopSelectTabBarChildViewControllerCompletion)completion{
    
    UIViewController *selectedTabBarChildViewController = [self tsz_popSelectTabBarChildViewControllerForClassType:classType];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        !completion ?: completion(selectedTabBarChildViewController);
        
    });
    
}


#pragma mark: 检查私有方法


/**
    检查当前索引对用的子控制器是否有效

 @param index index索引
 */
- (void)checkTabBarChildControllerValidityAtIndex:(NSUInteger)index {
    
    
    FFTabBarController *tabBarController = [self tsz_tabBarController];
    
    @try {
        UIViewController *viewController;
        viewController = tabBarController.viewControllers[index];
    } @catch (NSException *exception) {
        
        NSString *formatString = @"\n\n\
        ------ BEGIN NSException Log ---------------------------------------------------------------------\n \
        class name: %@                                                                                    \n \
        ------line: %@                                                                                    \n \
        ----reason: The Class Type or the index or its NavigationController(或者他的继承子类) you pass in method `-tsz_popSelectTabBarChildViewControllerAtIndex` or `-tsz_popSelectTabBarChildViewControllerForClassType` is not the item of CYLTabBarViewController \n \
        ------ END ---------------------------------------------------------------------------------------\n\n";
        
        NSString  *reason = [NSString stringWithFormat:formatString,
                             @(__PRETTY_FUNCTION__),
                             @(__LINE__)];
        
        // 抛出异常 ， 为了很好的查看异常
        @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
    }
    
}

@end
