//
//  HTMLBaseViewController.h
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/12/1.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef enum : NSUInteger {
    CONNECTED_ZHILIAN,
    CONNECTED_CONNECTALI,
} CONNECTED_STATE;

@protocol SendServiceModelToParentVCDelegate <NSObject>

@optional
- (void)sendServiceModelToParentVC:(ServicesModel *)serviceModel;
- (void)serviceCurrentConnectedState:(CONNECTED_STATE)state;

- (void)whetherDelegateService:(BOOL)delateService;

@end

@interface HTMLBaseViewController : UIViewController

@property (nonatomic , assign) CONNECTED_STATE connectState;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , assign) id<SendServiceModelToParentVCDelegate> delegate;

@end
