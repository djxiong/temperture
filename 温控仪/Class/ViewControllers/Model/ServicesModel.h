//
//  ServicesModel.h
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/11.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicesModel : NSObject

@property (nonatomic , copy) NSString *indexUrl;
@property (nonatomic , strong) NSString *typeSn;
@property (nonatomic , copy) NSString *typeName;
@property (nonatomic , copy) NSString *typeNumber;
@property (nonatomic , copy) NSString *devTypeNumber;
@property (nonatomic,copy) NSString *devTypeSn;


@property (nonatomic , copy) NSString *protocol;
@property (nonatomic , copy) NSString *bindUrl;
@property (nonatomic , copy) NSString *brand;
@property (nonatomic , copy) NSString *imageUrl;
@property (nonatomic , copy) NSString *devSn;
@property (nonatomic , assign) NSInteger slType;
@property (nonatomic,copy) NSString *remark;

@property (nonatomic , assign) NSInteger userDeviceID;
@property (nonatomic , assign) NSInteger slTypeInt;

@property (nonatomic , copy) NSString *definedName;

/**
 查询设备是否在线
 */
@property (nonatomic , assign) NSInteger ifConn;

@end
