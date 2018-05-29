//
//  UserMessageViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/16.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "UserMessageViewController.h"
#import "MineYouHuiQuanViewController.h"
#import "ForgetPwdViewController.h"
#import "TabBarViewController.h"
#import "MineViewController.h"
#import "XMGNavigationController.h"

#import "LocationPickerVC.h"
#import "NiChengViewController.h"
#import "LoginViewController.h"
#import "UserInfoCommonCell.h"
#import "GeRenModel.h"

#import "CustomPickerView.h"
#import "NSBundle+Language.h"

#import <AVFoundation/AVFoundation.h>
@interface UserMessageViewController ()<UITableViewDataSource , UITableViewDelegate , SendDiZhiDataToProvienceVCDelegate , SendNickOrEmailToPreviousVCDelegate, CustomPickerViewDelegate>

@property (strong, nonatomic)  CustomPickerView *myDatePicker;
@property (nonatomic , strong) CustomPickerView *sexPicker;
@property (nonatomic , strong) CustomPickerView *languagesPicker;
@property (nonatomic , strong) NSArray *sexArray;
@property (nonatomic,strong) NSMutableDictionary *languagesDic;
@property (nonatomic,strong) NSArray *languageAry;

@property (nonatomic , strong) GeRenModel *geRenModel;
@property (nonatomic , strong) DiZhiModel *diZhiModel;
@property (nonatomic , strong) NSIndexPath *selectedIndexPath;

@property (nonatomic , strong) NSMutableArray *infoArray;
@end

static NSString *celled = @"celled";
@implementation UserMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.tableView registerClass:[UserInfoCommonCell class] forCellReuseIdentifier:celled];
    
    if ([kStanderDefault objectForKey:@"GeRenInfo"] != nil) {
        self.geRenModel = [[GeRenModel alloc]init];
        [self.geRenModel setValuesForKeysWithDictionary:[kStanderDefault objectForKey:@"GeRenInfo"]];
        NSLog(@"%@" , self.geRenModel);
    }
    
    [kNetWork requestPOSTUrlString:kChaXunYongHuDiZhi parameters:@{@"userSn" : @(self.userModel.sn)} isSuccess:^(NSDictionary * _Nullable responseObject) {
        //    NSLog(@"%@" , data[0]);
        NSDictionary *dic = responseObject;
        
        if (![dic[@"data"] isKindOfClass:[NSArray class]]) {
            return ;
        } else {
            NSArray *aray = [NSArray arrayWithArray:dic[@"data"]];
            NSDictionary *dd = aray[0];
            
            self.diZhiModel = [[DiZhiModel alloc]init];
            
            [self.diZhiModel yy_modelSetWithDictionary:dd];
            
            for (NSString *key in dd) {
                if ([key isEqualToString:@"id"]) {
                    self.diZhiModel.idd = [dd[key] integerValue];
                }
            }
            
            [self.tableView reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    if (self.selectedIndexPath) {
        UserInfoCommonCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selectedImage.hidden = YES;
    }
    
    NSString *nickName = nil;
    NSInteger sex = 0;
    NSString *birthday = nil;
    NSString *address = nil;
    NSString *email = nil;
    
    for (int i = 1; i < 6; i++) {
        UserInfoCommonCell *cell = [self tableViewindexPathForRow:i inSection:0];
        switch (i) {
            case 1:
                nickName = cell.rightLabel.text;
                break;
            case 2:
                sex = [cell.rightLabel.text isEqualToString:@"男"] ? 1 : 2;
                break;
            case 3:
                birthday = cell.rightLabel.text;
                break;
            case 4:
                address = cell.rightLabel.text;
                break;
            case 5:
                email = cell.rightLabel.text;
                break;
            default:
                break;
        }
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:nickName , @"nickName", @(sex) , @"sex" , birthday , @"birthday" , email ,@"email", address , @"address" , nil];
    NSLog(@"%@" , dic);
    [kStanderDefault setValue:dic forKey:@"GeRenInfo"];
    
}

#pragma mark - TableView的代理事件
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UserInfoCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:celled];
    cell.userModel = self.userModel;
    cell.indexPath = indexPath;
    
    if (indexPath.section != 2) {
        NSArray *array = self.infoArray[indexPath.section];
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.headPortraitImageView.image = array[0];
            cell.currentVC = self;
        } else if (indexPath.section == 1 && indexPath.row == 2) {
            cell.idLabel.text = array[indexPath.row];
        } else {
            cell.rightLabel.text = array[indexPath.row];
        }
    }
    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    }
    
    UserInfoCommonCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    self.selectedIndexPath = indexPath;
    return YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath) {
        UserInfoCommonCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selectedImage.hidden = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) return 6;
    else if (section == 1) return 3;
    else return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return kScreenH / 8.3;
    } else return kScreenH / 14.46;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kScreenW / 27;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 5)) {

        NiChengViewController *nickNameVC = [[NiChengViewController alloc]init];
        if (indexPath.row == 5) {
            nickNameVC.navigationItem.title = NSLocalizedString(@"Email", nil);
        } else if (indexPath.row == 1) {
            nickNameVC.navigationItem.title = NSLocalizedString(@"NickName", nil);
        }
        nickNameVC.delegate = self;
        nickNameVC.userModel = self.userModel;
        [self.navigationController pushViewController:nickNameVC animated:YES];
    } else if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3)) {
        
        if (indexPath.row == 2) {
            self.sexPicker = [[CustomPickerView alloc]initWithPickerViewType:UIPickerViewTypeOfSex andBackColor:kMainColor];
            [self.view addSubview:self.sexPicker];
            self.sexPicker.delegate = self;
        } else if (indexPath.row == 3) {
            self.myDatePicker = [[CustomPickerView alloc]initWithPickerViewType:UIPickerViewTypeOfBirthday andBackColor:kMainColor];
            [self.view addSubview:self.myDatePicker];
            self.myDatePicker.delegate = self;
        }
        
        
    }  else if (indexPath.section == 0 && indexPath.row == 4) {
        LocationPickerVC *diZhiVC = [[LocationPickerVC alloc]init];
        diZhiVC.userModel = self.userModel;
        diZhiVC.diZhiModel = self.diZhiModel;
        diZhiVC.delegate = self;
        diZhiVC.navigationItem.title = NSLocalizedString(@"My Address", nil);
        [self.navigationController pushViewController:diZhiVC animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (indexPath.row == 0) {
            
            ForgetPwdViewController *forgetPwdVC = [[ForgetPwdViewController alloc]init];
            forgetPwdVC.navigationItem.title = NSLocalizedString(@"Change Password", nil);
            forgetPwdVC.phoneNumber = [kStanderDefault objectForKey:@"phone"];
            [self.navigationController pushViewController:forgetPwdVC animated:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        if (indexPath.row == 1) {
            self.languagesPicker = [[CustomPickerView alloc]initWithPickerViewType:UIPickerViewTypeOfLanguages data:self.languagesDic andBackColor:kMainColor];
            [self.view addSubview:self.languagesPicker];
            self.languagesPicker.delegate = self;
        }
        
    } else if (indexPath.section == 2) {
        
        if ([kApplicate.window.rootViewController isKindOfClass:[TabBarViewController class]]) {
            [[CZNetworkManager shareCZNetworkManager] removeAllObjectOfStanderDefault];
            
            
            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
            kWindowRoot = nav;
            
        } else {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[CZNetworkManager shareCZNetworkManager] removeAllObjectOfStanderDefault];
            }];
        }
        
    }
}

- (void)sendPickerViewToVC:(UIPickerView *)picker {
    if (self.sexPicker) {
        UserInfoCommonCell *cell = [self tableViewindexPathForRow:2 inSection:0];
        cell.rightLabel.text = [NSString stringWithFormat:@"%@" , self.sexArray[[picker selectedRowInComponent:0]]];
        
        NSString *sexText = cell.rightLabel.text;
        NSInteger sex = 0;
        if ([sexText isEqualToString:@"男"]) {
            sex = 1;
        } else {
            sex = 2;
        }
        
        self.sexPicker = nil;
        NSDictionary *parames = @{@"user.sn" : @(self.userModel.sn) , @"user.sex" : @(sex)};
        
        [kNetWork requestPOSTUrlString:kXiuGaiXinXi parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
    }
    
    if (self.languagesPicker) {
        UserInfoCommonCell *cell = [self tableViewindexPathForRow:1 inSection:1];
        NSInteger index = [picker selectedRowInComponent:0];
        NSString *language = self.languageAry[index];
        cell.rightLabel.text = language;
        if ([language isEqualToString:@"中文"]) {
            language = @"zh-Hans";
        } else if ([language isEqualToString:@"英文"]) {
            language = @"en";
        }
        
        [self changeLanguageTo:language];
    }
}


- (void)changeLanguageTo:(NSString *)language {
    // 设置语言
    [NSBundle setLanguage:language];
    
    // 然后将设置好的语言存储好，下次进来直接加载
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"myLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    kWindowRoot = [[TabBarViewController alloc]init];
}

- (UserInfoCommonCell *)tableViewindexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:section];
    UserInfoCommonCell *cell = (UserInfoCommonCell *)[self.tableView cellForRowAtIndexPath:indexpath];
    return cell;
}

- (void)sendDatePickerViewToVC:(UIDatePicker *)datePicker {
    
    if (self.myDatePicker) {
        NSDate *date = datePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString *time = [dateFormatter stringFromDate:date];
        UserInfoCommonCell *cell = [self tableViewindexPathForRow:3 inSection:0];
        cell.rightLabel.text= time;
        self.myDatePicker = nil;
        
        NSDictionary *parames = @{@"user.sn" : @(self.userModel.sn) , @"user.birthdate" : time};
        NSLog(@"%@" , parames);
        [kNetWork requestPOSTUrlString:kXiuGaiXinXi parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
    
    
    
}

- (void)sendDiZhiDataToProvienceVC:(NSString *)diZhiStr {
    UserInfoCommonCell *cell = [self tableViewindexPathForRow:4 inSection:0];
    cell.rightLabel.text = diZhiStr;
}

- (void)sendNickOrEmailToPreviousVC:(NSArray *)nickOrEmailArr {
    
    NSString *info = nickOrEmailArr[0];
    NSString *navTitle = nickOrEmailArr[1];
    
    NSIndexPath *indexPath = nil;
    if ([navTitle isEqualToString:NSLocalizedString(@"NickName", nil)]) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        self.userModel.nickname = info;
        
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"niCheng" object:nil userInfo:[NSDictionary dictionaryWithObject:info forKey:@"niCheng"]]];
        
    } else {
        indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        self.userModel.email = info;
    }
    UserInfoCommonCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.rightLabel.text = info;
    
}


- (void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;

    if ([kStanderDefault objectForKey:@"GeRenInfo"]) {
        
        NSDictionary *dic = [kStanderDefault objectForKey:@"GeRenInfo"];
        
        GeRenModel *model = [[GeRenModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        _userModel.nickname = model.nickName;
        _userModel.sex = model.sex;
        _userModel.birthdate = model.birthday;
        _userModel.email = model.email;
    }
}

- (NSArray *)sexArray {
    if (!_sexArray) {
        _sexArray = [NSArray arrayWithObjects:@"男",@"女", nil];
    }
    return _sexArray;
}

- (NSMutableDictionary *)languagesDic {
    if (!_languagesDic) {
        _languagesDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.languageAry, @0 , nil];
    }
    return _languagesDic;
}

- (NSArray *)languageAry {
    if (!_languageAry) {
        _languageAry = [NSArray arrayWithObjects:@"中文", @"英文" ,  nil];
    }
    return _languageAry;
}

- (NSMutableArray *)infoArray {
    if (!_infoArray) {
        _infoArray = [NSMutableArray array];
        
        NSMutableArray *firstSectionArray = [NSMutableArray array];
        NSMutableArray *secondSectionArray = [NSMutableArray array];
        if (self.headImage) {
            [firstSectionArray addObject:self.headImage];
        } else {
            [firstSectionArray addObject:[UIImage imageNamed:@"iconfont-touxiang"]];
        }
        
        if (self.userModel.nickname == nil || [self.userModel.nickname isKindOfClass:[NSNull class]]) {
            [firstSectionArray addObject:NSLocalizedString(@"NickName", nil)];
        } else {
            [firstSectionArray addObject:self.userModel.nickname];
        }
        
        if (self.userModel.sex == 1){
            [firstSectionArray addObject:NSLocalizedString(@"Male", nil)];
        } else {
            [firstSectionArray addObject:NSLocalizedString(@"Female", nil)];
        }
        
        if ([self.userModel.birthdate isKindOfClass:[NSNull class]] || self.userModel.birthdate == nil) {
            [firstSectionArray addObject:NSLocalizedString(@"Please select birthday", nil)];
        } else {
            [firstSectionArray addObject:self.userModel.birthdate];
        }
        
        if (self.geRenModel.address != nil) {
            [firstSectionArray addObject:[NSString stringWithFormat:@"%@" , self.geRenModel.address]];
        } else {
            [firstSectionArray addObject:NSLocalizedString(@"Please enter the address", nil)];
        }
        
        
        if ([self.userModel.email isKindOfClass:[NSNull class]] || self.userModel.email == nil) {
            [firstSectionArray addObject:NSLocalizedString(@"Please input your email", nil)];
        } else {
            [firstSectionArray addObject:self.userModel.email];
        }
        [secondSectionArray addObject:@""];
        
        if ([NSString getCurrentLanguage]) {
            [secondSectionArray addObject:[NSString getCurrentLanguage]];
        } else {
            [secondSectionArray addObject:@"中文"];
        }
        
        
        [secondSectionArray addObject:[NSString stringWithFormat:@"%ld" , (long)self.userModel.sn]];
        
        [_infoArray addObject:firstSectionArray];
        [_infoArray addObject:secondSectionArray];
        
    }
    return _infoArray;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
