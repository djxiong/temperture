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
#import <SystemConfiguration/CaptiveNetwork.h>
@interface SetServicesViewController (){
    CFDictionaryRef dictRef;
}

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
    [self wifiName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (dictRef) {
        
        if (![self.wifiName isEqualToString:@"Qinianerwky"]) {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:@"请链接设备指定WIFI，否则设备无法绑定!"];
        } else {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:@"请输入当前局域网的正确WIFI信息，以是设备进入配网模式!"];
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

    UILabel *firstLable = [UILabel creatLableWithTitle:[NSString stringWithFormat:@"请把手机当前WIFI连接到烤箱的WIFI"] andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
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
    
    SearchServicesViewController *searVC = [[SearchServicesViewController alloc]init];
    searVC.navigationItem.title = @"添加设备";
    searVC.addServiceModel = self.addServiceModel;
    [self.navigationController pushViewController:searVC animated:YES];
    
}

#pragma mark - 获取本地wifi名字
- (NSString *)getWifiName {
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"%@" , networkInfo);
            
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (NSString *)wifiName {
    if (_wifiName == nil) {
        _wifiName = [self getWifiName];
    }
    return _wifiName;
}

- (void)setAddServiceModel:(AddServiceModel *)addServiceModel {
    _addServiceModel = addServiceModel;
    
    switch (_addServiceModel.slType) {
        case 1:
            self.alertMessage = @"定时3秒";
            break;
        case 2:
            self.alertMessage = @"开关3秒";
            break;
        case 3:
            self.alertMessage = @"wifi3秒";
            break;
        default:
            break;
    }
}

@end
