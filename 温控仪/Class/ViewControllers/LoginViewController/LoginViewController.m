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


@interface LoginViewController ()<UITextFieldDelegate  , HelpFunctionDelegate>

@property (nonatomic , strong) UITextField *pwdTectFiled;
@property (nonatomic , strong) UITextField *acctextFiled;

@property (nonatomic , strong) UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];

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
    
    TextFiledView *accFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"LoginVC_AccPlaceholder", nil) andSuperView:self.view];
    [accFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kScreenH / 3.5);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.acctextFiled = accFiledView.subviews[0];
    

    TextFiledView *pwdFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"LoginVC_PwdPlacrholder", nil) andSuperView:self.view];
    [pwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(accFiledView.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.pwdTectFiled = pwdFiledView.subviews[0];
    self.pwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    self.pwdTectFiled.secureTextEntry = YES;
    
    
    self.loginBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"LoginVC_login", nil) withLabelFont:k18 andBackGroundColor:[UIColor colorWithHexString:@"192a2f"] WithTarget:self andDoneAtcion:@selector(loginBtnAction) andSuperView:self.view];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 7.5));
        make.centerX.mas_equalTo(accFiledView.mas_centerX);
        make.top.mas_equalTo(pwdFiledView.mas_bottom).offset(kScreenH / 7);
    }];
    
    UIButton *registerBtn = [UIButton creatBtnWithTitle:[NSString stringWithFormat:@"%@>>" , NSLocalizedString(@"LoginVC_Register", nil)] withLabelFont:k15 andBackGroundColor:nil WithTarget:self andDoneAtcion:@selector(registerBtnAction) andSuperView:self.view];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW / 2, kScreenW / 25));
        make.centerX.mas_equalTo(_loginBtn.mas_centerX);
        make.top.mas_equalTo(_loginBtn.mas_bottom).offset(kScreenH / 36.8);
    }];
    [registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIButton *resertBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"LoginVC_ForgetPwd", nil) withLabelFont:k15 andBackGroundColor:nil WithTarget:self andDoneAtcion:@selector(forgetPwdBtnAction) andSuperView:self.view];
    [resertBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW / 2, kScreenW / 25));
        make.centerX.mas_equalTo(_loginBtn.mas_centerX);
        make.top.mas_equalTo(registerBtn.mas_bottom).offset(kScreenH / 4.6);
    }];
    [resertBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:kMainColor];
}

#pragma mark - 注册用户
- (void)registerBtnAction{

    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.navigationItem.title = @"注册";
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - 忘记密码点击事件
- (void)forgetPwdBtnAction{
    
    ForgetPwdViewController *forgetPwdVC = [[ForgetPwdViewController alloc]init];
    forgetPwdVC.navigationItem.title = @"重置密码";
    [self.navigationController pushViewController:forgetPwdVC animated:YES];
}


#pragma mark - 登陆按钮点击事件
- (void)loginBtnAction{

    
    if ( (self.acctextFiled.text.length == 11 || self.acctextFiled.text.length == 9) && [UITextField validateNumber:self.acctextFiled.text]  && self.pwdTectFiled.text != nil) {
        
        [SVProgressHUD show];
        NSDictionary *parameters = @{@"loginName":self.acctextFiled.text , @"password" : self.pwdTectFiled.text,@"ua.phoneType" : @(2)};
        
        [kStanderDefault setObject:self.pwdTectFiled.text forKey:@"password"];
        [kStanderDefault setObject:self.acctextFiled.text forKey:@"phone"];

        [HelpFunction requestDataWithUrlString:kLogin andParames:parameters andDelegate:self];
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

#pragma mark - 登陆的数据
- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    [SVProgressHUD dismiss];
    
    NSDictionary *dic = data[0];
//    NSLog(@"%@" , dic);
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        UserModel *userModel = [[UserModel alloc]init];
        for (NSString *key in [user allKeys]) {
            [userModel setValue:user[key] forKey:key];
        }
        
        kSocketTCP.userSn = [NSString stringWithFormat:@"%ld" , (long)userModel.sn];
        [kSocketTCP socketConnectHost];
        
        [kWindowRoot presentViewController:[[TabBarViewController alloc]init] animated:YES completion:^{
            self.acctextFiled.text = nil;
            self.pwdTectFiled.text = nil;
        }];
        
    } else {
        NSInteger state = [dic[@"state"] integerValue];
        if (state == 1) {
            [self setAlertText:NSLocalizedString(@"AccOrPwdEmpty", nil)];
        } else if (state == 2) {
            [self setAlertText:NSLocalizedString(@"UserNoRegistered", nil)];
        } else {
            [self setAlertText:NSLocalizedString(@"PwdError", nil)];
        }
    }
}


- (void)requestData:(HelpFunction *)request didFailLoadData:(NSError *)error {
    NSLog(@"%@" , error);
    [SVProgressHUD dismiss];
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
