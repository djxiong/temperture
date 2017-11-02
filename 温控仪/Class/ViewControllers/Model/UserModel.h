//
//  UserModel.h
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/7.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject


@property (nonatomic , copy) NSString *birthdate;
@property (nonatomic , copy) NSString *email;

@property (nonatomic , copy) NSString *headImageUrl;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *phone;
@property (nonatomic , copy) NSString *hexUsersn;

@property (nonatomic , assign) NSInteger sex;
@property (nonatomic , assign) NSInteger idd;
@property (nonatomic , assign) NSInteger sn;
@property (nonatomic , strong) NSString *state;
@property (nonatomic , strong) NSString *zmoney;



@end
