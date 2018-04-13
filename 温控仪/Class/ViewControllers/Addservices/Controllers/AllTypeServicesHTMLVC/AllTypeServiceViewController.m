//
//  AllTypeServiceViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/11/7.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "AllTypeServiceViewController.h"
#import "AllServicesViewController.h"
#import "FirstUserAlertView.h"
#import "AllTypeServiceModel.h"
#import "AllTypeServiceTableViewCell.h"


@interface AllTypeServiceViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , copy) NSString *devType;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) NSMutableArray *typeSnAry;
@property (nonatomic , strong) NSIndexPath *selectedIndexPath;

@end

@implementation AllTypeServiceViewController

- (NSMutableArray *)typeSnAry {
    if (!_typeSnAry) {
        _typeSnAry = [NSMutableArray array];
    }
    return _typeSnAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
    
    [self setAlertView];
    
    [self requestAllTypesService];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
}

- (void)setAlertView {
    [[FirstUserAlertView alloc]creatAlertViewwithImage:@"alert2" deleteFirstObj:@"YES"];
}

- (void)setUI {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"serviceList"]];
    imageView.frame = kScreenFrame;
    self.tableView.backgroundView = imageView;
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
}

- (void)requestAllTypesService {
    [kNetWork requestPOSTUrlString:kAllTypeServiceURL parameters:nil isSuccess:^(NSDictionary * _Nullable responseObject) {
        
        [kPlistTools saveDataToFile:responseObject name:BigTypesServicesData];
        
        [self setDataWith:responseObject];
        
    } failure:^(NSError * _Nonnull error) {
        if ([kPlistTools whetherExite:BigTypesServicesData]) {
            NSDictionary *dic = [kPlistTools readDataFromFile:BigTypesServicesData];
            [self setDataWith:dic];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"nonetwork", nil)];
        }
    }];
}

- (void)setDataWith:(NSDictionary *)dic {
    if ([dic[@"data"] isKindOfClass:[NSArray class]]) {
        NSArray *arr = [NSArray arrayWithArray:dic[@"data"]];
        
        for (NSDictionary *dd in arr) {
            AllTypeServiceModel *model = [[AllTypeServiceModel alloc]init];
            [model yy_modelSetWithDictionary:dd];
            [self.dataArray addObject:model];
            [self.typeSnAry addObject:[NSString stringWithFormat:@"%@" , model.typeSn]];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *celled = @"celled";
    
    AllTypeServiceTableViewCell *cell
    =[tableView dequeueReusableCellWithIdentifier:celled];
    if (!cell) {
        cell = [[AllTypeServiceTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:celled];
    }
    cell.count = self.dataArray.count;
    cell.indePath = indexPath;
    AllTypeServiceModel *allTypeServiceModel = _dataArray[indexPath.row];
    cell.allTypeServiceModel = allTypeServiceModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AllTypeServiceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    self.selectedIndexPath = indexPath;
    return YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath) {
        AllTypeServiceTableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selectedImage.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *typeSn = self.typeSnAry[indexPath.row];
    
    AllServicesViewController *allServiceVC = [[AllServicesViewController alloc]init];
    allServiceVC.navigationItem.title = self.navigationItem.title;
    allServiceVC.typeSn = typeSn;
    [self.navigationController pushViewController:allServiceVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kScreenH / 13;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end

