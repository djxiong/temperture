//
//  CZPlistTools.m
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/11/7.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "CZPlistTools.h"

static CZPlistTools *tools = nil;
@implementation CZPlistTools

+ (instancetype)shareCZPlistTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [CZPlistTools new];
    });
    return tools;
}

- (NSString *)whetherExite:(NSString *)fileName {

    NSString *filePath = [self appendDocumentPath:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件存在：%@",result?@"是的":@"不存在");
    
    
    return filePath;
}

- (BOOL)saveDataToBundle:(id)data name:(NSString *)fileName {
    NSString *filePath = [self whetherExite:fileName];
    NSLog(@"%@" , filePath);

    NSData *dddd = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    BOOL result = [dddd writeToFile:filePath atomically:YES];
    
    NSLog(@"缓存：%@",result?@"成功":@"失败");
    return result;
}

- (BOOL)saveDataToFile:(id)data name:(NSString *)fileName {
    NSString *filePath = [self whetherExite:fileName];
    NSLog(@"%@" , filePath);
    
    NSData *dddd = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    BOOL result = [dddd writeToFile:filePath atomically:YES];
    
    NSLog(@"缓存：%@",result?@"成功":@"失败");
    return result;
}

- (NSDictionary *)readDataFromFile:(NSString *)fileName {
    NSString *filePath = [self appendDocumentPath:fileName];
    NSLog(@"%@" , filePath);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data == nil) {
        filePath = [self appendBundlePath:fileName];
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dic;
    
}

- (NSDictionary *)readDataFromBundle:(NSString *)fileName {
    NSString *filePath = [self appendBundlePath:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dic;
}

- (NSString *)appendDocumentPath:(NSString *)fileName {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 拼接文件路径
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@" , fileName]];
    return path;
}

- (NSString *)appendBundlePath:(NSString *)fileName {
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:nil];
    return filePath;
}

- (void)saveFixedDataToFile {
    
    if (![self whetherExite:@"UserData"]) {
        NSDictionary *userData = [self readDataFromBundle:@"UserData"];
        [self saveDataToFile:userData name:@"UserData"];
    }
    
    if (![self whetherExite:@"MineServicesData"]) {
        NSDictionary *mineServicesData = [self readDataFromBundle:@"MineServicesData"];
        [self saveDataToFile:mineServicesData name:@"MineServicesData"];
    }
    
    if (![self whetherExite:@"LittleTypesServicesData"]) {
        NSDictionary *littleTypesServicesData = [self readDataFromBundle:@"LittleTypesServicesData"];
        [self saveDataToFile:littleTypesServicesData name:@"LittleTypesServicesData"];
    }
    
    if (![self whetherExite:@"BigTypesServicesData"]) {
        NSDictionary *bigTypesServicesData = [self readDataFromBundle:@"BigTypesServicesData"];
        [self saveDataToFile:bigTypesServicesData name:@"BigTypesServicesData"];
    }
    
}

- (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

@end
