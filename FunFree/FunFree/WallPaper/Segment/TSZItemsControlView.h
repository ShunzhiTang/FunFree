//
//  TSZItemsControlView.h
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSZItemsConfig : NSObject

@property (nonatomic ,assign) float itemWidth;
@property (nonatomic ,strong) UIFont *itemFont;
@property (nonatomic ,strong) UIColor *textColor;
@property (nonatomic ,strong) UIColor  *selectedColor;

@property (nonatomic ,assign)  float linePercent;
@property (nonatomic ,assign)  float lineHeight;


@end

typedef void (^TSZControlViewTapBlock) (NSInteger index , BOOL animation);


@interface TSZItemsControlView : UIScrollView

@property (nonatomic ,strong) TSZItemsConfig *config;

@property (nonatomic ,strong) NSArray * titleArray;

@property (nonatomic ,assign) BOOL tapAnimation ;

@property (nonatomic ,assign) NSInteger currentIndex;

@property (nonatomic ,copy) TSZControlViewTapBlock  tapItemWithIndex;

- (void)moveToIndex:(float)index; // called in scrollViewDidScroll



- (void)endMoveToIndex:(float)index; //called in scrollViewDidEndDecelerating

@end
