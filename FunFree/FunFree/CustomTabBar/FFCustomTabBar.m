//
//  FFCustomTabBar.m
//  sweetlove
//
//  Created by tang on 16/11/24.
//  Copyright © 2016年 TangFeng. All rights reserved.
//

#import "FFCustomTabBar.h"

#import "FFTabBarController.h"

static void *const FFTabBarContext = (void *)&FFTabBarContext;

@interface FFCustomTabBar ()

@property (nonatomic , assign) CGFloat tabBarItemWidth;

@property (nonatomic ,copy) NSArray   *tabBarButtonArray;

@end

@implementation FFCustomTabBar

#pragma mark: LifeCycle Method

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self = [self sharedInit];
        
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self =  [self sharedInit];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGFloat tabBarWidth = self.bounds.size.width;
    
    FFTabBarItemWidth = tabBarWidth / FFTabBarItemdsCount;
    
    self.tabBarItemWidth = FFTabBarItemWidth;
    
    NSArray *sortedSubviews = [self  sortedSubviews];
    
    // tabBarButton
    self.tabBarButtonArray = [self tabBarButtonFromTabBarSubviews:sortedSubviews];
    
    // 设置可变换的image的位置
    [self setupSwappableImageViewDefaultOffset:self.tabBarButtonArray[0]];
    
    // 调整位置
    [self.tabBarButtonArray enumerateObjectsUsingBlock:^(UIView * _Nonnull childView, NSUInteger buttonIndex, BOOL * _Nonnull stop) {
       
        // 调整UITabBarItem的位置
        
        CGFloat childViewX;
        
        childViewX = buttonIndex * FFTabBarItemWidth ;
        //仅修改childView的x和宽度
        childView.frame = CGRectMake(childViewX, CGRectGetMinY(childView.frame), FFTabBarItemWidth, CGRectGetHeight(childView.frame));
        
        
    }];
}


#pragma mark: private 

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    
    return NO;
}


// kvo 监听执行

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (context != FFTabBarContext) {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
        
    }
    
    if (context == FFTabBarContext) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FFTabBarItemWidthDidChangeNotification object:self];
        
    }
}


- (instancetype)sharedInit{
    
    // KVO 注册监听
    _tabBarItemWidth = FFTabBarItemWidth;
    
    [self addObserver:self forKeyPath:@"tabBarItemWidth" options:NSKeyValueObservingOptionNew context:FFTabBarContext];
    
    return self;
}


/**
     给子视图进行排序

 @return 一个排好序的数组
 */
- (NSArray *)sortedSubviews{
    
    NSArray *sortedSubviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView *latterView) {
        
        CGFloat formerViewX = formerView.frame.origin.x;
        CGFloat latterViewX = latterView.frame.origin.x;
        return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
        
    }];
    
    return sortedSubviews;
}


/**
    找到TabBarSubviews 中的tabBarButton

 @param tabBarSubviews subviews
 @return tabBarButtons
 */
- (NSArray *)tabBarButtonFromTabBarSubviews:(NSArray *)tabBarSubviews{
    
    NSMutableArray *tabBarButtonMutable = [NSMutableArray arrayWithCapacity:tabBarSubviews.count - 1];
    
    [tabBarSubviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            [tabBarButtonMutable addObject:obj];
        }
        
    }];
    
    return [tabBarButtonMutable copy];
}


/**
    设置tabBarButton上image的位置

 @param tabBarButton tabBarButton
 */
- (void)setupSwappableImageViewDefaultOffset:(UIView *)tabBarButton{
    
    __block BOOL shouldCustomizeImageView = YES;
    __block CGFloat swappableImageViewHeight = 0.f;
    __block CGFloat swappableImageViewDefaultOffset = 0.f;
    
    CGFloat tabBarHeight = self.frame.size.height;
    
    [tabBarButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")]) {
            
            shouldCustomizeImageView = NO;
        }
        
        swappableImageViewHeight = obj.frame.size.height;
        BOOL  isSwappleImgView = [obj isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")];
        if (isSwappleImgView) {
            
            swappableImageViewDefaultOffset = (tabBarHeight - swappableImageViewHeight) * 0.5 * 0.5;
        }
        
        if (isSwappleImgView && swappableImageViewDefaultOffset == 0.f) {
            shouldCustomizeImageView = NO;
        }
        
    }];
    
    if (shouldCustomizeImageView) {
        
        self.swappableImageViewDefaultOffset = swappableImageViewDefaultOffset;
    }
    
}


#pragma mark: lazy getter

- (NSArray *)tabBarButtonArray{
    
    if (_tabBarButtonArray == nil) {
        
        _tabBarButtonArray = [[NSArray alloc] init];
        
    }
    
    return _tabBarButtonArray;
}

- (void)setSwappableImageViewDefaultOffset:(CGFloat)swappableImageViewDefaultOffset{
    
    if (swappableImageViewDefaultOffset != 0.f) {
        [self willChangeValueForKey:@"swappableImageViewDefaultOffset"];
        _swappableImageViewDefaultOffset = swappableImageViewDefaultOffset;
        [self didChangeValueForKey:@"swappableImageViewDefaultOffset"];
    }
    
}

- (void)setTabBarItemWidth:(CGFloat )tabBarItemWidth {
    if (_tabBarItemWidth != tabBarItemWidth) {
        [self willChangeValueForKey:@"tabBarItemWidth"];
        _tabBarItemWidth = tabBarItemWidth;
        [self didChangeValueForKey:@"tabBarItemWidth"];
    }
}

- (void)dealloc{
    
    // 移除注册
    
    [self removeObserver:self forKeyPath:@"tabBarItemWidth"];
    
}

#pragma  mark: 在超出tarBar部分也可以点击
/*!
 *  Capturing touches on a subview outside the frame of its superview.
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    BOOL canNotResponseEvent = self.hidden || (self.alpha <= 0.01f) || (self.userInteractionEnabled == NO);
    
    if (canNotResponseEvent) {
        return nil;
    }
    
    NSArray *tabBarButtons = self.tabBarButtonArray;
    if (self.tabBarButtonArray.count == 0) {
        
        tabBarButtons = [self tabBarButtonFromTabBarSubviews:self.subviews];
        
    }
    
    for (NSUInteger index = 0; index < tabBarButtons.count; index++) {
        
        UIView *selectedTabBarButton = tabBarButtons[index];
        
        CGRect selectedTabBarButtonFrame = selectedTabBarButton.frame;
        
        if (CGRectContainsPoint(selectedTabBarButtonFrame, point)) {
            
            return selectedTabBarButton;
        }
        
    }
    
    return nil;
}



@end
