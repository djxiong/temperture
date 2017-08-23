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
#import "AllTypeServiceViewController.h"
#import "WeatherView.h"
#import "FirstUserAlertView.h"

@interface MineSerivesViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , HelpFunctionDelegate , CCLocationManagerZHCDelegate , UIGestureRecognizerDelegate>
@property (nonatomic , strong) UICollectionView *collectionView;

@property (nonatomic , strong) UIView *topView;
@property (nonatomic , strong) UIImageView *backImageView;
@property (nonatomic , strong) UIImage *werthImage;

@property (nonatomic , strong) NSMutableDictionary *wearthDic;

@property (nonatomic , strong) UIViewController *childViewController;
@property (nonatomic , strong) NSMutableArray *haveArray;
@property (nonatomic , copy) NSString *userSn;
@property (nonatomic , strong) ServicesModel *serviceModel;

@property (nonatomic , strong) UIView *markView;

@property (nonatomic , strong) NSArray *arrImage;
@end

@implementation MineSerivesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    
    if ([kStanderDefault objectForKey:@"userSn"]) {
        self.userSn = [kStanderDefault objectForKey:@"userSn"];
        kSocketTCP.userSn = [NSString stringWithFormat:@"%@" , [kStanderDefault objectForKey:@"userSn"]];
        [kSocketTCP socketConnectHost];
    }
    
    [self setNav];
    
    [self setUI];
    
    [self setAlertView];

}

- (void)setNav {
    self.navigationItem.title = @"启联者";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(addSerViceAtcion) image:@"addService_high" highImage:nil];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAtcion) image:nil highImage:nil];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
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

- (void)setAlertView {
    
    [[FirstUserAlertView alloc]creatAlertViewwithImage:@"alert1" deleteFirstObj:@"NO"];
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
 
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"20c3df"]};
    
    self.navigationController.navigationBar.hidden = NO;
    
    if (self.userSn && self.serviceModel) {
        [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@%@%@Q#" , self.userSn , self.serviceModel.devTypeSn , self.serviceModel.devSn] andType:kQuite andIsNewOrOld:nil];
    }

    [self requestWeather];
    
    NSDictionary *parameters = @{@"userSn": [kStanderDefault objectForKey:@"userSn"]};
    [HelpFunction requestDataWithUrlString:kQueryTheUserdevice andParames:parameters andDelegate:self];
    
}

- (void)requestWeather {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger nowTimeInterval = [NSString getNowTimeInterval];
            if ([kStanderDefault objectForKey:@"requestWeatherTime"]) {
                NSInteger weatherTime = [[kStanderDefault objectForKey:@"requestWeatherTime"] integerValue];
                NSLog(@"%@ , %@" , [NSString turnTimeIntervalToString:nowTimeInterval] , [NSString turnTimeIntervalToString:weatherTime]);
                if (nowTimeInterval > weatherTime + 1 * 3600) {
                    [kStanderDefault setObject:@(nowTimeInterval) forKey:@"requestWeatherTime"];
                    [self startWearthData];
                }
            } else {
                [kStanderDefault setObject:@(nowTimeInterval) forKey:@"requestWeatherTime"];
                [self startWearthData];
            }
        });
    });
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

#pragma mark - 设置UI界面
- (void)setUI{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
    layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
    
    //2.初始化collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kScreenH / 3.6 - 40, kScreenW, kScreenH - kScreenH / 3.6 + 40) collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.collectionView registerClass:[MineServiceCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    //添加轻扫手势
    UISwipeGestureRecognizer *swipeGesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture22:)];
    //设置轻扫的方向
    swipeGesture1.direction = UISwipeGestureRecognizerDirectionLeft; //默认向右
    [self.view addGestureRecognizer:swipeGesture1];
    
    
    UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH / 3.7 - 40 + kHeight, kScreenW, kScreenH - kScreenH / 3.7 - 29)];
    [self.view addSubview:markView];
    markView.backgroundColor = [UIColor colorWithHexString:@"f6f6f6"];
    self.markView = markView;
    
    
    UILabel *lable = [UILabel creatLableWithTitle:@"暂未添加任何设备" andSuperView:markView andFont:k17 andTextAligment:NSTextAlignmentCenter];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 2, kScreenW / 10));
        make.top.mas_equalTo(markView.mas_top).offset(kScreenH / 8.5);
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
    
    
    UIView *topView = [[UIView alloc]init];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenH / 3.9));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(kHeight);
    }];
    _topView = topView;
    
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"weather_bg"]];
    [topView addSubview:backImageView];
    [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenH / 3.6));
        make.centerX.mas_equalTo(topView.mas_centerX);
        make.centerY.mas_equalTo(topView.mas_centerY);
    }];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    _backImageView = backImageView;
    

    
    if ([kStanderDefault objectForKey:@"wearthDic"]) {
        self.wearthDic = [kStanderDefault objectForKey:@"wearthDic"];
        
    } else {
        
        [self.wearthDic setObject:@"==" forKey:@"quality"];
        [self.wearthDic setObject:@"==" forKey:@"humidity"];
        [self.wearthDic setObject:@"==" forKey:@"temp_curr"];
        [self.wearthDic setObject:@"==" forKey:@"weather_curr"];
        [self.wearthDic setObject:@"==" forKey:@"weather"];
        [self.wearthDic setObject:@"==" forKey:@"winp"];
        [self.wearthDic setObject:@(0) forKey:@"weather_icon"];
        [self.wearthDic setObject:@"==" forKey:@"cityName"];
        
    }
    
    [self getWeatherDic:self.wearthDic];
}

#pragma mark - 请求天气参数
- (void)startWearthData {
    [[CCLocationManager shareLocation] getNowCityNameAndProvienceName:self];
    
}

- (void)getCityNameAndProvience:(NSArray *)address {
    NSString *cityName = address[0];
    
    if ([cityName containsString:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length - 1];
    }
    
    [HelpFunction requestWeatherDataWithDelegate:self andCityName:cityName];
    [kStanderDefault setObject:cityName forKey:@"cityName"];
}



- (void)requestWearthData:(HelpFunction *)request didDone:(NSMutableArray *)array {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic = array[0];
    
    [kStanderDefault setObject:dic forKey:@"wearthDic"];
    
    self.wearthDic = dic;
    
    [self getWeatherDic:dic];
    
}

- (void)getWeatherDic:(NSMutableDictionary *)dic {
    
    NSString *imagetr = self.arrImage[[dic[@"weather_icon"] integerValue]];
    self.werthImage = [UIImage imageNamed:imagetr];
    
    NSArray *array = _backImageView.subviews;
    for (int i = 0; i < array.count; i++) {
        [array[i] removeFromSuperview];
    }
    
    [WeatherView creatViewWeatherDic:dic andSuperView:_backImageView andWearthImage:self.werthImage andMainColor:[UIColor whiteColor]];
    
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

#pragma mark - 开关的点击事件
- (void)addSerViceAtcion{

    AllTypeServiceViewController *allTypeServiceVC = [[AllTypeServiceViewController alloc]init];
    allTypeServiceVC.navigationItem.title = @"设备列表";
    [self.navigationController pushViewController:allTypeServiceVC animated:YES];
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
    [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@%@%@N#" , [kStanderDefault objectForKey:@"userSn"] , model.devTypeSn , model.devSn] andType:kAddService andIsNewOrOld:nil];
    
    HTMLBaseViewController *htmlVC = [[HTMLBaseViewController alloc]init];
    htmlVC.serviceModel = model;
    [self.navigationController pushViewController:htmlVC animated:YES];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenW - 1) / 2, kScreenH / 4.16);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
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

- (NSMutableDictionary *)wearthDic {
    if (!_wearthDic) {
        _wearthDic = [NSMutableDictionary dictionary];
    }
    return _wearthDic;
}


- (NSArray *)arrImage {
    if (!_arrImage) {
        _arrImage = [NSArray arrayWithObjects:@"qing", @"dayu", @"duoyun", @"feng", @"leiyu", @"mai", @"daxue",@"qingjianduoyun",@"wu",@"xiaoxue",@"xiaoyu",@"yin",@"yujiaxue",@"zhenyu",@"zhongxue",@"zhongyu", nil];
        
    }
    return _arrImage;
}

@end
