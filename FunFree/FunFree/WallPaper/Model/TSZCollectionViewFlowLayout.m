//
//  TSZCollectionViewFlowLayout.m
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZCollectionViewFlowLayout.h"

@interface TSZCollectionViewFlowLayout()

@property (nonatomic , strong)NSMutableDictionary *maxYDict;

@end

@implementation TSZCollectionViewFlowLayout

- (NSMutableDictionary *)maxYDict{
    
    if (!_maxYDict) {
        
        self.maxYDict = [[NSMutableDictionary alloc] init];
        
    }
    return _maxYDict;
}

- (instancetype)init{
    
    if (self = [super init]) {
        
        self.colCount = 3;
        self.rowMagrin = 10;
        self.colMagrim = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
    }
    
    return self;
}

- (void)prepareLayout{
    
    [super prepareLayout];
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    return YES;
}

- (CGSize)collectionViewContentSize{
    
    __block NSString *maxCol = @"0";
    
    // 找出最短的列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString  *column, NSNumber *maxY, BOOL * _Nonnull stop) {
       
        if ([maxY floatValue] > [self.maxYDict[maxCol] floatValue]) {
            
            maxCol = column;
            
        }
        
    }];
    
    return CGSizeMake(0, [self.maxYDict[maxCol] floatValue]);
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __block NSString *minCol = @"0";
    
    // 找出最短的列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^( NSString *column , NSNumber  *maxY, BOOL * _Nonnull stop) {
       
        if ([maxY  floatValue] < [self.maxYDict[minCol] floatValue]) {
            minCol = column;
        }
        
    }];
    
    // 计算宽度
    CGFloat  width  = (self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - (self.colCount -1) *self.colMagrim) / self.colCount;
    
    // 计算高度
    
    CGFloat hight = [self.delegate waterFlow:self heightForWidth:width atIndexPath:indexPath];
    
    CGFloat x = self.sectionInset.left + (width + self.colMagrim) * [minCol intValue];
    
    CGFloat y = [self.maxYDict[minCol] floatValue] + self.rowMagrin;
    
    // 距离最大的值
    self.maxYDict[minCol] = @(y + hight);
    
    // 计算位置
    UICollectionViewLayoutAttributes *attri = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attri.frame = CGRectMake(x, y, width, hight);
    
    return attri;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    for (int i = 0; i < self.colCount; i++) {
        
        NSString *col = [NSString stringWithFormat:@"%d", i];
        
        self.maxYDict[col] = @0;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0 ];
    
    for (int j = 0; j < count ; j++) {
    
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j  inSection:0]];
        
        [array addObject:attrs];
    }
    
    return array;
}



@end
