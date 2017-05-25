//
//  AppDelegate.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "AppDelegate.h"
#import "AsyncSocket.h"
#import "Reachability.h"
#import "LoginViewController.h"
#import "XMGNavigationController.h"
#import "LaunchScreenViewController.h"
#import "MineSerivesViewController.h"
#import "HTMLBaseViewController.h"
#import "TabBarViewController.h"

@interface AppDelegate ()<GCDAsyncSocketDelegate , AsyncSocketDelegate>
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachAbility;

@property (nonatomic , strong) UIAlertController *alertVC;
@property (nonatomic , strong) UIAlertController *alertController;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UILabel *noNetwork;
@property (nonatomic , strong) UIView *markview;
#pragma mark - 0 没网 1 有网
@property (nonatomic , assign) BOOL noNetWorkStr;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
    self.noNetWorkStr = 1;

    NSLog(@"%f , %f" , kScreenW , kScreenH);
    _alertController = nil;
//    self.window.rootViewController = [[BottomNavViewController alloc]init];
    
    [self setRootViewController];
    
    [self checkNetwork];
    
    
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
//    self.noNetwork = [self addNoNetLabel];
}

- (void)checkNetwork {
    
    NSString *remoteHostName = @"www.baidu.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachAbility:self.hostReachability];
    
    self.internetReachAbility = [Reachability reachabilityForInternetConnection];
    [self.internetReachAbility startNotifier];
    [self updateInterfaceWithReachAbility:self.internetReachAbility];
}


- (void)updateInterfaceWithReachAbility:(Reachability *)reachability {
    
    if (reachability == self.internetReachAbility) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        if (netStatus == NotReachable) {
            self.noNetWorkStr = 0;
            
            if ([[[HelpFunction shareHelpFunction] getCurrentVC] isKindOfClass:[HTMLBaseViewController class]]) {
                self.noNetwork.hidden = YES;
                
                self.alertVC = [UIAlertController creatRightAlertControllerWithHandle:^{
                    [UIView animateWithDuration:1.0f animations:^{
                        self.window.alpha = 0;
                        self.window.frame = CGRectMake(0, self.window.bounds.size.width, 0, 0);
                    } completion:^(BOOL finished) {
                        exit(0);
                    }];
                } andSuperViewController:kWindowRoot Title:@"您当前的设备未联网，APP无法使用"];
            }else {
                self.noNetwork.hidden = NO;
                self.markview.hidden = NO;
            }
            
        } else if (netStatus == ReachableViaWWAN || netStatus == ReachableViaWiFi) {
            self.noNetWorkStr = 1;
            
            if (self.noNetwork || self.alertVC) {
                self.noNetwork.hidden = YES;
                self.markview.hidden = YES;
                [self.alertVC dismissViewControllerAnimated:YES completion:^{
                    self.alertVC = nil;
                }];
                [self setRootViewController];
            }
            
        }
    }
}


- (UILabel *)addNoNetLabel {
    UILabel *noNetWork = [UILabel creatLableWithTitle:@"❗️当前网络不可用，请检查手机网络" andSuperView:kWindowRoot.view andFont:k13 andTextAligment:NSTextAlignmentCenter];
    [noNetWork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 15));
        make.centerX.mas_equalTo(kWindowRoot.view  .mas_centerX);
        make.top.mas_equalTo(kHeight);
    }];
    
    noNetWork.textColor = [UIColor colorWithHexString:@"ef6060"];
    noNetWork.backgroundColor = [UIColor colorWithHexString:@"ffdcdc"];
    noNetWork.layer.borderWidth = 0;
    noNetWork.layer.cornerRadius = 0;
    noNetWork.hidden = YES;
    
    UIView *markview = [[UIView alloc]initWithFrame:self.window.bounds];
    [kWindowRoot.view addSubview:markview];
    markview.backgroundColor = [UIColor clearColor];
    markview.hidden = YES;
    self.markview = markview;
    
    return noNetWork;
}


- (NSInteger)wheatherHaveNet {
    return self.noNetWorkStr;
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
    [self setUpEnterForeground];
    
}

- (void)setUpEnterForeground {
    if (self.userModel && self.serviceModel) {
        
        [kSocketTCP cutOffSocket];
        kSocketTCP.userSn = [NSString stringWithFormat:@"%ld" , (long)_userModel.sn];
        [kSocketTCP socketConnectHost];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%ld%@%@N#" , (long)self.userModel.sn , _serviceModel.devTypeSn , _serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
        });
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序在终止时执行");
    
    [kSocketTCP cutOffSocket];
    
}

- (void)initUserModel:(UserModel *)userModel {
    
    self.userModel = [[UserModel alloc]init];
    self.userModel = userModel;
}

- (void)initServiceModel:(ServicesModel *)serviceModel {
    self.serviceModel = [[ServicesModel alloc]init];
    self.serviceModel = serviceModel;
}

@end
