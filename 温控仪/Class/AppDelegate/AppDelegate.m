//
//  AppDelegate.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "LoginViewController.h"
#import "XMGNavigationController.h"
#import "LaunchScreenViewController.h"
#import "HTMLBaseViewController.h"
#import "NSBundle+Language.h"

#define STOREAPPID @"1113948983"
@interface AppDelegate ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong) NSString *userHexSn;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UIView *markview;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] isEqualToString:@""]) {
        [NSBundle setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"]];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
    
    NSLog(@"%f , %f" , kScreenW , kScreenH);
    
    [self setNotifi];
    [self setRootViewController];
    [[CZNetworkManager shareCZNetworkManager]checkNetWork];
    
    [kPlistTools saveFixedDataToFile];

    return YES;
}

#pragma mark - 推送业务
- (void)setNotifi {
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册 APNs
    [self registerRemoteNotification];
    
    
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // 处理APNs代码，通过userInfo可以取到推送的信息（包括内容，角标，自定义参数等）。如果需要弹窗等其他操作，则需要自行编码。
    NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n",userInfo);
    
    //静默推送收到消息后也需要将APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^ _Nonnull __strong)(void))completionHandler {
    
    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}

#endif

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [kStanderDefault setObject:clientId forKey:@"GeTuiClientId"];
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    if ([extensionPointIdentifier isEqualToString:@"com.apple.keyboard-service"]) {
        return NO;
    }
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

#pragma mark - 程序启动的整个流程
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
    [GeTuiSdk setBadge:0]; //同步本地角标值到服务器
    NSInteger nowTime = [NSString getNowTimeInterval];
    NSString *endTime = [kStanderDefault objectForKey:@"endTime"];
    
    if (nowTime > endTime.integerValue + 3600 * 2 && endTime != nil) {
        [self setRootViewController];
        [kStanderDefault removeObjectForKey:@"endTime"];
    }
    
    [self setUpEnterForeground];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序在终止时执行");
    
    [kSocketTCP cutOffSocket];
    
    NSString *endTime = [NSString stringWithFormat:@"%ld" , (long)[NSString getNowTimeInterval]];
    [kStanderDefault setObject:endTime forKey:@"endTime"];
    
}

#pragma mark - 懒加载
- (void)setUpEnterForeground {
    if (self.userHexSn && self.serviceModel) {
        
        [kSocketTCP socketConnectHostWith:kSocketTCP.socketHost port:kSocketTCP.socketPort];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [kSocketTCP sendDataToHost:nil andType:kAddService];
            
        });
    }
}

- (void)initUserHexSn:(NSString *)userHexSn {
    self.userHexSn = userHexSn;
}

- (void)initServiceModel:(ServicesModel *)serviceModel {
    self.serviceModel = [[ServicesModel alloc]init];
    self.serviceModel = serviceModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
