//
//  ServicesModel.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/11.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "ServicesModel.h"

@implementation ServicesModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}


- (NSString *)description {
   
    return [NSString stringWithFormat:@" devSn--%@ , typeName--%@ , brand--%@ , bindUrl--%@ , slTypeInt--%ld , indexUrl--%@ , definedName--%@"  , _devSn , _typeName , _brand , _bindUrl , (long)_slTypeInt , _indexUrl , _definedName];
}

@end
