//
//  SystemMessageViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/2/5.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "SystemMessageViewController.h"
#import "SystemMessageAndMineMessageTableViewCell.h"
#import "SystemMessageModel.h"
#import "SystemMessageWebViewController.h"
#import "XMGRefreshFooter.h"
#import "XMGRefreshHeader.h"
#import "SystemMessageNoMore.h"
#import "MineMessageVC.h"

@interface SystemMessageViewController ()<UITableViewDataSource , UITableViewDelegate>{
    NSUInteger pages;
}
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) SystemMessageNoMore *noMoreView;
@property (nonatomic , strong) UITableView *tableView;
@end

@implementation SystemMessageViewController
- (void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setUI];
    
    if (self.presentVC) {
        [self setNav];
    }
    
}

#pragma mark - 设置UI
- (void)setUI{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - kHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.noMoreView = [[SystemMessageNoMore alloc]initWithFrame:CGRectMake(kScreenW / 6, kScreenH - 88 - 64, kScreenW * 2 / 3, 44)];
    [self.view addSubview:self.noMoreView];
    self.noMoreView.alpha = 0;
    
    [self setRefresh];
    
}

- (void)setNav{
    self.navigationController.navigationBar.hidden = false;
    self.navigationItem.title = NSLocalizedString(@"System Information", nil);
    self.navigationItem.leftBarButtonItem = nil;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"navigationButtonReturn"] forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithHexString:@"00a2ff"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:k15];
    [backButton sizeToFit];
    // 这句代码放在sizeToFit后面
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [backButton addTarget:self action:@selector(backAtcion) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backAtcion {
    [self dismissViewControllerAnimated:YES completion:^{
        self.presentVC = false;
    }];
}

- (void)setRefresh{
    
    self.tableView.mj_header = [XMGRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [XMGRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
}

- (void)loadNewTopics {
    pages = 1;
    [self requestDataWith:pages];
}

- (void)loadMoreTopics {
    pages++;
    [self requestDataWith:pages];
}

- (void)requestDataWith:(NSInteger)page {
    NSDictionary *parames = nil;
    NSString *url = nil;
    if ([self.navigationItem.title isEqualToString:NSLocalizedString(@"System Information", nil)]) {
        parames = @{@"page" : @(pages) , @"rows" : @10};
        url = kSystemMessageJieKou;
    } else {
        parames = @{@"page" : @(pages) , @"rows" : @10 , @"userSn":@(self.userModel.sn)};
        url = kMyMessageJieKou;
    }
    [self loadData:parames withUrl:url];
}

- (void)loadData:(NSDictionary *)parames withUrl:(NSString *)url{
    
    
    [kNetWork requestPOSTUrlString:url parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        
        if ([responseObject[@"total"] isKindOfClass:[NSNull class]]) {
            [self noHaveMessage];
            return ;
        }
        
        NSInteger total = [responseObject[@"total"] integerValue];
        if (total > 0) {
            
            NSArray *data = responseObject[@"rows"];
            
            if (data.count > 0) {
                
                if (pages == 1) [self.dataArray removeAllObjects];
                [data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SystemMessageModel *model = [[SystemMessageModel alloc]init];
                    [model yy_modelSetWithDictionary:obj];
                    [self.dataArray addObject:model];
                }];
                
                SystemMessageModel *model = [[SystemMessageModel alloc]init];
                model = [self.dataArray firstObject];
                [kStanderDefault setValue:model.addTime forKey:@"SystemMessageTime"];
                
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            } else {
                [self noHaveMessage];
            }
        } else if (total == 0) {
            [self noHaveMessage];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self noHaveMessage];
    }];
}

- (void)noHaveMessage {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];

    
    [UIView animateWithDuration:0.5 animations:^{
        self.noMoreView.alpha = 1;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.noMoreView.alpha = 0;
        }];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString * identy = @"headFoot";
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identy];
    if (!view) {
        view = [[UIView alloc]init];
    }
    view.backgroundColor = kCOLOR(244, 244, 244);
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenH / 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *celled = @"celled";
    
    SystemMessageAndMineMessageTableViewCell *cell
    =[tableView dequeueReusableCellWithIdentifier:celled];
    if (!cell) {
        cell = [[SystemMessageAndMineMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
    }
    SystemMessageModel *model = [[SystemMessageModel alloc]init];
    model = self.dataArray[indexPath.section];
    cell.systemMessageModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SystemMessageModel *model = [[SystemMessageModel alloc]init];
    model = self.dataArray[indexPath.section];
    
    NSLog(@"%@" , @(model.idd.integerValue));
    
    if ([self.navigationItem.title isEqualToString:NSLocalizedString(@"System Information", nil)]) {
        SystemMessageWebViewController *systemWebVC = [[SystemMessageWebViewController alloc]init];
        systemWebVC.model = model;
        
        systemWebVC.navigationItem.title = self.navigationItem.title;
        [self.navigationController pushViewController:systemWebVC animated:YES];
    } else {
        MineMessageVC *mineMessageVC = [[MineMessageVC alloc]init];
        mineMessageVC.model = model;
        mineMessageVC.navigationItem.title = self.navigationItem.title;
        [self.navigationController pushViewController:mineMessageVC animated:YES];
        
        SystemMessageAndMineMessageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary *parames = @{@"id":model.idd};
        [kNetWork requestPOSTUrlString:kUserWhtherReadMessageURL parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
            cell.promptView.hidden = YES;
//            [self.tableView reloadData];
        } failure:^(NSError * _Nonnull error) {
            [kNetWork noNetWork];
        }];
        
    }
    
}


@end
