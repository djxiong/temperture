//
//  CZPlistTools.h
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/11/7.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZPlistTools : NSObject

+ (instancetype)shareCZPlistTools;

/**
 判断文档中是否存在文件

 @param fileName 文件名称
 @return 是否存在
 */
- (NSString *)whetherExite:(NSString *)fileName;

/**
 保存数据到沙盒中

 @param fileName 文件名称
 */
- (BOOL)saveDataToBundle:(id)data name:(NSString *)fileName;
/**
 保存数据到沙盒中
 
 @param fileName 文件名称
 */
- (BOOL)saveDataToFile:(id)data name:(NSString *)fileName;

/**
 从沙盒中读取文件

 @param fileName 文件名称
 @return 读取的数据
 */
- (NSDictionary *)readDataFromFile:(NSString *)fileName;

/**
 从Bundle中获取本地数据

 @param fileName 本地数据名称
 @return 获取的数据
 */
- (NSDictionary *)readDataFromBundle:(NSString *)fileName;

- (void)saveFixedDataToFile;

- (UIViewController *)getPresentedViewController;

@end
