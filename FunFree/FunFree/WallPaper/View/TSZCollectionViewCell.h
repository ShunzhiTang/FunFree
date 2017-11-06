//
//  TSZCollectionViewCell.h
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "TSZShopModel.h"

@interface TSZCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *shopImage;

@property (weak, nonatomic) IBOutlet UILabel *shopName;

@property (nonatomic ,strong) TSZShopModel *shopModel;



@end
