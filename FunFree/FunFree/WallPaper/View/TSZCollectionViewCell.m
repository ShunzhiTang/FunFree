//
//  TSZCollectionViewCell.m
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation TSZCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setShopModel:(TSZShopModel *)shopModel
{
    _shopModel = shopModel;
    
    [self.shopImage  sd_setImageWithURL:[NSURL URLWithString:_shopModel.img]];
    
    self.shopName.hidden = YES;
    
}

@end
