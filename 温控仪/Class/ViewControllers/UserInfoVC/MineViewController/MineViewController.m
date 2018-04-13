//
//  MineViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/12.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "MineViewController.h"
#import "HeadPortraitView.h"
#import "MineTableViewCell.h"
#import "UserFeedBackViewController.h"
#import "UserMessageViewController.h"

#import "SumMessageViewController.h"
#import "SystemMessageModel.h"

#import "AboutOusTableViewController.h"

#import "MineYouHuiQuanViewController.h"
#import "MineSerivesViewController.h"
#import "AboutProductViewController.h"
#import "SetServicesViewController.h"

@interface MineViewController ()<UITableViewDataSource , UITableViewDelegate>
@property (nonatomic , copy) NSString *systemMessageIsShowPrompt;
@property (nonatomic , strong) UITableView *tableVIew;
@property (nonatomic , strong) UILabel *nameLable;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) UIImage *headImage;
@property (nonatomic , strong) UIImageView *headImageView;
@property (nonatomic , strong) UIImageView *headBackImageView;

@property (nonatomic , strong) HeadPortraitView *headPortraitView;

@property (nonatomic , strong) NSIndexPath *selectedIndexPath;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setNotifi];
    
    [self setNav];
    
    [self setUI];
    
    [self setData];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar
    .titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0f3649"]};
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar
    .titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"20c3df"]};
}

- (void)setNotifi {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHeadImage:) name:@"headImage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNiCheng:) name:@"niCheng" object:nil];
}

- (void)setData {
    
    NSDictionary *userParames = @{@"userSn" : [kStanderDefault objectForKey:@"userSn"]};
    [kNetWork requestPOSTUrlString:kGetUserDataURL parameters:userParames isSuccess:^(NSDictionary * _Nullable responseObject) {
        [self setUserData:responseObject];
    } failure:^(NSError * _Nonnull error) {
        NSDictionary *userData = [kPlistTools readDataFromFile:UserData];
        [self setUserData:userData];
    }];
    
    NSDictionary *parames = @{@"page" : @(1) , @"rows" : @10};
    
    [kNetWork requestPOSTUrlString:kSystemMessageJieKou parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        if ([responseObject[@"total"] isKindOfClass:[NSNull class]]) {
            return ;
        }
        
        NSInteger total = [responseObject[@"total"] integerValue];
        if (total > 0) {
            
            NSArray *data = responseObject[@"rows"];
            
            if (data.count > 0) {
                NSMutableArray *dataArray = [NSMutableArray array];
                [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SystemMessageModel *model = [[SystemMessageModel alloc]init];
                    [model yy_modelSetWithDictionary:obj];
                    [dataArray addObject:model];
                }];
                
                SystemMessageModel *model = [[SystemMessageModel alloc]init];
                model = [dataArray firstObject];
                
                
                if (![[kStanderDefault objectForKey:@"SystemMessageTime"] isKindOfClass:[NSNull class]]) {
                    NSString *messageTime = [kStanderDefault objectForKey:@"SystemMessageTime"];
                    if ([messageTime compare:model.addTime]) {
                        self.systemMessageIsShowPrompt = @"YES";
                    } else {
                        self.systemMessageIsShowPrompt = @"NO";
                    }
                } else {
                    self.systemMessageIsShowPrompt = @"YES";
                }
            }
        }
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableVIew reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
    }];
}

- (void)setUserData:(NSDictionary *)dic {
    
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        _userModel = [[UserModel alloc]init];
        [_userModel yy_modelSetWithDictionary:user];
        
        _headPortraitView.userModel = self.userModel;
    }
}

- (void)setNav {
    self.navigationItem.title = NSLocalizedString(@"Personal Certer", nil);
}

#pragma mark - 设置UI界面
- (void)setUI{
    
    _headPortraitView = [[HeadPortraitView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH / 3.7) Target:self action:@selector(mineAtcion)];
    [self.view addSubview:_headPortraitView];
    self.headBackImageView = _headPortraitView.subviews[0];
    self.headImageView = _headPortraitView.subviews[2];
    self.nameLable = [_headPortraitView.subviews objectAtIndex:3];
    
    self.tableVIew = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenH / 3.7 + 0, kScreenW, 7 * kScreenH / 14.2 + 2) style:UITableViewStylePlain];
    [self.view addSubview:self.tableVIew];
    self.tableVIew.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    self.tableVIew.scrollEnabled = NO;
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (MineTableViewCell *)tableViewindexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:section];
    MineTableViewCell *cell = (MineTableViewCell *)[self.tableVIew cellForRowAtIndexPath:indexpath];
    return cell;
}

#pragma mark - 获取头像
- (void)getHeadImage:(NSNotification *)post {
    
    if (post.userInfo[@"headImage"]) {

        self.headImageView.image = post.userInfo[@"headImage"];
        _headBackImageView.image = _headBackImageView.image = [UIImage boxblurImage:post.userInfo[@"headImage"] withBlurNumber:.3];
    }
    
    
}

- (void)getNiCheng:(NSNotification *)post {

    if ([post.userInfo[@"niCheng"] length] != 0) {
        self.nameLable.text = post.userInfo[@"niCheng"];
    }
}


#pragma mark - 头像点击事件
- (void)mineAtcion {
    UserMessageViewController *userVC = [[UserMessageViewController alloc]init];

    userVC.userModel = self.userModel;
    userVC.headImage = self.headImageView.image;
    userVC.navigationItem.title = NSLocalizedString(@"User Info", nil);
    [self.navigationController pushViewController:userVC animated:YES];
//    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - TableView的点击事件
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"id";
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[MineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId
                ];
    }
    
    cell.indexpath = indexPath;
    cell.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MineTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    self.selectedIndexPath = indexPath;
    return YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath) {
        MineTableViewCell *cell = [self.tableVIew cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selectedImage.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
//    self.tabBarController.tabBar.hidden = YES;
    if (indexPath.row == 0 && indexPath.section == 0) {
        
        [self mineAtcion];
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        
        SumMessageViewController *sumMessageVC = [[SumMessageViewController alloc]init];
        sumMessageVC.systemMessageIsShowPrompt = self.systemMessageIsShowPrompt;
        sumMessageVC.navigationItem.title = NSLocalizedString(@"Message Notification", nil);
        sumMessageVC.userModel = self.userModel;
        [self.navigationController pushViewController:sumMessageVC animated:YES];
        
        self.systemMessageIsShowPrompt = @"NO";
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } else if (indexPath.row == 0 && indexPath.section == 1) {
        AboutProductViewController *aboutVC = [[AboutProductViewController alloc]init];
        aboutVC.model = [[UserModel alloc]init];
        aboutVC.model = self.userModel;
        aboutVC.navigationItem.title = NSLocalizedString(@"About Products", nil);
        [self.navigationController pushViewController:aboutVC animated:YES];
    } else if (indexPath.row == 1 && indexPath.section == 1) {
        AboutOusTableViewController *aboutOusVC = [[AboutOusTableViewController alloc]init];
        aboutOusVC.navigationItem.title = NSLocalizedString(@"About Us", nil);
        [self.navigationController pushViewController:aboutOusVC animated:YES];
    } else  {
//        self.tabBarController.tabBar.hidden = NO;
        MineTableViewCell *cell = [_tableVIew cellForRowAtIndexPath:indexPath];
        
        [UIAlertController creatCancleAndRightAlertControllerWithHandle:^{
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                cell.clearLabel.text = [NSString stringWithFormat:@"%@ : %@" , NSLocalizedString(@"Current Cache", nil) ,  [cell getBufferSize]];
            }];
            
            [self cleanCacheAndCookie];
            
        } andSuperViewController:self Title:NSLocalizedString(@"Clear Cache", nil)];
        
        
        
    }
  
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    for (NSString *p in files) {
        NSError *error;
        NSString *Path = [path stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
            //清理缓存，保留Preference，里面含有NSUserDefaults保存的信息
            if (![Path containsString:@"Preferences"]) {
                [[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = [UIColor clearColor];
}

//弹出列表方法presentSnsIconSheetView需要设置delegate为self
-(BOOL)isDirectShareInIconActionSheet
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenH / 14.46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kScreenW / 27;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
