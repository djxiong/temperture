//
//  SystemMessageModel.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/2/5.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "SystemMessageModel.h"

@implementation SystemMessageModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"idd" : @"id"};
}

- (NSString *)description
{
   return [self yy_modelDescription];
}
@end
