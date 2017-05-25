//
//  SetServicesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "SetServicesViewController.h"
#import "WiFiViewController.h"
#import "MineSerivesViewController.h"
@interface SetServicesViewController ()
@property (nonatomic , strong) NSMutableArray *array;
@property (nonatomic , strong) NSTimer *myTimer;
@property (nonatomic , strong) UIImageView *switchImage;
@end

@implementation SetServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
    
     [self setUI];
}

#pragma mark - 设置UI
- (void)setUI {
    
    UIImage *image = nil;

    image = [UIImage imageNamed:@"wifianjianpeiwangmoshi0"];
    
    _switchImage = [[UIImageView alloc]initWithImage:image];
    [self.view addSubview:_switchImage];
    [_switchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenH / 3, kScreenH / 3));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(kScreenH / 11 + kHeight);
    }];

    UILabel *firstLable = [UILabel creatLableWithTitle:[NSString stringWithFormat:@"请开机长按功能按键3秒，听到“滴”的声音后指示灯闪烁，进入配网模式。（wifi功能按键请查看说明书）"] andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    firstLable.textColor = [UIColor whiteColor];
    firstLable.layer.borderWidth = 0;
    [firstLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenH / 2.5 , kScreenW / 5));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(_switchImage.mas_bottom).offset(kScreenH / 8.5);
    }];
    
    
    UIButton *neaxtBtn = [UIButton creatBtnWithTitle:@"下一步" andBorderColor:kMainColor WithTarget:self andDoneAtcion:@selector(neaxtBtnAction) andSuperView:self.view];
    neaxtBtn.layer.cornerRadius = kScreenW / 18;
    neaxtBtn.backgroundColor = kCOLOR(239, 250, 253);
    [neaxtBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenH / 3, kScreenW / 9));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(firstLable.mas_bottom).offset(kScreenH /  22.30303);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(qieHuanTuPian) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_myTimer invalidate];
    _myTimer = nil;
}

- (void)qieHuanTuPian{
    
    if ([_switchImage.image isEqual:[UIImage imageNamed:@"wifianjianpeiwangmoshi1"]]) {
        [self qieHuanTuPianGuan];
    } else{
        [self qieHuanTuPianKai];
    }
}

- (void)qieHuanTuPianKai{
    
    _switchImage.image = [UIImage imageNamed:@"wifianjianpeiwangmoshi1"];
    
}

- (void)qieHuanTuPianGuan{
    
    _switchImage.image = [UIImage imageNamed:@"wifianjianpeiwangmoshi0"];
    
}

#pragma mark - 下一步按钮点击事件
- (void)neaxtBtnAction {

    WiFiViewController *wifiVC = [[WiFiViewController alloc]init];
    wifiVC.navigationItem.title = @"添加设备";
    wifiVC.addServiceModel = self.addServiceModel;
    [self.navigationController pushViewController:wifiVC animated:YES];
    
}

@end
