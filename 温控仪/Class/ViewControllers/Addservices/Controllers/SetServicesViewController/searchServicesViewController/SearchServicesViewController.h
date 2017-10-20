//
//  searchServicesViewController.h
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface SearchServicesViewController : BaseViewController

@property (nonatomic , strong) AddServiceModel *addServiceModel;

/**
 密码
 */
@property (strong, nonatomic) NSString *pwdStr;
/**
 账号
 */
@property (strong, nonatomic)  NSString *wifiNameStr;

@property (nonatomic , strong) NSString *deviceSn;
@end
