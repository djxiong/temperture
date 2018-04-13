//
//  RegisterViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/8.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "RegisterViewController.h"
#import "YinSiViewController.h"
#import "XieYiNeiRongViewController.h"
#import "AuthcodeView.h"
#import "AlertMessageView.h"
#import "PZXVerificationCodeView.h"
#import "MineSerivesViewController.h"
#import "TabBarViewController.h"
#import "TextFiledView.h"

@interface RegisterViewController ()
@property (nonatomic , retain) UITextField *accTectFiled;
@property (nonatomic , retain) UITextField *pwdTectFiled;
@property (nonatomic , retain) UITextField *verificationCodeTectFiled;
@property (nonatomic , strong) AuthcodeView *authView;

@property (nonatomic , strong) UIView *markView;

@property (nonatomic , strong) AlertMessageView *alertMessageView;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)whetherGegisterSuccess:(NSNotification *)post {
    NSString *success = post.userInfo[@"RegisterSuccess"];
    NSString *vercodeStr = post.userInfo[@"VercodeStr"];
//    NSLog(@"%@" , success);
    if ([success isEqualToString:@"YES"]) {
        
        [self cancleAtcion];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"user.phone":self.accTectFiled.text , @"user.password" : self.pwdTectFiled.text ,@"code" : vercodeStr , @"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]}];
        if ([kStanderDefault objectForKey:@"GeTuiClientId"]) {
            [parameters setObject:[kStanderDefault objectForKey:@"GeTuiClientId"] forKey:@"ua.clientId"];
        }
        [kStanderDefault setObject:self.pwdTectFiled.text forKey:@"password"];
        [kStanderDefault setObject:self.accTectFiled.text forKey:@"phone"];
        
        [kNetWork requestPOSTUrlString:kRegisterURL parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
            [kPlistTools saveDataToFile:responseObject name:UserData];
            NSInteger state = [responseObject[@"state"] integerValue];
            
            if (state == 0) {
                
                NSDictionary *user = responseObject[@"data"];
                
                [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
                [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    
                    [kWindowRoot presentViewController:[[TabBarViewController alloc]init] animated:YES completion:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                    
                } andSuperViewController:self Title:NSLocalizedString(@"Congratulations", nil)];
            }
        } failure:^(NSError * _Nonnull error) {
            [kNetWork noNetWork];
        }];
    }
}

#pragma mark - 设置UI
- (void)setUI{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whetherGegisterSuccess:) name:@"RegisterSuccess" object:nil];
    
    
    TextFiledView *accTextFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"EnterPhone", nil) andSuperView:self.view];
    [accTextFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kScreenH / 4.43);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.accTectFiled = accTextFiledView.subviews[0];
    
    TextFiledView *pwdTextFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"Please enter your password", nil) andSuperView:self.view];
    pwdTextFiledView.whetherdark = YES;
    [pwdTextFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(accTextFiledView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.pwdTectFiled = pwdTextFiledView.subviews[0];
    self.pwdTectFiled.keyboardType = UIKeyboardTypeDefault;
    self.pwdTectFiled.secureTextEntry = YES;
    
    TextFiledView *verCodeTextFiledView = [[TextFiledView alloc]initWithColor:[UIColor blackColor] andAlpthFloat:.3  andTextFiledPlaceHold:NSLocalizedString(@"Please enter verification code", nil) andSuperView:self.view];
    [verCodeTextFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pwdTextFiledView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 7.2));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    self.verificationCodeTectFiled = verCodeTextFiledView.subviews[0];
    
    self.authView = [[AuthcodeView alloc]init];
    [self.view addSubview:self.authView];
    [self.authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 5.35, kScreenW / 12.5));
        make.centerY.mas_equalTo(_verificationCodeTectFiled.mas_centerY);
        make.right.mas_equalTo(_verificationCodeTectFiled.mas_right);
    }];
    
    UIButton *registerBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"Sign up now", nil) withLabelFont:k18 andBackGroundColor:[UIColor colorWithHexString:@"192a2f"] WithTarget:self andDoneAtcion:@selector(registerAction) andSuperView:self.view];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 7.5));
        make.centerX.mas_equalTo(verCodeTextFiledView.mas_centerX);
        make.top.mas_equalTo(verCodeTextFiledView.mas_bottom).offset(kScreenH / 6.65);
    }];
    
    UILabel *changLable = [UILabel creatLableWithTitle:NSLocalizedString(@"Click 'Register Now' to indicate that you agree to abide by the cronator", nil) andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentCenter];
    changLable.textColor = kWhiteColor;
    changLable.layer.borderWidth = 0;
    [changLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 20));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(registerBtn.mas_bottom).offset(kScreenH / 5.55);
    }];
    
    UILabel *heLable = [UILabel creatLableWithTitle:NSLocalizedString(@"And", nil) andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentCenter];
    heLable.layer.borderWidth = 0;
    heLable.textColor = kWhiteColor;
    [heLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 20, kScreenW / 13));
        make.centerX.mas_equalTo(changLable.mas_centerX);
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    
    
    UILabel *xieYiLable = [UILabel creatLableWithTitle:NSLocalizedString(@"Agreement", nil) andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentRight];
    xieYiLable.textColor = kWhiteColor;
    xieYiLable.layer.borderWidth = 0;
    [xieYiLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 6, kScreenW / 14));
        make.right.mas_equalTo(heLable.mas_left);
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    xieYiLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapXieYi = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(xieYiAction)];
    [xieYiLable addGestureRecognizer:tapXieYi];
    
    
    
    UILabel *yinSiLable = [UILabel creatLableWithTitle:NSLocalizedString(@"Privacy Policy", nil) andSuperView:self.view andFont:k12 andTextAligment:NSTextAlignmentLeft];
    yinSiLable.textColor = kWhiteColor;
    yinSiLable.layer.borderWidth = 0;
    [yinSiLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(heLable.mas_right);
        make.size.mas_equalTo(CGSizeMake(kScreenW / 6, kScreenW / 14));
        make.top.mas_equalTo(changLable.mas_bottom);
    }];
    
    yinSiLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapYinSi = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yinSiAtcion)];
    [yinSiLable addGestureRecognizer:tapYinSi];
    
    self.markView = [[UIView alloc]initWithFrame:kScreenFrame];
    [self.view addSubview:self.markView];
    //模糊效果
    UIBlurEffect *light = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc]initWithEffect:light];
    bgView.frame = self.markView.bounds;
    [self.markView addSubview:bgView];
    self.markView.alpha = 0;
    
    self.alertMessageView = [[AlertMessageView alloc]initWithFrame:CGRectMake((kScreenW - kScreenW / 1.4) / 2, (kScreenH - kScreenH / 2.66) / 2, kScreenW / 1.4, kScreenH / 2.66) TitleText:NSLocalizedString(@"EnterVertionCode", nil) andBtnTarget:self andCancleAtcion:@selector(cancleAtcion)];
    [self.view addSubview:self.alertMessageView];

    self.alertMessageView.alpha = 0;
    
    
}

- (void)cancleAtcion {
    [UIView animateWithDuration:.3 animations:^{
        self.markView.alpha = 0;
        self.alertMessageView.alpha = 0;
    }];
    [self.view endEditing:YES];
}

#pragma mark - 隐私政策点击事件
- (void)yinSiAtcion{
    YinSiViewController *yinSiVC = [[YinSiViewController alloc]init];
    yinSiVC.navigationItem.title = NSLocalizedString(@"Privacy Policy", nil);
    [self.navigationController pushViewController:yinSiVC animated:YES];
}

#pragma mark - 用户协议点击事件
- (void)xieYiAction{
    XieYiNeiRongViewController *xieYiVC = [[XieYiNeiRongViewController alloc]init];
    xieYiVC.navigationItem.title = NSLocalizedString(@"Agreement", nil);
    [self.navigationController pushViewController:xieYiVC animated:YES];
}

#pragma mark - 立即注册按钮点击事件
- (void)registerAction{
    
    if (self.accTectFiled.text.length > 0 && self.pwdTectFiled.text.length > 0 && self.verificationCodeTectFiled.text.length > 0) {
        if (self.accTectFiled.text.length == 11 && [NSString validateNumber:self.accTectFiled.text] && self.pwdTectFiled.text.length >= 6 && self.pwdTectFiled.text.length <= 12 && [self.verificationCodeTectFiled.text isEqualToString:self.authView.authCodeStr]) {
            NSDictionary *parameters = @{@"phone":self.accTectFiled.text};
            
            [kNetWork requestPOSTUrlString:kJiaoYanZhangHu parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
                NSInteger state = [responseObject[@"state"] integerValue];
                if (state == 0) {
                    if (![self.verificationCodeTectFiled.text isEqualToString:self.authView.authCodeStr]) {
                        //验证不匹配，验证码和输入框抖动
                        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
                        anim.repeatCount = 1;
                        anim.values = @[@-20 , @20 , @-20];
                        [self.verificationCodeTectFiled.layer addAnimation:anim forKey:nil];
                        
                    } else {
                        
                        if (self.accTectFiled.text == nil) {
                            
                            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"AccEmpty", nil)];
                        } else {
                            
                            self.alertMessageView.phoneNumber = self.accTectFiled.text;
                            
                            [UIView animateWithDuration:.3 animations:^{
                                self.markView.alpha = .8;
                                self.alertMessageView.alpha = 1;
                                
                            }];
                            
                            
                            PZXVerificationCodeView *pzxView = [self.alertMessageView viewWithTag:10003];
                            UITextField *firstTf = [pzxView viewWithTag:100];
                            [firstTf becomeFirstResponder];
                            
                            CGRect frame = self.alertMessageView.frame;
                            int offset = frame.origin.y + frame.size.height - (kScreenH - (216+36)) + kScreenW / 10;
                            
                            NSTimeInterval animationDuration = 0.30f;
                            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
                            [UIView setAnimationDuration:animationDuration];
                            
                            if(offset > 0)
                            {
                                self.alertMessageView.frame = CGRectMake((kScreenW - kScreenW / 1.4) / 2, (kScreenH - kScreenH / 2.66) / 2 - offset, kScreenW / 1.4, kScreenH / 2.66);
                                
                            }
                            
                            [UIView commitAnimations];
                            
                        }
                    }
                    
                } else if (state == 1) {
                    [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"InputValueError", nil)];
                } else if (state == 3) {
                    
                    [UIAlertController creatRightAlertControllerWithHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    } andSuperViewController:self Title:NSLocalizedString(@"AccExiteSoLogin", nil)];
                }
            } failure:^(NSError * _Nonnull error) {
                [kNetWork noNetWork];
            }];
            
        } else {
            if (self.accTectFiled.text.length != 11) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    self.accTectFiled.text = nil;
                } andSuperViewController:self Title:NSLocalizedString(@"PhoneFormattedError", nil)];
            } else if ( self.pwdTectFiled.text.length < 6 || self.pwdTectFiled.text.length > 12) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    self.pwdTectFiled.text = nil;
                } andSuperViewController:self Title:NSLocalizedString(@"PwdFormat", nil)];
            } else if (![self.verificationCodeTectFiled.text isEqualToString:self.authView.authCodeStr]) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    self.verificationCodeTectFiled.text = nil;
                } andSuperViewController:self Title:NSLocalizedString(@"YourVerificationCodeErrorSoRe-Enter", nil)];
            }
        }
    } else {
        if (self.accTectFiled.text.length == 0) {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"PhoneNumberEmpty", nil)];
        } else if (self.pwdTectFiled.text.length == 0) {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"PwdEmpty", nil)];
        } else if (self.verificationCodeTectFiled.text.length == 0) {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"VerificationCodeEmpty", nil)];
        }
    }
}

#pragma mark - 点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

@end


