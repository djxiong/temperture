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
#import "AllServicesCollectionViewCell.h"

@interface AllServicesViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout,  HelpFunctionDelegate>
@property (nonatomic , strong) NSMutableArray *array;
@property (nonatomic , strong) NSMutableArray *addModelArray;
@property (nonatomic , strong) UICollectionView *collectionView;
@end

@implementation AllServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"serviceList"]];
    imageView.frame = kScreenFrame;
    [self.view addSubview:imageView];
    
}

- (void)setUI {
    [self initCollectionView];
}


/** 控制器初始化的同时设置布局参数给collectionView */
- (void)initCollectionView{
    
    /** 创建布局参数 */
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(30, 40);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScreenW / 25, kHeight, kScreenW - kScreenW * 2 / 25, (NSInteger)(((CGFloat)self.array.count / 2) + 0.5) * kScreenH / 5.12) collectionViewLayout:flowLayout];
    
    /** 注册cell可重用ID */
    [self.collectionView registerClass:[AllServicesCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.layer.cornerRadius = 5;
    self.collectionView.layer.masksToBounds = YES;
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSDictionary *parames = @{@"typeSn":@"41"};
    [HelpFunction requestDataWithUrlString:kGengDuoChanPin andParames:parames andDelegate:self];
    
}
#pragma mark - 代理返回的数据
- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    NSDictionary *dic = data[0];
//    NSLog(@"%@" , dic);
    
    self.array = [NSMutableArray array];
    self.addModelArray = [NSMutableArray array];
    if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
        NSArray *arr = [NSArray arrayWithArray:dic[@"data"]];
        
        for (NSDictionary *dd in arr) {
            
            ServicesModel *model = [[ServicesModel alloc]init];
            [model setValuesForKeysWithDictionary:dd];
            if (![dd[@"slType"] isKindOfClass:[NSNull class]]) {
                model.slTypeInt = [dd[@"slType"] integerValue];
            }
            AddServiceModel *addModel = [[AddServiceModel alloc]init];
            [addModel setValuesForKeysWithDictionary:dd];
            [self.array addObject:model];
            [self.addModelArray addObject:addModel];
        }
        
    }
    
    [self setUI];
}

- (void)requestData:(HelpFunction *)request didFailLoadData:(NSError *)error {
    NSLog(@"%@" , error);
}

#pragma mark - collectionView有多少分区
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - 每个分区rows的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.array.count;
}

#pragma mark - 生成items
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AllServicesCollectionViewCell *cell = (AllServicesCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.dataCount = self.array.count;
    cell.indexPath = indexPath;
    ServicesModel *model = [[ServicesModel alloc]init];
    model = self.array[indexPath.row];
    cell.serviceModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ServicesModel *model = [[ServicesModel alloc]init];
    model = self.array[indexPath.row];
    
    AddServiceModel *addModel = [[AddServiceModel alloc]init];
    addModel = self.addModelArray[indexPath.row];
    
    SetServicesViewController *setSerVC = [[SetServicesViewController alloc]init];
    setSerVC.addServiceModel = addModel;
    setSerVC.navigationItem.title = @"添加设备";
    [self.navigationController pushViewController:setSerVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenW - kScreenW * 2 / 25) / 2, kScreenH / 5.12);
    
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//    return UIEdgeInsetsMake(0, kScreenW / 25, kScreenW / 25, kScreenW / 25);
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
