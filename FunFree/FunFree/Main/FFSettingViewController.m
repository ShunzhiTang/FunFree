//
//  FFSettingViewController.m
//  FunFree
//
//  Created by Michael Tang on 2017/11/3.
//  Copyright © 2017年 MichaelTang. All rights reserved.
//

#import "FFSettingViewController.h"

@interface FFSettingViewController ()

@end

@implementation FFSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.navigationItem.title = @"热点";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
