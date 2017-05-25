//
//  AllTypeServiceViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/11/7.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "AllTypeServiceViewController.h"
#import "AllServicesViewController.h"


@interface AllTypeServiceViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , copy) NSString *devType;
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation AllTypeServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}

- (void)setUI {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"serviceList"]];
    imageView.frame = kScreenFrame;
    self.tableView.backgroundView = imageView;
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *celled = @"celled";
    
    UITableViewCell *cell
    =[tableView dequeueReusableCellWithIdentifier:celled];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:celled];
    }
    
    cell.textLabel.text = @"温控仪";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.textColor = kMainColor;
    cell.backgroundColor = [UIColor clearColor];
    cell.tintColor = kMainColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AllServicesViewController *allServiceVC = [[AllServicesViewController alloc]init];
    allServiceVC.navigationItem.title = @"温控仪";
    [self.navigationController pushViewController:allServiceVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return kScreenH / 14.46;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
