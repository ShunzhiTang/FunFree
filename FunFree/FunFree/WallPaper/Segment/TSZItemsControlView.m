//
//  TSZItemsControlView.m
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZItemsControlView.h"


@implementation  TSZItemsConfig

- (id)init{
    
    if (self = [super init]) {
        
        _itemWidth = 0;
        _itemFont = [UIFont boldSystemFontOfSize:16.0];
        _textColor = [UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1];
    
        _selectedColor = [UIColor  colorWithRed:61/255.0 green:209/255.0 blue:165/255.0 alpha:1];
        _linePercent = 0.8;
        _lineHeight = 2.5;
        
    }
    
    return self;
}


@end


@interface TSZItemsControlView()

@property (nonatomic , strong) UIView *line;

@end


@implementation TSZItemsControlView

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.tapAnimation = YES;
        
    }
    
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray{
    
    _titleArray = titleArray;
    
    if (!_config) {
        
        NSLog(@"请先设置config");
        return;
        
    }
    
    float x = 0;
    float y = 0;
    float width = _config.itemWidth;
    float height = self.frame.size.height;
    
    for (int i = 0; i < titleArray.count; i++) {
        
        x = _config.itemWidth * i ;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y,width , height)];
        btn.tag = 100 + i;
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn  setTitleColor:_config.textColor forState:UIControlStateNormal];
        btn.titleLabel.font = _config.itemFont;
        [btn addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        if (i == 0) {
            
            [btn  setTitleColor:_config.selectedColor forState:UIControlStateNormal];
            
            _currentIndex = 0;
            self.line = [[UIView  alloc] initWithFrame:CGRectMake(_config.itemWidth * (1- _config.linePercent) / 2.0, CGRectGetHeight(self.frame) - _config.lineHeight, _config.itemWidth * _config.linePercent , _config.lineHeight)];
            _line.backgroundColor = _config.selectedColor;
            [self addSubview:_line];
            
        }
        
    }
    
    self.contentSize = CGSizeMake(width * titleArray.count, height);
}

#pragma mark: 点击事件

- (void)itemButtonClick:(UIButton *)btn{
    
    //接入外部效果
    _currentIndex = btn.tag - 100;
    
    // 有动画 滚动改变线条 ， 改变颜色 _tapAnimation
       
    // 手动textColor
    [self changeItemColor:_currentIndex];
    
    // 改变线条
    [self changeLine:_currentIndex];
    // 改变 scrollOfSet
    [self changeScrollOfSet:_currentIndex];
    
    if (self.tapItemWithIndex) {
        _tapItemWithIndex(_currentIndex , _tapAnimation);
    }
    
}

- (void)changeItemColor:(NSInteger)index{
    
    for (int i = 0; i < _titleArray.count; i++) {
        
        UIButton *btn = (UIButton *)[self viewWithTag: i + 100];
        
        [btn setTitleColor:_config.textColor forState:UIControlStateNormal];
        
        if (btn.tag == index + 100) {
            
            [btn setTitleColor:_config.selectedColor forState:UIControlStateNormal];
            
        }
        
    }
    
}

- (void)changeLine:(NSInteger)index{
    
    CGRect rect = _line.frame;
    
    rect.origin.x  = index *_config.itemWidth + _config.itemWidth * (1 - _config.linePercent) / 2.0;
    
    _line.frame = rect;
    
}

// 移动scrollview

- (void)changeScrollOfSet:(NSInteger)index{
    
    float  halfWidth = CGRectGetWidth(self.frame) / 2.0;
    
    float scrollWidth = self.contentSize.width;
    
    float leftSpace = _config.itemWidth * index - halfWidth + _config.itemWidth / 2.0;
    
    if (leftSpace < 0) {
        leftSpace = 0;
    }
    
    if (leftSpace > scrollWidth - 2 * halfWidth) {
        
        leftSpace = scrollWidth - 2 * halfWidth;
        
    }
    
    [self setContentOffset:CGPointMake(leftSpace, 0) animated:YES];
}

#pragma mark: 在ScrollView Delegate中回调

- (void)moveToIndex:(float)x{
    
    [self changeLine:x];
    
//    NSInteger tempIndex = ceil(x);
    NSInteger tempIndex = [self changeProgressToIndex:x];
    
    if (tempIndex != _currentIndex) {
        
        [self changeItemColor:tempIndex];
        
    }
    
    _currentIndex = tempIndex;
    
}

- (void)endMoveToIndex:(float)x{
    
    [self changeLine:x];
    [self changeItemColor:x];
    _currentIndex = x;
    
    [self changeScrollOfSet:x];
}



// 向上取整

- (NSInteger)changeProgressToIndex:(float)x{
    
    float max = _titleArray.count;
    float min = 0;
    
    NSInteger index = 0;
    
    if (x < min + 0.5) {
        index = min;
    }else if(x >= max - 0.5){
        
        index = max;
        
    }else{
        index = (x + 0.5);
    }
    
    return index;
}


@end
