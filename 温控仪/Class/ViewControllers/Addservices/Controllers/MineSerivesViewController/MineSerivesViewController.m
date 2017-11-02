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



@interface MineSerivesViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , HelpFunctionDelegate , CCLocationManagerZHCDelegate , UIGestureRecognizerDelegate , SendServiceModelToParentVCDelegate>
@property (nonatomic , strong) UICollectionView *collectionView;


@property (nonatomic , strong) UIViewController *childViewController;
@property (nonatomic , strong) NSMutableArray *haveArray;
@property (nonatomic , copy) NSString *userSn;
@property (nonatomic , strong) ServicesModel *serviceModel;

@property (nonatomic , strong) UIView *markView;

@end

@implementation MineSerivesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    
    if ([kStanderDefault objectForKey:@"userSn"]) {
        NSString *sn = [kStanderDefault objectForKey:@"userSn"];
        self.userSn = [NSString toHex:sn.integerValue];
        kSocketTCP.userSn = self.userSn;
        [kSocketTCP socketConnectHostWith:KALIHost port:kALIPort];
    }
    
    [self setNav];
    
    [self setUI];

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
    
    if (self.userSn && self.serviceModel) {
        [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@%@Q#" , self.userSn , self.serviceModel.devSn] andType:kQuite andIsNewOrOld:nil];
    }
    
    if ([kStanderDefault objectForKey:@"userSn"] != nil || [kStanderDefault objectForKey:@"userSn"] != NULL) {
        NSDictionary *parameters = @{@"userSn": [kStanderDefault objectForKey:@"userSn"]};
        [HelpFunction requestDataWithUrlString:kQueryTheUserdevice andParames:parameters andDelegate:self];
    }
}



- (void)setNav {
    self.navigationItem.title = @"启联者";
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
    
    
    UILabel *lable = [UILabel creatLableWithTitle:@"暂未添加任何设备" andSuperView:markView andFont:k17 andTextAligment:NSTextAlignmentCenter];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2, kScreenW / 10));
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    lable.textColor = [UIColor colorWithHexString:@"b4b4b4"];
    lable.layer.borderWidth = 0;
    
    UIButton *button = [UIButton initWithTitle:@"添加设备" andColor:kFenGeXianYanSe andSuperView:markView];
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

#pragma mark - 获取代理的数据
- (void)requestData:(HelpFunction *)requset queryUserdevice:(NSDictionary *)dddd{
    NSInteger state = [dddd[@"state"] integerValue];
    if (state == 0) {
        
        if ([dddd[@"data"] isKindOfClass:[NSNull class]]) {
            self.markView.hidden = NO;
            return ;
        }
        NSMutableArray *dataArray = dddd[@"data"];
        
        if (dataArray.count > 0) {
            [self.haveArray removeAllObjects];
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = obj;
                
                if ([dic[@"brand"] isKindOfClass:[NSNull class]]) {
                    [dic setValue:@"" forKey:@"brand"];
                }
                
                ServicesModel *serviceModel = [[ServicesModel alloc]init];
                [serviceModel setValuesForKeysWithDictionary:dic];
                serviceModel.userDeviceID = [obj[@"id"] integerValue];
                serviceModel.ifConn = [obj[@"ifConn"] integerValue];
                [_haveArray addObject:serviceModel];
            }];
            [kStanderDefault setObject:@"YES" forKey:@"isHaveService"];
            
            if (self.haveArray.count > 0) {
                self.markView.hidden = YES;
                [self.collectionView reloadData];
            } else {
                self.markView.hidden = NO;
            }
            
        }
    }
}

- (void)requestData:(HelpFunction *)request didFailLoadData:(NSError *)error {
    NSLog(@"%@" , error);
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

#pragma mark - 添加设备的点击事件
- (void)addSerViceAtcion{

    AllTypeServiceViewController *allTypeVC = [[AllTypeServiceViewController alloc]init];
    allTypeVC.navigationItem.title = @"添加设备";
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
    
    [kApplicate initServiceModel:model];
    kSocketTCP.serviceModel = model;
    [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@%@N#" , self.userSn ,  model.devSn] andType:kAddService andIsNewOrOld:nil];
    
    HTMLBaseViewController *htmlVC = [[HTMLBaseViewController alloc]init];
    htmlVC.serviceModel = model;
    htmlVC.sendServiceModelToParentVCDelegate = self;
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
