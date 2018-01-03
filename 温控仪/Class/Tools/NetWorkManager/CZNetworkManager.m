//
//  CZNetworkManager.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/8/31.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "CZNetworkManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface CZNetworkManager ()
@property (nonatomic , strong) NSArray *arrImage;
@end

static CZNetworkManager *helper = nil;

@implementation CZNetworkManager

- (void)removeAllObjectOfStanderDefault {
    [kStanderDefault removeObjectForKey:@"Login"];
    [kStanderDefault removeObjectForKey:@"cityName"];
    [kStanderDefault removeObjectForKey:@"password"];
    [kStanderDefault removeObjectForKey:@"phone"];
    [kStanderDefault removeObjectForKey:@"userSn"];
    [kStanderDefault removeObjectForKey:@"userId"];
    [kStanderDefault removeObjectForKey:@"zhuYe"];
    
    [kStanderDefault removeObjectForKey:@"offBtn"];
    [kStanderDefault removeObjectForKey:@"GanYiJiData"];
    [kStanderDefault removeObjectForKey:@"ganYiJiHongGanDic"];
    [kStanderDefault removeObjectForKey:@"GanYiJiIsWork"];
    [kStanderDefault removeObjectForKey:@"AirData"];
    [kStanderDefault removeObjectForKey:@"AirDingShiData"];
    [kStanderDefault removeObjectForKey:@"kongZhiTai"];
    [kStanderDefault removeObjectForKey:@"data"];
    [kStanderDefault removeObjectForKey:@"wearthDic"];
    [kStanderDefault removeObjectForKey:@"requestWeatherTime"];
    [kStanderDefault removeObjectForKey:@"GeRenInfo"];
    
    kSocketTCP.isDuanXianChongLian = @"NO";
    [kSocketTCP cutOffSocket];
}

+ (instancetype)shareCZNetworkManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc]init];
        helper.responseSerializer = [AFJSONResponseSerializer serializer];
        helper.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];

        [helper.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        helper.requestSerializer.timeoutInterval = 1.0f;
        [helper.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        
//        [helper.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [helper.requestSerializer setValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    });
    
    return helper;
}

- (void)checkNetWork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    __weak typeof (AFNetworkReachabilityManager) *wearManager= manager;
    [wearManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变时调用
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:{
                
                [self noNetWork];
                
                NSLog(@"没有网络");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
        }
    }];
    [manager startMonitoring];
}

- (void)noNetWork {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [SVProgressHUD show];
    [SVProgressHUD showErrorWithStatus:@"当前网络不可用，\n请检查您的网络设置"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (NSString *)getWifiName {
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
       CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
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

- (void)requestGETUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters isSuccess:(success)isSuccess failure:(failure)failure {
    if (urlString == nil) {
        return ;
    }
    
    [SVProgressHUD show];
    [self GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        return ;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *dic = responseObject;
        isSuccess(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@" , error);
        //        failure(error);
    }];
    
    
}

- (void)requestPOSTUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters isSuccess:(success)isSuccess failure:(failure)failure {
    if (urlString == nil) {
        return ;
    }
    
    [SVProgressHUD show];
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [SVProgressHUD dismiss];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:responseObject];
        isSuccess(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@" , urlString);
        failure(error);
    }];
    
}

- (void)requestWetherParameters:(NSString *_Nullable)cityname isSuccess:(success _Nullable )isSuccess failure:(failure _Nullable)failure {
    
    if (cityname == nil) {
        return ;
    }
    [SVProgressHUD show];
    NSMutableDictionary *wearthDic = [NSMutableDictionary dictionary];
    [self GET:kRequestWeatherURL parameters:@{@"city" : cityname} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *dic = responseObject;
        if ([dic isKindOfClass:[NSNull class]] || dic == nil) {
            return ;
        }
        
        NSArray *HeWeather5 = dic[@"HeWeather5"];
        NSDictionary *info = HeWeather5[0];
        NSDictionary *aqi = info[@"aqi"];
        
        NSDictionary *city = aqi[@"city"];
        NSString *qlty = city[@"qlty"];
        [wearthDic setObject:qlty forKey:@"quality"];
        
        NSDictionary *now = info[@"now"];
        NSString *hum = now[@"hum"];
        [wearthDic setObject:hum forKey:@"humidity"];
        
        NSString *tmp = now[@"tmp"];
        [wearthDic setObject:tmp forKey:@"temp_curr"];
        
        NSDictionary *wind = now[@"wind"];
        //        NSString *dir = wind[@"dir"];
        NSString *sc = wind[@"sc"];
        NSArray *subArray = nil;
        if ([sc containsString:@"-"]) {
            subArray = [sc componentsSeparatedByString:@"-"];
        }
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Wind" ofType:@"plist"];
        NSDictionary *windDic = [NSDictionary dictionaryWithContentsOfFile:path];
        
        if (subArray == nil) {
            [wearthDic setObject:sc forKey:@"winp"];
        } else {
            [wearthDic setObject:windDic[subArray[0]] forKey:@"winp"];
        }
        
        NSDictionary *cond = now[@"cond"];
        NSString *txt = cond[@"txt"];
        [wearthDic setObject:txt forKey:@"weather_curr"];
        NSString *imageStr = @"qing";
        if ([txt isEqualToString:@"晴"]) {
            imageStr = @"qing";
        } else if ([txt isEqualToString:@"多云"] || [txt isEqualToString:@"少云"]) {
            imageStr = @"duoyun";
        } else if ([txt isEqualToString:@"晴间多云"]) {
            imageStr = @"qingjianduoyun";
        } else if ([txt isEqualToString:@"阴"]) {
            imageStr = @"yin";
        } else if ([txt containsString:@"风"] || [txt isEqualToString:@"平静"]) {
            imageStr = @"feng";
        }  else if ([txt isEqualToString:@"阵雨"] || [txt isEqualToString:@"强阵雨"]) {
            imageStr = @"zhenyu";
        } else if ([txt containsString:@"雷"]) {
            imageStr = @"leiyu";
        } else if ([txt isEqualToString:@"小雨"] || [txt isEqualToString:@"毛毛雨"] || [txt isEqualToString:@"细雨"]) {
            imageStr = @"xiaoyu";
        } else if ([txt isEqualToString:@"中雨"] || [txt isEqualToString:@"冻雨"]) {
            imageStr = @"zhongyu";
        } else if ([txt isEqualToString:@"大雨"] || [txt containsString:@"暴雨"] || [txt isEqualToString:@"极端降雨"]) {
            imageStr = @"dayu";
        } else if ([txt isEqualToString:@"小雪"]) {
            imageStr = @"xiaoxue";
        } else if ([txt isEqualToString:@"中雪"] || [txt isEqualToString:@"阵雪"]) {
            imageStr = @"zhongxue";
        } else if ([txt isEqualToString:@"大雪"] || [txt containsString:@"暴雪"]) {
            imageStr = @"daxue";
        } else if ([txt isEqualToString:@"雨夹雪"] || [txt isEqualToString:@"雨雪天气"] || [txt isEqualToString:@"阵雨夹雪"]) {
            imageStr = @"yujiaxue";
        } else if ([txt containsString:@"雾"]) {
            imageStr = @"wu";
        } else if ([txt isEqualToString:@"霾"]) {
            imageStr = @"mai";
        }
        
        NSInteger index = [self.arrImage indexOfObject:imageStr];
        NSLog(@"%@ , %ld" , imageStr , index);
        [wearthDic setObject:@(index) forKey:@"weather_icon"];
        [wearthDic setObject:cityname forKey:@"cityName"];
        
        isSuccess(wearthDic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@" , error);
        failure(error);
    }];
    
}

- (void)pushToWIFISetVC {
    NSString * urlString = @"App-Prefs:root=WIFI";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        if (iOS10) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
            }
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }
    }

}

- (NSArray *)arrImage {
    if (!_arrImage) {
        _arrImage = [NSArray arrayWithObjects:@"qing", @"dayu", @"duoyun", @"feng", @"leiyu", @"mai", @"daxue",@"qingjianduoyun",@"wu",@"xiaoxue",@"xiaoyu",@"yin",@"yujiaxue",@"zhenyu",@"zhongxue",@"zhongyu", nil];
    }
    return _arrImage;
}



@end
