//
//  TSZWallPaperViewController.m
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZWallPaperViewController.h"
#import "MJRefresh.h"
#import "TSZCollectionViewFlowLayout.h"
#import "TSZShopModel.h"
#import "TSZItemsControlView.h"
#import "TSZCollectionViewCell.h"
#import "GDataXMLNode.h"
#import "TSZCommonFontColorStyle.h"


@interface TSZWallPaperViewController ()<UICollectionViewDelegate , UICollectionViewDataSource ,TSZCollectionViewFlowLayoutDelegate >

@property (nonatomic ,strong) UICollectionView *collectView;

@property (nonatomic ,strong) NSMutableArray *shops;

@property (nonatomic ,assign) NSInteger currentPageIndex;

@property (nonatomic ,strong) NSArray *categories;

@property (nonatomic ,strong) NSString *currentCategory;

@property (nonatomic ,strong) TSZItemsControlView *itemControlView;

@end

@implementation TSZWallPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setStrNavTitle:@"图片墙"];
    
    self.currentPageIndex = 1;
    self.shops = [[NSMutableArray alloc] init];
    
     self.categories = @[@"唯美",@"清新",@"主流",@"个性",@"伤感",@"斯基",@"欧美",@"阿狸",@"科比",@"小新",@"小碎花",@"智能",@"龙猫",@"诱惑",@"苹果",@"安卓",@"大屏幕",@"手机",@"三星",@"车模",];
    
    self.currentCategory = @"唯美";
    
    // 头部控制 , 滑动的 scrollview
    TSZItemsConfig *config = [[TSZItemsConfig alloc] init];
    config.itemWidth = TSZSystemScreenWidth / 5.0;
    
    _itemControlView = [[TSZItemsControlView alloc] initWithFrame:CGRectMake(0, 0, TSZSystemScreenWidth, 40)];
    _itemControlView.tapAnimation = YES;
    _itemControlView.config = config;
    _itemControlView.titleArray = self.categories;
    TSZWeakSelf weakSelf = self;
    
    [_itemControlView setTapItemWithIndex:^(NSInteger index , BOOL animation){
       
        weakSelf.currentCategory = weakSelf.categories[index];
        [weakSelf.collectView headerBeginRefreshing];
        [weakSelf.itemControlView moveToIndex:index];
    }];
    
    [self.view addSubview:_itemControlView];
    
    // 注册cell
    TSZCollectionViewFlowLayout *layout = [[TSZCollectionViewFlowLayout alloc] init];
    
    layout.delegate = self;
    self.collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, TSZSystemScreenWidth, TSZSystemScreenHeight - 64.f - 40.f) collectionViewLayout:layout];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.gjcf_top = 40;
    [self.view addSubview:self.collectView];
    
    [self.collectView registerNib:[UINib  nibWithNibName:@"TSZCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self setupRefresh];
    
}

- (void)setupRefresh{
    
    [self addHeader];
    
    [self addFooter];
    
}


/**
     头部刷新
 */

- (void)addHeader{
    
    // 添加下拉头部刷新
    TSZWeakSelf weakSelf = self;
    
    [self.collectView addHeaderWithCallback:^{
        
        // 进入刷新就会调用这个block
        
        weakSelf.currentPageIndex = 1;
        [weakSelf requestWallList];
        
        
    } dateKey:@"collection"];  // dateKey用于存储刷新时间，也可以不传值，可以保证不同界面拥有不同的刷新时间
    
    [self.collectView headerBeginRefreshing];
}

/**
    增加底部刷新
 */
- (void)addFooter{
    
    TSZWeakSelf weakSelf = self;
    // 添加上拉刷新
    [self.collectView addFooterWithCallback:^{
       
        weakSelf.currentPageIndex++;
        [weakSelf requestWallList];
        
    }];
    
}

#pragma mark: collectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  self.shops.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TSZCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [TSZCommonFontColorStyle mainThemeColor];
    cell.shopModel = self.shops[indexPath.item];
    return cell;
}

// waterFlow 的代理
- (CGFloat)waterFlow:(TSZCollectionViewFlowLayout *)waterFlow heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPach{
    
    if (indexPach.item < 0 || indexPach.item > self.shops.count - 1) {
        return 0.0;
    }
    
    if (indexPach.row == 1) {
        return 0.0;
    }
    
    TSZShopModel *shop = self.shops[indexPach.row];
    
    return shop.h / shop.w * width;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 点击选择
    TSZShopModel *shopModel = self.shops[indexPath.row];
    
    if (self.resultBlock) {
        
        self.resultBlock(shopModel.img);
        
    }
    
}



#pragma mark - 请求网络数据

- (void)requestWallList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
        NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.3gbizhi.com/tag-%@/%ld.html",TSZStringEncodeString(self.currentCategory),(long)self.currentPageIndex]]];
       
        if (!htmlData) {
            return ;
        }
        
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        
        if (!htmlString) {
            return;
        }
        
        GDataXMLDocument *htmlDoc = [[GDataXMLDocument alloc] initWithHTMLString:htmlString error:nil];
        
        NSArray *elements = [htmlDoc nodesForXPath:@"//img" error:nil];
        if (self.currentPageIndex == 1) {
            [self.shops removeAllObjects];
        }
        
        if (elements.count == 0) {
            return;
        }
        
        
        for ( GDataXMLElement *node in elements) {
            
            @autoreleasepool {
                
                for ( GDataXMLNode *subNode  in  node.attributes) {
                    
                    if (!TSZStringIsNull(subNode.stringValue)) {
                        
                        if ([subNode.stringValue hasPrefix:@"http://"]) {
                            
                            TSZShopModel *itemModel = [[TSZShopModel alloc] init];
                            itemModel.h = 321;
                            itemModel.w = 238;
                            itemModel.img = subNode.stringValue;
                            
                            [self.shops addObject:itemModel];
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self.collectView headerEndRefreshing];
            [self.collectView  footerEndRefreshing];
            
            [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
        });
        
        
    });
    
}


@end
