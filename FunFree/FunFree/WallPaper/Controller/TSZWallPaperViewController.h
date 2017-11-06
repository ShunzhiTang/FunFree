//
//  TSZWallPaperViewController.h
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^WallPaperDidFinishChooseImageBlock) (NSString *imageUrl);


@interface TSZWallPaperViewController : UIViewController

@property (nonatomic ,copy) WallPaperDidFinishChooseImageBlock  resultBlock;


@end
