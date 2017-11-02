//
//  AppDelegate.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "AsyncSocket.h"
#import "Reachability.h"
#import "LoginViewController.h"
#import "XMGNavigationController.h"
#import "LaunchScreenViewController.h"
#import "HTMLBaseViewController.h"


#define STOREAPPID @"1113948983"
@interface AppDelegate ()<GCDAsyncSocketDelegate , AsyncSocketDelegate , HelpFunctionDelegate>

@property (nonatomic , strong) UIAlertController *alertVC;
@property (nonatomic , strong) UIAlertController *alertController;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UIView *markview;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
    
    NSLog(@"%f , %f" , kScreenW , kScreenH);
    
    _alertController = nil;
    
    [self setRootViewController];
    [[CZNetworkManager shareCZNetworkManager]checkNetWork];
    
    

    return YES;
}

- (void)setRootViewController {
    NSString *isLaunchLoad = [kStanderDefault objectForKey:@"isLaunch"];
    if ([isLaunchLoad isEqualToString:@"NO"]) {
        [kStanderDefault setObject:@"NO" forKey:@"firstRun"];
        
        if ([kStanderDefault objectForKey:@"Login"]) {
            self.window.rootViewController = [[TabBarViewController alloc]init];
        } else {
            LoginViewController *loginVC = [[LoginViewController alloc]init];
            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:loginVC];
            self.window.rootViewController = nav;
        }
    } else {
        self.window.rootViewController = [[LaunchScreenViewController alloc]init];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"程序将要进入非活动状态");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Singleton sharedInstance] enableBackgroundingOnSocket];
    
    NSLog(@"程序进入后台后执行");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSLog(@"程序将要进入前台时执行");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"程序被激活（获得焦点）后执行");
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSInteger nowTime = [NSString getNowTimeInterval];
    NSString *endTime = [kStanderDefault objectForKey:@"endTime"];
    
    if (nowTime > endTime.integerValue + 3600 * 24 * 5 && endTime != nil) {
        [self requestLoginURL];
    }
    
    if (nowTime > endTime.integerValue + 3600 * 2 && endTime != nil) {
        [self setRootViewController];
        [kStanderDefault removeObjectForKey:@"endTime"];
    }
    
    [self setUpEnterForeground];
    
}

- (void)requestLoginURL {
    NSString *phone = [kStanderDefault objectForKey:@"phone"];
    NSString *password = [kStanderDefault objectForKey:@"password"];
    NSString *clientId = [kStanderDefault objectForKey:@"GeTuiClientId"];
    
    if (phone == nil || password == nil) {
        return ;
    }
    
    NSDictionary *parames = nil;
    if (clientId != nil) {
        parames = @{@"loginName" : phone , @"password" : password , @"ua.clientId" : clientId, @"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]};
    } else {
        parames = @{@"loginName" : phone , @"password" : password , @"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]};
    }
    
    [HelpFunction requestDataWithUrlString:kLogin andParames:parames andDelegate:self];
}

- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    NSLog(@"%@" , data);
}

- (void)setUpEnterForeground {
    if (self.userModel && self.serviceModel) {
        
        kSocketTCP.userSn = self.userModel.hexUsersn;
        [kSocketTCP socketConnectHostWith:KALIHost port:kALIPort];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@%@N#" , self.userModel.hexUsersn , _serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
        });
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序在终止时执行");
    
    [kSocketTCP cutOffSocket];
    
    NSString *endTime = [NSString stringWithFormat:@"%ld" , [NSString getNowTimeInterval]];
    [kStanderDefault setObject:endTime forKey:@"endTime"];
    
}

- (void)initUserModel:(UserModel *)userModel {
    
    self.userModel = [[UserModel alloc]init];
    self.userModel = userModel;
}

- (void)initServiceModel:(ServicesModel *)serviceModel {
    self.serviceModel = [[ServicesModel alloc]init];
    self.serviceModel = serviceModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
