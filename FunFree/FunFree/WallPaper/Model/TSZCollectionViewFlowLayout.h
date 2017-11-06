//
//  TSZCollectionViewFlowLayout.h
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  TSZCollectionViewFlowLayout;

@protocol TSZCollectionViewFlowLayoutDelegate <NSObject>

- (CGFloat)waterFlow:(TSZCollectionViewFlowLayout *)waterFlow  heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPach;



@end


@interface TSZCollectionViewFlowLayout : UICollectionViewLayout

@property (nonatomic ,assign) UIEdgeInsets sectionInset;

@property (nonatomic ,assign) CGFloat rowMagrin;

@property (nonatomic ,assign) CGFloat colMagrim;

@property (nonatomic ,assign) CGFloat  colCount;

@property (nonatomic ,weak)  id<TSZCollectionViewFlowLayoutDelegate>  delegate;


@end
