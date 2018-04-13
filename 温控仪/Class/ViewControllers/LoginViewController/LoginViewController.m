//
//  LoginViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"
#import "MineSerivesViewController.h"
#import "TabBarViewController.h"
#import "TextFiledView.h"


@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic , strong) UITextField *pwdTectFiled;
@property (nonatomic , strong) UITextField *acctextFiled;

@property (nonatomic , strong) UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    
   
    
}


#pragma mark - 设置UI界面
- (void)setUI{
    UIImageView *logoImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 3.5, kScreenW / 12.5));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(kScreenH / 7.5);
    }];
    
    TextFiledView *accFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"Please enter your account", nil) andSuperView:self.view];
    [accFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kScreenH / 3.5);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.acctextFiled = accFiledView.subviews[0];
    self.acctextFiled.keyboardType = UIKeyboardTypeDefault;
    

    TextFiledView *pwdFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"Please enter your password", nil) andSuperView:self.view];
    [pwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(accFiledView.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.pwdTectFiled = pwdFiledView.subviews[0];
    self.pwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    self.pwdTectFiled.secureTextEntry = YES;
    
    
    self.loginBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"Log in", nil) withLabelFont:k18 andBackGroundColor:[UIColor colorWithHexString:@"192a2f"] WithTarget:self andDoneAtcion:@selector(loginBtnAction) andSuperView:self.view];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 7.5));
        make.centerX.mas_equalTo(accFiledView.mas_centerX);
        make.top.mas_equalTo(pwdFiledView.mas_bottom).offset(kScreenH / 7);
    }];
    
    UIButton *registerBtn = [UIButton creatBtnWithTitle:[NSString stringWithFormat:@"%@>>" , NSLocalizedString(@"Sign up now", nil)] withLabelFont:k15 andBackGroundColor:nil WithTarget:self andDoneAtcion:@selector(registerBtnAction) andSuperView:self.view];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW / 2, kScreenW / 25));
        make.centerX.mas_equalTo(_loginBtn.mas_centerX);
        make.top.mas_equalTo(_loginBtn.mas_bottom).offset(kScreenH / 36.8);
    }];
    [registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIButton *resertBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"Forget password", nil) withLabelFont:k15 andBackGroundColor:nil WithTarget:self andDoneAtcion:@selector(forgetPwdBtnAction) andSuperView:self.view];
    [resertBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW / 2, kScreenW / 25));
        make.centerX.mas_equalTo(_loginBtn.mas_centerX);
        make.top.mas_equalTo(registerBtn.mas_bottom).offset(kScreenH / 4.6);
    }];
    [resertBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
}

#pragma mark - 注册用户
- (void)registerBtnAction{

    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.navigationItem.title = NSLocalizedString(@"RegistVC_Register", nil);
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - 忘记密码点击事件
- (void)forgetPwdBtnAction{
    
    ForgetPwdViewController *forgetPwdVC = [[ForgetPwdViewController alloc]init];
    forgetPwdVC.navigationItem.title = NSLocalizedString(@"ResetVC_ResetPwd", nil);
    [self.navigationController pushViewController:forgetPwdVC animated:YES];
}

#pragma mark - 登陆按钮点击事件
- (void)loginBtnAction{
    
    NSString *accText = [self.acctextFiled.text lowercaseString];
    NSString *pwdText = [self.pwdTectFiled.text lowercaseString];
    
    [kStanderDefault setObject:accText forKey:@"phone"];
    [kStanderDefault setObject:pwdText forKey:@"password"];
    
    if (([pwdText isEqualToString:@"admin"] || [pwdText isEqualToString:@"user"]) && [accText isEqualToString:pwdText]) {
//        NSDictionary *dic =  [kPlistTools readDataFromFile:UserData];
        NSDictionary *dic = [kPlistTools readDataFromBundle:UserData];
        [self setData:dic];
    } else if ( (self.acctextFiled.text.length == 11 || self.acctextFiled.text.length == 9) && [UITextField validateNumber:self.acctextFiled.text]  && self.pwdTectFiled.text != nil) {
    
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"loginName":self.acctextFiled.text , @"password" : self.pwdTectFiled.text ,@"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]}];
        if ([kStanderDefault objectForKey:@"GeTuiClientId"]) {
            [parameters setObject:[kStanderDefault objectForKey:@"GeTuiClientId"] forKey:@"ua.clientId"];
        }
        
        [kNetWork requestPOSTUrlString:kLogin parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
            
            NSInteger state = [responseObject[@"state"] integerValue];
            if (state == 0){
                [self setData:responseObject];
            } else {
                if (state == 1) {
                    [self setAlertText:NSLocalizedString(@"AccOrPwdEmpty", nil)];
                } else if (state == 2) {
                    [self setAlertText:NSLocalizedString(@"UserNoRegistered", nil)];
                } else {
                    [self setAlertText:NSLocalizedString(@"PwdError", nil)];
                }
            }
        } failure:^(NSError * _Nonnull error){
            
            [UIAlertController creatRightAlertControllerWithHandle:^{
                self.acctextFiled.text = nil;
                self.pwdTectFiled.text = nil;
            } andSuperViewController:self Title:NSLocalizedString(@"Currently no network, please login public account Admin", nil)];
        }];
    } else {
        if (self.acctextFiled.text.length == 0) {
            [self setAlertText:NSLocalizedString(@"AccEmpty", nil)];
        }
        if (self.pwdTectFiled.text.length == 0) {
            [self setAlertText:NSLocalizedString(@"PwdEmpty", nil)];
        }
        if (self.acctextFiled.text.length != 11 || self.acctextFiled.text.length != 9) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                self.acctextFiled.text = nil;
            } andSuperViewController:self Title:NSLocalizedString(@"AccountFormatInputError", nil)];
        }
    }
}

- (void)setData:(NSDictionary *)dic {
    
    [kPlistTools saveDataToFile:dic name:UserData];
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        [kWindowRoot presentViewController:[[TabBarViewController alloc]init] animated:YES completion:^{
            self.acctextFiled.text = nil;
            self.pwdTectFiled.text = nil;
        }];
    }
}

#pragma mark - 点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setAlertText:(NSString *)text {
    [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:text];
}
@end
