//
//  ServicesModel.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/11.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "ServicesModel.h"

@implementation ServicesModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userDeviceID" : @"id"};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
