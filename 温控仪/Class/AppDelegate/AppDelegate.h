//
//  AppDelegate.h
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTSDK/GeTuiSdk.h>     // GetuiSdk头文件应用
#import "ServicesModel.h"
#import "UserModel.h"

// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

/// 使用个推回调时，需要添加"GeTuiSdkDelegate"
/// iOS 10 及以上环境，需要添加 UNUserNotificationCenterDelegate 协议，才能使用 UserNotifications.framework 的回调
@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate, UNUserNotificationCenterDelegate>


@property (strong, nonatomic) UIWindow *window;

- (void)initUserHexSn:(NSString *)userHexSn;
- (void)initServiceModel:(ServicesModel *)serviceModel;
@end

