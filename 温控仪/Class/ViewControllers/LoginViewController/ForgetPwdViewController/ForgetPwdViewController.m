//
//  ForgetPwdViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/9.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "ChongZhiPwdViewController.h"
#import "TextFiledView.h"

@interface ForgetPwdViewController ()<UITextFieldDelegate>
@property (nonatomic , strong) UIButton *nextBtn2;

@property (nonatomic , strong) UITextField *pwdTectFiled;
@property (nonatomic , retain) UITextField *accTectFiled;
//倒计时长度
@property (nonatomic , assign) NSInteger secondsCountDown;
//定时器
@property (nonatomic , strong) NSTimer *countDownTimer;
//发送短信按钮
@property (nonatomic , strong)UIButton *sendDuanXinBtn;

@property (nonatomic , copy) NSString *userSn;
@property (nonatomic , strong) NSString *data;
@property (nonatomic , retain) NSString *message;
@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
    [self setUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

#pragma mark - 设置UI
- (void)setUI{

    TextFiledView *phoneFiledView = [[TextFiledView alloc]initWithColor:[UIColor colorWithHexString:@"1281a2"] andAlpthFloat:.25 andTextFiledPlaceHold:NSLocalizedString(@"Please enter your mobile number", nil) andSuperView:self.view];
    [phoneFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(kHeight);
    }];
    self.accTectFiled = phoneFiledView.subviews[0];
    
  
    TextFiledView *pwdFiledView = [[TextFiledView alloc]initWithColor:[UIColor colorWithHexString:@"1281a2"] andAlpthFloat:.45 andTextFiledPlaceHold:NSLocalizedString(@"Please enter verification code", nil) andSuperView:self.view];
    pwdFiledView.whetherdark = YES;
    [pwdFiledView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenW / 8.3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(phoneFiledView.mas_bottom);
    }];
    self.pwdTectFiled = pwdFiledView.subviews[0];
    
    self.sendDuanXinBtn = [UIButton initWithTitle:NSLocalizedString(@"SendSMSCode", nil) andColor:kMainColor andSuperView:pwdFiledView];
    [self.sendDuanXinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 3.75, kScreenW / 15));
        make.centerY.mas_equalTo(pwdFiledView.mas_centerY);
        make.right.mas_equalTo(pwdFiledView.mas_right).offset(-kScreenW / 25);
    }];
    self.sendDuanXinBtn.titleLabel.font = [UIFont systemFontOfSize:k12];
    [self.sendDuanXinBtn addTarget:self action:@selector(sendDuanXinBtnAtcion) forControlEvents:UIControlEventTouchUpInside];
    self.sendDuanXinBtn.layer.cornerRadius = kScreenW / 30;
    
    
    UIButton *nextBtn = [UIButton creatBtnWithTitle:NSLocalizedString(@"Sure", nil) andBorderColor:kMainColor WithTarget:self andDoneAtcion:@selector(nextBtnAtcion2) andSuperView:self.view];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2, kScreenW / 10));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(pwdFiledView.mas_bottom)
        .offset(kScreenW / 8.33);
    }];
    nextBtn.layer.cornerRadius = kScreenW / 20;
    nextBtn.backgroundColor = kWhiteColor;
    
    if (self.phoneNumber != nil) {
        self.accTectFiled.text = self.phoneNumber;
        self.accTectFiled.userInteractionEnabled = NO;
    }
    
}

#pragma mark - 发送短信按钮60S倒计时
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([kStanderDefault objectForKey:@"sendTimeInterVal"]) {
        NSInteger currentTimeInterval = [NSString getNowTimeInterval];
        
        NSInteger sendEmailTimeInterval = [[kStanderDefault objectForKey:@"sendTimeInterVal"] integerValue];
        
        if (currentTimeInterval >= sendEmailTimeInterval + 60) {
            [kStanderDefault removeObjectForKey:@"sendTimeInterVal"];

            [self.sendDuanXinBtn setTitle:NSLocalizedString(@"SendSMSCode", nil) forState:UIControlStateNormal];
            self.sendDuanXinBtn.backgroundColor = kMainColor;
            self.sendDuanXinBtn.userInteractionEnabled = YES;
            
            [_countDownTimer invalidate];
            _countDownTimer = nil;
            _secondsCountDown = 60;
        } else {
            
            _secondsCountDown = sendEmailTimeInterval + 60 - currentTimeInterval;
            self.sendDuanXinBtn.userInteractionEnabled = NO;
            self.sendDuanXinBtn.backgroundColor = [UIColor grayColor];
            
            [_countDownTimer invalidate];
            _countDownTimer = nil;
            _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
        }
        
    }
    
}


#pragma mark - 确定点击事件
- (void)nextBtnAtcion2{
    
    if ([_pwdTectFiled.text isEqualToString:[NSString stringWithFormat:@"%@" , _data]] && self.accTectFiled.text.length == 11) {
        ChongZhiPwdViewController *chongZhiPwd = [[ChongZhiPwdViewController alloc]init];
        chongZhiPwd.phoneNumber = [NSString stringWithFormat:@"%@" , self.accTectFiled.text];
        chongZhiPwd.userSn = self.userSn;
        chongZhiPwd.navigationItem.title = NSLocalizedString(@"ResetVC_ResetPwd", nil);
        [self.navigationController pushViewController:chongZhiPwd animated:YES];
        
        [kStanderDefault removeObjectForKey:@"sendTimeInterVal"];
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    } else {
        
        if (self.accTectFiled.text.length != 11) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                self.accTectFiled.text = nil;
            } andSuperViewController:self Title:NSLocalizedString(@"YourPhoneNumberErrorSoRe-Enter", nil)];
        } else if (![_pwdTectFiled.text isEqualToString:[NSString stringWithFormat:@"%@" , _data]]) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                self.pwdTectFiled.text = nil;
            } andSuperViewController:self Title:NSLocalizedString(@"YourVerificationCodeErrorSoRe-Enter", nil)];
        }
    }
    
}


#pragma mark - 发送按钮点击事件
- (void)sendDuanXinBtnAtcion{
    
    if (self.accTectFiled.text.length == 11) {
        NSDictionary *parameters = @{@"phone":self.accTectFiled.text};
        
        [kNetWork requestPOSTUrlString:kJiaoYanZhangHu parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
            
            //    NSLog(@"%@" , dddd);
            
            NSInteger state = [responseObject[@"state"] integerValue];
            if (state == 0) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    self.accTectFiled.text = nil;
                } andSuperViewController:self Title:NSLocalizedString(@"ThisAccNoExist", nil)];
            } else if (state == 1) {
                [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:NSLocalizedString(@"InputValueError", nil)];
            } else if (state == 3) {
                self.sendDuanXinBtn.userInteractionEnabled = NO;
                self.sendDuanXinBtn.backgroundColor = [UIColor grayColor];
                
                self.secondsCountDown = 60;
                self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                NSInteger sendTimeInterVal = [NSString getNowTimeInterval];
                [kStanderDefault setObject:@(sendTimeInterVal) forKey:@"sendTimeInterVal"];
                
                
                NSDictionary *parameters = @{@"dest":self.accTectFiled.text , @"bool" : @(1)};
                
                [kNetWork requestPOSTUrlString:kFaSongDuanXin parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
                    NSDictionary *dic = responseObject;
                    
                    if (dic[@"data"]) {
                        NSInteger state = [dic[@"state"] integerValue];
                        
                        if (state == 0) {
                            NSDictionary *data = dic[@"data"];
                            NSString *code = data[@"code"];
                            NSString *userSn = data[@"userSn"];
                            
                            self.data = code;
                            _userSn = userSn;
                            NSLog(@"%@ , %@" , self.data , userSn);
                        }
                    }
                } failure:^(NSError * _Nonnull error) {
                    [kNetWork noNetWork];
                }];
            }
        } failure:^(NSError * _Nonnull error) {
            [kNetWork noNetWork];
        }];
    } else {
        [UIAlertController creatRightAlertControllerWithHandle:^{
            self.pwdTectFiled.text = nil;
        } andSuperViewController:self Title:NSLocalizedString(@"PhoneFormattedError", nil)];
    }
    
}

-(void)timeFireMethod{
    [self.sendDuanXinBtn setTitle:[NSString stringWithFormat:@"%lds%@",(long)self.secondsCountDown , NSLocalizedString(@"AfterSecondsRe-Send", nil)] forState:UIControlStateNormal];
    
    if(self.secondsCountDown==0){
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        self.data = 0;
        [self.sendDuanXinBtn setTitle:NSLocalizedString(@"SendSMSCode", nil) forState:UIControlStateNormal];
        self.sendDuanXinBtn.backgroundColor = kMainColor;
        self.sendDuanXinBtn.userInteractionEnabled = YES;
    }
    
    self.secondsCountDown--;
}

#pragma mark - 点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
