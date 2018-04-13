//
//  BindServiceVC.m
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/11/7.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "BindServiceVC.h"

#import "MineSerivesViewController.h"
#import "FailContextViewController.h"
@interface BindServiceVC ()
@property (nonatomic , strong) UIAlertController *alertVC;
@end

@implementation BindServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
    
    [self bindServiceRequest];
    
}

- (void)bindServiceRequest {
    NSDictionary *parames = [NSMutableDictionary dictionary];
    [parames setValuesForKeysWithDictionary:@{@"ud.userSn" : [kStanderDefault objectForKey:@"userSn"] ,  @"ud.devSn" : self.serviceModel.devSn , @"ud.devTypeSn" : self.serviceModel.typeSn, @"phoneType":@(2) , @"ud.devTypeNumber":self.serviceModel.typeNumber}];
    
    if ([kStanderDefault objectForKey:@"cityName"] && [kStanderDefault objectForKey:@"provience"]) {
        NSString *city = [kStanderDefault objectForKey:@"cityName"];
        
        NSString *subStr = [city substringWithRange:NSMakeRange(city.length - 1, 1)];
        if (![subStr isEqualToString:@"市"]) {
            city = [NSString stringWithFormat:@"%@市" , city];
        }
        [parames setValuesForKeysWithDictionary:@{@"province" : [kStanderDefault objectForKey:@"provience"] , @"city" : city}];
    }
    
    [kNetWork requestPOSTUrlString:self.serviceModel.bindUrl parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSLog(@"%@" , responseObject);
        
        if ([responseObject[@"state"] integerValue] == 0) {
            [self determineAndBindTheDevice];
        } else if ([responseObject[@"state"] integerValue] == 2 ) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                [self returnMinSerVC];
            } andSuperViewController:self Title:NSLocalizedString(@"This device is already bound", nil)];
            
        } else if ([responseObject[@"state"] integerValue] == 1){
            [self addServiceFail];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self addServiceFail];
    }];
}

#pragma mark - 绑定设备失败
- (void)addServiceFail {
    
    if (!self.alertVC) {
        self.alertVC = [UIAlertController creatRightAlertControllerWithHandle:^{
           
            FailContextViewController *failVC = [[FailContextViewController alloc]init];
            failVC.navigationItem.title = NSLocalizedString(@"Failure", nil);
            failVC.serviceModel = self.serviceModel;
            [self.navigationController pushViewController:failVC animated:YES];
        } andSuperViewController:[kPlistTools getPresentedViewController] Title:NSLocalizedString(@"This device failed to bind", nil)];
        
    }
    
}

#pragma mark - 判断并绑定设备
- (void)determineAndBindTheDevice {
    
    [kStanderDefault setObject:@"YES" forKey:@"isHaveServices"];
    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    [UIAlertController creatRightAlertControllerWithHandle:^{
        [self returnMinSerVC];
    } andSuperViewController:self Title:NSLocalizedString(@"Device binding successful", nil)];
    
}

- (void)returnMinSerVC {
    
    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:BindService object:nil]];
    
    MineSerivesViewController *tabVC = [[MineSerivesViewController alloc]init];
    tabVC.fromAddVC = @"YES";
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:[tabVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
    
//    _serviceModel.devSn = [NSString toHex:[_serviceModel.devSn integerValue]];
//    if (_serviceModel.devSn.length != 4) {
//        _serviceModel.devSn = [NSString stringWithFormat:@"0%@" , _serviceModel.devSn];
//    }
    
}

@end
