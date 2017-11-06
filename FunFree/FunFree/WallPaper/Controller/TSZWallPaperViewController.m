//
//  TSZWallPaperViewController.m
//  IMFeng
//
//  Created by tang on 16/8/5.
//  Copyright © 2016年 shunzhitang. All rights reserved.
//

#import "TSZWallPaperViewController.h"
#import "TSZCollectionViewFlowLayout.h"
#import "TSZShopModel.h"
#import "TSZItemsControlView.h"
#import "TSZCollectionViewCell.h"
#import "GDataXMLNode.h"
#import <MJRefresh/MJRefresh.h>

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title =@"图片墙";
    self.currentPageIndex = 1;
    self.shops = [[NSMutableArray alloc] init];
    
     self.categories = @[@"唯美",@"清新",@"主流",@"个性",@"伤感",@"斯基",@"欧美",@"阿狸",@"科比",@"小新",@"小碎花",@"智能",@"龙猫",@"诱惑",@"苹果",@"安卓",@"大屏幕",@"手机",@"三星",@"车模",];
    
    self.currentCategory = @"唯美";
    
    // 头部控制 , 滑动的 scrollview
    TSZItemsConfig *config = [[TSZItemsConfig alloc] init];
    config.itemWidth = kScreenWidth / 5.0;
    
    _itemControlView = [[TSZItemsControlView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 40)];
    _itemControlView.tapAnimation = YES;
    _itemControlView.config = config;
    _itemControlView.titleArray = self.categories;
    __weak typeof(self) weakSelf = self;
    
    [_itemControlView setTapItemWithIndex:^(NSInteger index , BOOL animation){
       
        weakSelf.currentCategory = weakSelf.categories[index];
        [weakSelf.collectView.mj_header beginRefreshing];
        [weakSelf.itemControlView moveToIndex:index];
    }];
    
    [self.view addSubview:_itemControlView];
    
    // 注册cell
    TSZCollectionViewFlowLayout *layout = [[TSZCollectionViewFlowLayout alloc] init];
    
    layout.delegate = self;
    self.collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 120, kScreenWidth, kScreenHeight - 64.f - 80.f) collectionViewLayout:layout];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    [self.view addSubview:self.collectView];
    
    [self.collectView registerNib:[UINib  nibWithNibName:@"TSZCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectView.backgroundColor = [UIColor whiteColor];
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
    __weak typeof(self) weakSelf = self;
    self.collectView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentPageIndex = 1;
        [weakSelf requestWallList];
    }];
    
    [self.collectView.mj_header beginRefreshing];
}

/**
    增加底部刷新
 */
- (void)addFooter{
    
    __weak typeof(self) weakSelf = self;
    // 添加上拉刷新
    self.collectView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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
    
    cell.backgroundColor = [UIColor whiteColor];
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

- (NSString *)urlEncode:(id)object {
    
    if (!object) {
        return nil;
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        object = [NSString stringWithFormat:@"%@",object];
    }
    
    NSString *string = (NSString*)object;
    NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,
                                                                                         (CFStringRef)string,
                                                                                         nil,
                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                         kCFStringEncodingUTF8);
    return encodedValue;
}

- (void)requestWallList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
        NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.3gbizhi.com/tag-%@/%ld.html", [self urlEncode:self.currentCategory],(long)self.currentPageIndex]]];
       
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
                    
                    if (subNode.stringValue) {
                        
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
           
            [self.collectView.mj_header endRefreshing];
            [self.collectView.mj_footer endRefreshing];
            
            [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
        });
        
        
    });
    
}


@end
