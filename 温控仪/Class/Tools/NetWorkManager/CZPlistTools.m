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

- (BOOL)whetherExite:(NSString *)fileName {

    NSString *filePath = [self appendDocumentPath:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件存在：%@",result?@"是的":@"不存在");
    return result;
}

- (BOOL)saveDataToFile:(NSDictionary *)data name:(NSString *)fileName {
    NSString *filePath = [self appendDocumentPath:fileName];
    NSLog(@"%@" , filePath);
    
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    BOOL result = [data2 writeToFile:filePath atomically:YES];
    
    return result;
}

- (NSDictionary *)readDataFromFile:(NSString *)fileName {
    NSString *filePath = [self appendDocumentPath:fileName];
    NSLog(@"%@" , filePath);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
//    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dic;
    
}

- (NSString *)appendDocumentPath:(NSString *)fileName {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist" , fileName]];
}

@end
