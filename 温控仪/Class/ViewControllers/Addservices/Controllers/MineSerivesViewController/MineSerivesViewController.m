//
//  MineSerivesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/1.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "MineSerivesViewController.h"
#import "MineServiceCollectionViewCell.h"
#import "SetServicesViewController.h"
#import "HTMLBaseViewController.h"
#import "CCLocationManager.h"
#import "FirstUserAlertView.h"
#import "AllTypeServiceViewController.h"
#import "XMGRefreshFooter.h"
#import "XMGRefreshHeader.h"

@interface MineSerivesViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , CCLocationManagerZHCDelegate , UIGestureRecognizerDelegate , SendServiceModelToParentVCDelegate>
@property (nonatomic , strong) UICollectionView *collectionView;


@property (nonatomic , strong) UIViewController *childViewController;
@property (nonatomic , strong) NSMutableArray *haveArray;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) UIView *markView;

@property (nonatomic , copy) NSString *userSn;
@property (nonatomic , copy) NSString *userHexSn;

@end

@implementation MineSerivesViewController

- (NSString *)userSn {
    if (!_userSn) {
        if ([kStanderDefault objectForKey:@"userSn"]) {
            _userSn = [kStanderDefault objectForKey:@"userSn"];
        }
    }
    return _userSn;
}

- (NSString *)userHexSn {
    if (!_userHexSn) {
        _userHexSn = [NSString toHex:self.userSn.integerValue];
        if (_userHexSn.length != 8) {
            _userHexSn = [NSString stringWithFormat:@"0%@" , _userHexSn];
        }
    }
    return _userHexSn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    
    if (self.userSn) {
        kSocketTCP.userSn = self.userHexSn;
        [kSocketTCP socketConnectHostWith:KALIHost port:kALIPort];
    }
    
    [self setNotifai];
    
    [self setNav];
    
    [self setUI];

    [self setRefresh];
    
    [[CCLocationManager shareLocation] getNowCityNameAndProvienceName:self];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0f3649"]};
    
    for (int i = 0; i < self.haveArray.count; i++) {
        MineServiceCollectionViewCell *cell = (MineServiceCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.selectedImage.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"20c3df"]};
    
    self.navigationController.navigationBar.hidden = NO;
    
    if (self.userHexSn && self.serviceModel) {
        [kSocketTCP sendDataToHost:nil andType:kQuite];
    }
    
}

- (void)setNotifai {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bindService) name:BindService object:nil];
}

- (void)setRefresh{
    
    self.collectionView.mj_header = [XMGRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(setData)];
    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark - 绑定成功刷新数据
- (void)bindService {
    [self setData];
}

- (void)setData {
    if (self.userSn) {
        
        NSDictionary *parameters = @{@"userSn": @(self.userSn.integerValue)};
        
        [kNetWork requestPOSTUrlString:kQueryTheUserdevice parameters:parameters isSuccess:^(NSDictionary * _Nullable responseObject) {
            
            [kPlistTools saveDataToFile:responseObject name:MineServicesData];
            NSInteger state = [responseObject[@"state"] integerValue];
            if (state == 0) {
                [self setDataWith:responseObject];
            }
            
        } failure:^(NSError * _Nonnull error){
            if ([kPlistTools whetherExite:MineServicesData]) {
                NSDictionary *dic = [kPlistTools readDataFromFile:MineServicesData];
                [self setDataWith:dic];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"nonetwork", nil)];
            }
        }];
    }
}

- (void)setDataWith:(NSDictionary *)dic {
    
    NSInteger state = [dic[@"state"] integerValue];
    if (state == 0) {
        
        if ([dic[@"data"] isKindOfClass:[NSNull class]]) {
            self.markView.hidden = NO;
            [_haveArray removeAllObjects];
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
            return ;
        }
        NSMutableArray *dataArray = dic[@"data"];
        
        if (dataArray.count > 0) {
            [self.haveArray removeAllObjects];
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = obj;
                
                ServicesModel *serviceModel = [[ServicesModel alloc]init];
                [serviceModel yy_modelSetWithDictionary:dic];
                [_haveArray addObject:serviceModel];
            }];
            [kStanderDefault setObject:@"YES" forKey:@"isHaveService"];
            
            if (self.haveArray.count > 0) {
                self.markView.hidden = YES;
            } else {
                self.markView.hidden = NO;
            }
        } else {   
            self.markView.hidden = NO;
        }
        
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
    }
}

- (void)setNav {
    self.navigationItem.title = NSLocalizedString(@"Company_name", nil);
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(addSerViceAtcion) image:@"addService_high" highImage:nil];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAtcion) image:nil highImage:nil];
    self.navigationController.interactivePopGestureRecognizer
    .delegate = self;
    
}


#pragma mark - 设置UI界面
- (void)setUI{
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"serviceList"]];
    imageView.frame = kScreenFrame;
    [self.view addSubview:imageView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kScreenW - 1) / 2, kScreenH / 4.16);
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.headerReferenceSize = CGSizeMake(kScreenW, 10);
//    layout.sectionInset = UIEdgeInsetsMake(-50, 0, 0, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kHeight, kScreenW, kScreenH - kHeight - self.tabBarController.tabBar.size.height) collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerClass:[MineServiceCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UISwipeGestureRecognizer *swipeGesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture22:)];
    swipeGesture1.direction = UISwipeGestureRecognizerDirectionLeft; //默认向右
    [self.view addGestureRecognizer:swipeGesture1];
    
    
    UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, kHeight, kScreenW, kScreenH - kHeight)];
    [self.view addSubview:markView];
    markView.backgroundColor = [UIColor clearColor];
    self.markView = markView;
    
    
    UILabel *lable = [UILabel creatLableWithTitle:NSLocalizedString(@"noDevice", nil) andSuperView:markView andFont:k17 andTextAligment:NSTextAlignmentCenter];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2, kScreenW / 10));
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    lable.textColor = [UIColor colorWithHexString:@"b4b4b4"];
    lable.layer.borderWidth = 0;
    
    UIButton *button = [UIButton initWithTitle:NSLocalizedString(@"addDevice", nil) andColor:kFenGeXianYanSe andSuperView:markView];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2.6, kScreenW / 11));
        make.top.mas_equalTo(lable.mas_bottom).offset(kScreenH / 4);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    button.layer.cornerRadius = kScreenW / 22;
    button.layer.masksToBounds = YES;
    button.backgroundColor = kCOLOR(28, 164, 252);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(addSerViceAtcion) forControlEvents:UIControlEventTouchUpInside];
    
    self.markView.hidden = YES;
    
    
}


- (void)backAtcion {
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self.fromAddVC isEqualToString:@"YES"]) {
        return NO;
    } else {
        return YES;
    }
    
}

- (void)getCityNameAndProvience:(NSArray *)address {
    NSString *cityName = address[0];
    
    if ([cityName containsString:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length - 1];
    }
    [kStanderDefault setObject:cityName forKey:@"cityName"];
}

#pragma mark - 向右滑动返回主界面
- (void)swipeGesture22:(UISwipeGestureRecognizer *)swipe {
    
    if (_childViewController) {
        [self.navigationController pushViewController:_childViewController animated:YES];
    }
    
}

- (void)sendViewControllerToParentVC:(UIViewController *)viewController {
    _childViewController = viewController;
    
}

- (void)sendServiceModelToParentVC:(ServicesModel *)serviceModel {
    self.serviceModel = serviceModel;
}

- (void)whetherDelegateService:(BOOL)delateService {
    if (delateService) {
        [self setData];
    }
}

#pragma mark - 添加设备的点击事件
- (void)addSerViceAtcion{

    AllTypeServiceViewController *allTypeVC = [[AllTypeServiceViewController alloc]init];
    allTypeVC.navigationItem.title = NSLocalizedString(@"addDevice", nil);
    [self.navigationController pushViewController:allTypeVC animated:YES];
    
}

#pragma mark - collectionView有多少分区
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - 每个分区rows的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.haveArray.count;
}

#pragma mark - 生成items
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   MineServiceCollectionViewCell *cell = (MineServiceCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    ServicesModel *model1 = [[ServicesModel alloc]init];
    
    model1 = self.haveArray[indexPath.row];
    
    cell.indexPath = indexPath;
    
    cell.serviceModel = model1;
    
    return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    MineServiceCollectionViewCell *cell = (MineServiceCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    MineServiceCollectionViewCell *cell = (MineServiceCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedImage.hidden = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MineServiceCollectionViewCell *cell = (MineServiceCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    
    ServicesModel *model = [[ServicesModel alloc]init];
    model = self.haveArray[indexPath.row];
    
    kSocketTCP.whetherConnected = NO;
    [kApplicate initServiceModel:model];
    [kApplicate initUserHexSn:self.userHexSn];
    
    kSocketTCP.serviceModel = model;

    [kSocketTCP sendDataToHost:nil andType:kAddService];
    
    HTMLBaseViewController *htmlVC = [[HTMLBaseViewController alloc]init];
    htmlVC.connectState = CONNECTED_CONNECTALI;
    htmlVC.serviceModel = model;
    htmlVC.delegate = self;
    [self.navigationController pushViewController:htmlVC animated:YES];
}

- (NSMutableArray *)haveArray {
    if (!_haveArray) {
        _haveArray = [NSMutableArray array];
    }
    return _haveArray;
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

@end
