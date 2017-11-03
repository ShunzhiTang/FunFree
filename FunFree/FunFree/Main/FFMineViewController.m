//
//  FFMineViewController.m
//  FunFree
//
//  Created by Michael Tang on 2017/11/3.
//  Copyright © 2017年 MichaelTang. All rights reserved.
//

#import "FFMineViewController.h"
#import "FFSettingViewController.h"
#import "UINavigationController+FFScreenPopGesture.h"

@interface FFMineViewController ()

@end

@implementation FFMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    self.fd_prefersNavigationBarHidden = YES;
    self.navigationItem.title = @"个人中心";

    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(100, 100, 150, 44);
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(gotoSettingVc:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //     [self.navigationController setNavigationBarHidden:YES
    //     animated:animated];
}

- (void)gotoSettingVc:(UIButton *)sender {
    FFSettingViewController *settingVc = [[FFSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation - (void)prepareForSegue:(UIStoryboardSegue *)segue
sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
