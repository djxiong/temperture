//
//  BaseViewController.m
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/5/22.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];

    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_back"]];
    imageView.frame = kScreenFrame;
    [self.view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
}

@end
