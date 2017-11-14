//
//  SetServicesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "SetServicesViewController.h"
#import "MineSerivesViewController.h"
#import "SearchServicesViewController.h"
@interface SetServicesViewController ()

@property (nonatomic , copy) NSString *wifiName;
@property (nonatomic , strong) NSMutableArray *array;
@property (nonatomic , strong) UIImageView *switchImage;
@property (nonatomic , copy) NSString *alertMessage;
@end

@implementation SetServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
    
    [self setUI];
}

- (NSString *)getWifiName {
    return [[CZNetworkManager shareCZNetworkManager] getWifiName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self getWifiName] != nil || [self getWifiName] != NULL) {
        
        if (![[self getWifiName] isEqualToString:@"Qinianerwky"]) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                [kNetWork pushToWIFISetVC];
                return ;
            } andSuperViewController:self Title:@"请链接设备指定WIFI，否则设备无法绑定!"];
        }
    } else {
        [UIAlertController creatRightAlertControllerWithHandle:^{
            [self.navigationController popViewControllerAnimated:YES];
        } andSuperViewController:kWindowRoot Title:@"您当前没有连接WIFI，设备无法添加"];
    }
}

#pragma mark - 设置UI
- (void)setUI {
    
    UIImage *image = nil;

    image = [UIImage imageNamed:@"WIFIback"];
    
    _switchImage = [[UIImageView alloc]initWithImage:image];
    [self.view addSubview:_switchImage];
    [_switchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenH / 3, kScreenH / 3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(kScreenH / 11 + kHeight);
    }];

    UILabel *firstLable = [UILabel creatLableWithTitle:[NSString stringWithFormat:@"请把手机当前WIFI连接到'Qinianerwky'的WIFI"] andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    firstLable.textColor = [UIColor whiteColor];
    firstLable.layer.borderWidth = 0;
    [firstLable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kScreenH / 2.5 , kScreenW / 5));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(_switchImage.mas_bottom).offset(kScreenH / 8.5);
    }];
    
    
    UIButton *neaxtBtn = [UIButton creatBtnWithTitle:@"下一步" andBorderColor:kMainColor WithTarget:self andDoneAtcion:@selector(neaxtBtnAction) andSuperView:self.view];
    neaxtBtn.layer.cornerRadius = kScreenW / 18;
    neaxtBtn.backgroundColor = kCOLOR(239, 250, 253);
    [neaxtBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenH / 3, kScreenW / 9));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(firstLable.mas_bottom).offset(kScreenH /  22.30303);
    }];
    
}

#pragma mark - 下一步按钮点击事件
- (void)neaxtBtnAction {
    
    if (![[self getWifiName] isEqualToString:@"Qinianerwky"]) {
        [UIAlertController creatRightAlertControllerWithHandle:^{
            [kNetWork pushToWIFISetVC];
            return ;
        } andSuperViewController:self Title:@"未连接到指定WIFI，无法进行配网设置"];
    }
    
    SearchServicesViewController *searVC = [[SearchServicesViewController alloc]init];
    searVC.serviceModel = self.serviceModel;
    searVC.navigationItem.title = @"设备配网";
    [self.navigationController pushViewController:searVC animated:YES];
    
}


- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
    _serviceModel.devSn = [NSString toHex:[_serviceModel.devSn integerValue]];
    if (_serviceModel.devSn.length != 4) {
        _serviceModel.devSn = [NSString stringWithFormat:@"0%@" , _serviceModel.devSn];
    }
}

@end
