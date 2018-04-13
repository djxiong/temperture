//
//  AllServicesViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/11/8.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "AllServicesViewController.h"
#import "SetServicesViewController.h"
#import "ServicesModel.h"
#import "AddServiceModel.h"
#import "ChanPinShuoMingViewController.h"
#import "AllServicesCollectionViewCell.h"
#import "SearchServicesViewController.h"
#import "SetServicesViewController.h"
#import "HTMLBaseViewController.h"

#import "QQLBXScanViewController.h"
#import "Global.h"
#import "StyleDIY.h"
@interface AllServicesViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , SendServiceModelToParentVCDelegate>
@property (nonatomic , strong) NSMutableArray *modelArray;
@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , copy) NSString *userSn;
@end

@implementation AllServicesViewController

- (void)setupUI{
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"serviceList"]];
    imageView.frame = kScreenFrame;
    [self.view addSubview:imageView];
    
    /** 创建布局参数 */
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];

    flowLayout.itemSize = CGSizeMake((kScreenW - kScreenW * 8 / 75) / 2, kScreenH / 5.12);
    flowLayout.minimumLineSpacing = kScreenW * 2 / 75;
    flowLayout.sectionInset = UIEdgeInsetsMake(kScreenW * 2 / 75, kScreenW * 2 / 75, kScreenW * 2 / 75, kScreenW * 2 / 75);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kHeight, kScreenW, kScreenH) collectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];
    
    /** 注册cell可重用ID */
    [self.collectionView registerClass:[AllServicesCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self requestData];
}

- (void)requestData {
    NSDictionary *parames = @{@"typeSn":self.typeSn};
    
    [kNetWork requestPOSTUrlString:kGengDuoChanPin parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        [kPlistTools saveDataToFile:responseObject name:LittleTypesServicesData];
        [self setDataWith:responseObject];
    } failure:^(NSError * _Nonnull error) {
        if ([kPlistTools whetherExite:LittleTypesServicesData]) {
            NSDictionary *dic = [kPlistTools readDataFromFile:LittleTypesServicesData];
            [self setDataWith:dic];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"nonetwork", nil)];
        }
    }];
}

- (void)setDataWith:(NSDictionary *)dic {
    
    self.modelArray = [NSMutableArray array];
    if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
        NSArray *arr = [NSArray arrayWithArray:dic[@"data"]];
        
        for (NSDictionary *dd in arr) {
            
            ServicesModel *model = [[ServicesModel alloc]init];
            [model yy_modelSetWithDictionary:dd];
            [self.modelArray addObject:model];
        }
        
        [self.collectionView reloadData];
    }
    
}

#pragma mark - collectionView有多少分区
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - 每个分区rows的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}

#pragma mark - 生成items
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AllServicesCollectionViewCell *cell = (AllServicesCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.dataCount = self.modelArray.count;
    cell.indexPath = indexPath;
    ServicesModel *model = [[ServicesModel alloc]init];
    model = self.modelArray[indexPath.row];
    cell.serviceModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ServicesModel *model = [[ServicesModel alloc]init];
    model = self.modelArray[indexPath.row];
    if (!model.remark) {
        model.remark = NSLocalizedString(@"Specified WIFI", nil);
    }
    if ([self.navigationItem.title isEqualToString:NSLocalizedString(@"addDevice", nil)]) {
        
        if ([model.typeNumber isEqualToString:@"7931A"]) {
            [UIAlertController creatSheetControllerWithFirstHandle:^{
                NSString *phone = [kStanderDefault objectForKey:@"phone"];
                if ([phone isEqualToString:@"admin"] || [phone isEqualToString:@"user"]) {
                    [UIAlertController creatRightAlertControllerWithHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    } andSuperViewController:self Title:NSLocalizedString(@"CannotAddDevice", nil)];
                }
                
                QQLBXScanViewController *vc = [QQLBXScanViewController new];
                vc.libraryType = [Global sharedManager].libraryType;
                vc.scanCodeType = [Global sharedManager].scanCodeType;
                vc.style = [StyleDIY qqStyle];
                vc.serviceModel = model;
                vc.isVideoZoom = YES;
                [self.navigationController pushViewController:vc animated:YES];
            } andFirstTitle:NSLocalizedString(@"Binding device", nil) andSecondHandle:nil andSecondTitle:nil andThirtHandle:nil andThirtTitle:nil andForthHandle:nil andForthTitle:nil andSuperViewController:self];
        } else {
            [UIAlertController creatSheetControllerWithFirstHandle:^{
                
                SetServicesViewController *setserVC = [[SetServicesViewController alloc]init];
                setserVC.serviceModel = model;
                setserVC.navigationItem.title = NSLocalizedString(@"addDevice", nil);
                [self.navigationController pushViewController:setserVC animated:YES];
            } andFirstTitle:NSLocalizedString(@"Equipment Distribution Network", nil) andSecondHandle:^{
                
                NSString *phone = [kStanderDefault objectForKey:@"phone"];
                if ([phone isEqualToString:@"admin"] || [phone isEqualToString:@"user"]) {
                    [UIAlertController creatRightAlertControllerWithHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    } andSuperViewController:self Title:NSLocalizedString(@"CannotAddDevice", nil)];
                }
                
                QQLBXScanViewController *vc = [QQLBXScanViewController new];
                vc.libraryType = [Global sharedManager].libraryType;
                vc.scanCodeType = [Global sharedManager].scanCodeType;
                vc.style = [StyleDIY qqStyle];
                vc.serviceModel = model;
                vc.isVideoZoom = YES;
                [self.navigationController pushViewController:vc animated:YES];
            } andSecondTitle:NSLocalizedString(@"Binding device", nil) andThirtHandle:^{
                if (![[kNetWork getWifiName] isEqualToString:model.remark]) {
                    [UIAlertController creatRightAlertControllerWithHandle:^{
                        [kNetWork pushToWIFISetVC];
                        return ;
                    } andSuperViewController:self Title:[NSString stringWithFormat:@"%@'%@'%@" , NSLocalizedString(@"Not connected to the specified", nil) , model.remark , NSLocalizedString(@"WIFI cannot use direct connection mode", nil)]];
                }
                
                
                HTMLBaseViewController *htmlVC = [[HTMLBaseViewController alloc]init];
                htmlVC.connectState = CONNECTED_ZHILIAN;
                htmlVC.serviceModel = model;
                htmlVC.delegate = self;
                kSocketTCP.serviceModel = model;
                [kSocketTCP socketConnectHostWith:KQILIANHost port:kQILIAN_TCP_Port];
                kSocketTCP.whetherConnected = YES;
                
                [self.navigationController pushViewController:htmlVC animated:YES];
            } andThirtTitle:NSLocalizedString(@"Direct connection mode", nil) andForthHandle:nil andForthTitle:nil andSuperViewController:self];
        }
        
        
    } else {
        ChanPinShuoMingViewController *chanPinShuoMingVC = [[ChanPinShuoMingViewController alloc]init];
        chanPinShuoMingVC.typeSn = self.typeSn;
        chanPinShuoMingVC.serviceModel = model;
        [self.navigationController pushViewController:chanPinShuoMingVC animated:YES];
    }
    
}

- (void)serviceCurrentConnectedState:(CONNECTED_STATE)state {
    if (state == CONNECTED_ZHILIAN) {
        if (self.userSn) {
            NSString *userSn = [NSString toHex:self.userSn.integerValue];
            if (userSn.length != 8) {
                userSn = [NSString stringWithFormat:@"0%@" , userSn];
            }
            
            kSocketTCP.userSn = userSn;
            [kSocketTCP socketConnectHostWith:KALIHost port:kALIPort];
        }
    }
}

- (NSString *)userSn {
    if (!_userSn ) {
        if ([kStanderDefault objectForKey:@"userSn"]) {
            _userSn = [kStanderDefault objectForKey:@"userSn"];
        } else {
            _userSn = nil;
        }
        
    }
    return _userSn;
}

@end
