//
//  FailContextViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "FailContextViewController.h"
#import "AllTypeServiceViewController.h"
#import "MineSerivesViewController.h"
#import "UserFeedBackViewController.h"
@interface FailContextViewController ()<UIGestureRecognizerDelegate>
@end

@implementation FailContextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
   
    [self setUI];
    
    [self setupNav];
}

- (void)setupNav {
    
    self.navigationController
    .interactivePopGestureRecognizer.delegate = self;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"navigationButtonReturn"] forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"Back to Home page", nil) forState:UIControlStateNormal];
    [backButton setTitleColor:kMainColor forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:k15];
    [backButton sizeToFit];
    // 这句代码放在sizeToFit后面
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [backButton addTarget:self action:@selector(backAtcion) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backAtcion {
    MineSerivesViewController *tabVC = [[MineSerivesViewController alloc]init];
    tabVC.fromAddVC = @"YES";
    
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:[tabVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

#pragma mark - 设置UI
- (void)setUI {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kHeight, kScreenW, kScreenH / 6.65)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor redColor];
    
    UILabel *lable1 = [UILabel creatLableWithTitle:NSLocalizedString(@"Binding failed!", nil) andSuperView:view andFont:k17 andTextAligment:NSTextAlignmentLeft];
    lable1.layer.borderWidth = 0;
    [lable1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScreenW / 8.3);
        make.size.mas_equalTo(CGSizeMake(kScreenW / 3, kScreenW / 15));
        make.bottom.mas_equalTo(view.mas_centerY);
    }];
    lable1.textColor = [UIColor whiteColor];
    
    UILabel *lable2 = [UILabel creatLableWithTitle:[NSString stringWithFormat:@"%@%@" , self.serviceModel.brand , self.serviceModel.typeName] andSuperView:view andFont:k15 andTextAligment:NSTextAlignmentLeft];
    lable2.layer.borderWidth = 0;
    [lable2 mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_equalTo(lable1.mas_left);
        make.size.mas_equalTo(CGSizeMake(kScreenW / 3, kScreenW / 15));
        make.top.mas_equalTo(view.mas_centerY);
    }];
    lable2.textColor = [UIColor whiteColor];
    
    UIImageView *jingGaoIamgeView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iconfont-jinggao"]];
    [view addSubview:jingGaoIamgeView];
    [jingGaoIamgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 10, kScreenW / 10));
        make.right.mas_equalTo(-kScreenW / 15);
        make.centerY.mas_equalTo(view.mas_centerY).offset(-15);
    }];
    [UIImageView setImageViewColor:jingGaoIamgeView andColor:[UIColor whiteColor]];
    
    UILabel *jingGaoLable = [UILabel creatLableWithTitle:NSLocalizedString(@"Caveat", nil) andSuperView:view andFont:k14 andTextAligment:NSTextAlignmentCenter];
    jingGaoLable.layer.borderWidth = 0;
    [jingGaoLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(jingGaoIamgeView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW / 4, kScreenW / 14));
        make.top.mas_equalTo(jingGaoIamgeView.mas_bottom);
    }];
    jingGaoLable.textColor = [UIColor whiteColor];
    
    UILabel *tiShiLable = [UILabel creatLableWithTitle:NSLocalizedString(@"Follow these steps to troubleshoot possible problems and try again", nil) andSuperView:view andFont:k15 andTextAligment:NSTextAlignmentLeft];
    tiShiLable.layer.borderWidth = 0;
    [tiShiLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 14));
        make.top.mas_equalTo(view.mas_bottom).offset(kScreenW / 11.4);
    }];
    
    UILabel *firstLable = [UILabel creatLableWithTitle:NSLocalizedString(@"AddFailureSerVC_First", nil) andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentLeft];
    firstLable.numberOfLines = 0;
    firstLable.layer.borderWidth = 0;
    [firstLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 7));
        make.top.mas_equalTo(tiShiLable.mas_bottom).offset(15);
    }];
    
    
    UILabel *secondLable = [UILabel creatLableWithTitle:NSLocalizedString(@"AddFailureSerVC_Second", nil) andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentLeft];
    secondLable.layer.borderWidth = 0;
    [secondLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 14));
        make.top.mas_equalTo(firstLable.mas_bottom);
    }];
    
    UILabel *thirtLable = [UILabel creatLableWithTitle:NSLocalizedString(@"AddFailureSerVC_Thirt", nil) andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentLeft];
    thirtLable.layer.borderWidth = 0;
    [thirtLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 14));
        make.top.mas_equalTo(secondLable.mas_bottom);
    }];
    
    UILabel *forthLable = [UILabel creatLableWithTitle:NSLocalizedString(@"AddFailureSerVC_Forth", nil) andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentLeft];
    forthLable.numberOfLines = 0;
    forthLable.layer.borderWidth = 0;
    [forthLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 7));
        make.top.mas_equalTo(thirtLable.mas_bottom);
    }];
    
    tiShiLable.textColor = kWhiteColor;
    firstLable.textColor = kWhiteColor;
    secondLable.textColor = kWhiteColor;
    thirtLable.textColor = kWhiteColor;
    forthLable.textColor = kWhiteColor;
    
    
    UIButton *againBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"AddFailureSerVC_Again", nil) andBorderColor:kMainColor WithTarget:self andDoneAtcion:@selector(againBtnAction) andSuperView:self.view];
    
    [againBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 9.375));
        make.top.mas_equalTo(forthLable.mas_bottom).offset(kScreenH / 14.72);
    }];
    againBtn.layer.cornerRadius = kScreenW / 18.75;
    againBtn.backgroundColor = kCOLOR(239, 250, 253);
    
    UIButton *fanKuiBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"AddFailureSerVC_OnlineFeedback", nil) andBorderColor:kMainColor WithTarget:self andDoneAtcion:@selector(fanKuiBtnAction) andSuperView:self.view];
    [fanKuiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 8.3, kScreenW / 9.375));
        make.top.mas_equalTo(againBtn.mas_bottom).offset(kScreenW / 15);
    }];
    fanKuiBtn.layer.cornerRadius = kScreenW / 18.75;
    fanKuiBtn.backgroundColor = kCOLOR(159, 232, 247);
    
}

#pragma mark - 重试按钮点击事件
- (void)againBtnAction {
    
    AllTypeServiceViewController *allTypeVC = [[AllTypeServiceViewController alloc]init];
    allTypeVC.navigationItem.title = NSLocalizedString(@"addDevice", nil);
    [self.navigationController pushViewController:allTypeVC animated:YES];
    
}

#pragma mark - 在线反馈按钮点击事件
- (void)fanKuiBtnAction {
    
    UserFeedBackViewController *fanKuiVC = [[UserFeedBackViewController alloc]init];
    fanKuiVC.navigationItem.title = NSLocalizedString(@"AddFailureSerVC_OnlineFeedback", nil);
    [self.navigationController pushViewController:fanKuiVC animated:YES];
    
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
    if (_serviceModel.brand == nil) {
        _serviceModel.brand = @"";
    }
}

@end
