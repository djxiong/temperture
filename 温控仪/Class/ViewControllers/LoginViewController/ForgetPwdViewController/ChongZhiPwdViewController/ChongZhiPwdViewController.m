//
//  ChongZhiPwdViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/9.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "ChongZhiPwdViewController.h"
#import "MineSerivesViewController.h"
#import "TabBarViewController.h"
@interface ChongZhiPwdViewController ()<UITextFieldDelegate>

@end

@implementation ChongZhiPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setUI];
}
#pragma mark - 设置UI
- (void)setUI{
    
    UIView *pwdFiledView = [UIView creatViewWithFiledCoradiusOfPlaceholder:NSLocalizedString(@"Please enter your password", nil) andSuperView:self.view];
    [pwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW / 15.625, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(10 + kHeight);
    }];
    self.pwdTectFiled = pwdFiledView.subviews[0];
    
    UIView *againPwdFiledView = [UIView creatViewWithFiledCoradiusOfPlaceholder:NSLocalizedString(@"Please re-enter your password", nil) andSuperView:self.view];
    [againPwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW / 15.625, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(pwdFiledView.mas_bottom).offset(10);
    }];
    self.againPwdTectFiled = againPwdFiledView.subviews[0];
    
    self.pwdTectFiled.secureTextEntry = YES;
    self.againPwdTectFiled.secureTextEntry = YES;
    self.pwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    self.againPwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    
    UIButton *submitBtn = [UIButton initWithTitle:NSLocalizedString(@"Submit", nil) andColor:[UIColor redColor] andSuperView:self.view];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2.8, kScreenW / 9.4));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(againPwdFiledView.mas_bottom).offset(kScreenW / 13.7);
    }];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:k14];
    submitBtn.layer.cornerRadius = kScreenW / 18.8;
    submitBtn.backgroundColor = kMainColor;
    [submitBtn addTarget:self action:@selector(doneBtnAtcion) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 输入框代理
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text.length >= 6 && textField.text.length <= 16) {
        if ([textField isEqual:self.againPwdTectFiled]) {
            if (![self.pwdTectFiled.text isEqualToString:self.againPwdTectFiled.text] && self.pwdTectFiled.text.length > 0 && self.againPwdTectFiled.text.length > 0) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    self.pwdTectFiled.text = nil;
                    self.againPwdTectFiled.text = nil;
                } andSuperViewController:self Title:NSLocalizedString(@"PwdTwiceDifferentRe-enter", nil)];
            }
        }
    } else {

        [UIAlertController creatRightAlertControllerWithHandle:^{
            textField.text = nil;
        } andSuperViewController:self Title:NSLocalizedString(@"PwdTwiceDifferentRe-enter", nil)];
    }
}


#pragma mark - 确定按钮点击事件
- (void)doneBtnAtcion{

    if (self.pwdTectFiled.text.length >= 6 && self.againPwdTectFiled.text.length >= 6 && self.pwdTectFiled.text.length <= 16 && self.againPwdTectFiled.text.length <= 16) {
        if ([self.pwdTectFiled.text isEqualToString:self.againPwdTectFiled.text]) {
            NSDictionary *parameters = @{@"userSn":self.userSn , @"newPassword" : self.againPwdTectFiled.text};
            NSLog(@"%@" , parameters);
            
            [kNetWork requestPOSTUrlString:kChongZhiMiMa parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
                NSInteger state = [responseObject[@"state"] integerValue];
                if (state == 0) {
                    
                    NSDictionary *parameters = @{@"loginName":self.phoneNumber , @"password" : self.againPwdTectFiled.text , @"ua.phoneType" : @(2)};
                    
                    [kStanderDefault setObject:self.againPwdTectFiled.text forKey:@"password"];
                    [kStanderDefault setObject:self.phoneNumber forKey:@"phone"];
                    [kNetWork requestPOSTUrlString:kLogin parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
                        NSDictionary *dic = responseObject;
                        if ([dic[@"state"] integerValue] == 0) {
                            NSDictionary *user = dic[@"data"];
                            
                            [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
                            [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
                            
                            
                            if ([[kPlistTools getPresentedViewController] isKindOfClass:[TabBarViewController class]]) {
                                [UIAlertController creatRightAlertControllerWithHandle:^{
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                } andSuperViewController:self Title:NSLocalizedString(@"Password reset complete", nil)];
                            } else {
                                [kWindowRoot presentViewController:[[TabBarViewController alloc]init] animated:YES completion:^{
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }];
                            }
                        }
                    } failure:^(NSError * _Nonnull error) {
                        [kNetWork noNetWork];
                    }];
                    
                } else if (state == 1) {
                    [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"PwdEnterError", nil)];
                } else {
                    
                    [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"SystemErrorRestall", nil)];
                }
            } failure:^(NSError * _Nonnull error) {
                [kNetWork noNetWork];
            }];
            
        } else {
           
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"PwdTwiceDifferentRe-enter", nil)];
        }
    } else {
        
        [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"PwdFormat", nil)];
    }
}

#pragma mark - 点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
