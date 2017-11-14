//
//  searchServicesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "SearchServicesViewController.h"
#import "FailContextViewController.h"
#import "AsyncUdpSocket.h"
#import "MineSerivesViewController.h"
#import "LXGradientProcessView.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SearchServicesViewController ()<AsyncUdpSocketDelegate , HelpFunctionDelegate , UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , strong) AsyncUdpSocket *updSocket;

@property (strong, nonatomic) NSString *pwdStr;
@property (strong, nonatomic)  NSString *wifiNameStr;

@property (nonatomic , copy) NSString *devTypeSn;
@property (nonatomic , strong) UILabel *searchLable;
@property (nonatomic , strong) UILabel *registerLable;
@property (nonatomic , strong) UILabel *addLable;
@property (nonatomic , strong) UIButton *refreshBtn;

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) NSMutableArray *dataAry;

@property (nonatomic , copy) NSString *message;

@property (nonatomic , strong) NSTimer *repeatTimer;
@property (nonatomic , strong) UIAlertController *alertVC;
@end

@implementation SearchServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView.image = [UIImage imageNamed:@"addServiceBackImage"];
    
    [self openUDPServer];
    
    [self setUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sendMessage:@"FF00010102"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
    [SVProgressHUD dismiss];
    [self.updSocket close];
    self.updSocket = nil;
}

- (void)refreshAtcion {
    [self openUDPServer];
    [self sendMessage:@"FF00010102"];
}

#pragma mark - UDP
-(void)openUDPServer{
    
    [self.updSocket close];
    self.updSocket = nil;
    
    //初始化udp
    AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    self.updSocket = tempSocket;
    
    //绑定端口
    NSError *error = nil;
    [self.updSocket bindToPort:6004 error:&error];
    
    [self.updSocket enableBroadcast:YES error:nil];
    
//    [self.updSocket joinMulticastGroup:@"192.168.1.110" error:&error];
    
    //启动接收线程
    [self.updSocket receiveWithTimeout:-1 tag:0];
}

//连接建好后处理相应send Events
-(void)sendMessage:(NSString*)message
{
    NSLog(@"UDP发送数据--\n%@" , message);
    
    NSData *data = [NSString hexStringToData:message];
    //开始发送
    [self.updSocket sendData:data toHost:@"192.168.1.110"
                        port:49000
                 withTimeout:-1
                         tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    [self.updSocket close];
    self.updSocket = nil;
    self.searchLable.textColor = kMainColor;
    
    NSLog(@"%@" , data);
    
    NSString *str = [NSString convertDataToHexStr:data];
    
    if (str.length == 14) {
        if ([str isEqualToString:@"FF000382010187"] || [str isEqualToString:@"ff000382010187"]) {
            self.addLable.textColor = kMainColor;
            
            [self bindServiceRequest];
            return YES;
        } else {
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:self Title:@"密码输入错误，请重新输入"];
        }
    }
    
    [self calculateData:str];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.registerLable.textColor = kMainColor;
    });
    
    return YES;
}

#pragma mark - 解析TCP数据
- (void)calculateData:(NSString *)str {
    NSString *length = [NSString stringWithFormat:@"%.4lx" , (str.length - 6) / 2];
    NSString *headStr = [NSString stringWithFormat:@"ff%@81" , length];
    str = [str substringWithRange:NSMakeRange(headStr.length, str.length - headStr.length)];
    
    NSMutableArray *subAry = (NSMutableArray *)[str componentsSeparatedByString:@"0d0a"];
    NSString *firstObj = subAry[0];
    firstObj = [firstObj substringFromIndex:2];
    [subAry replaceObjectAtIndex:0 withObject:firstObj];
    
    [self.dataAry removeAllObjects];
    for (NSString *subStr in subAry) {
        NSArray *subAry2 = [subStr componentsSeparatedByString:@"00"];
        NSString *firObj = subAry2[0];
        firObj = [NSString stringFromHexString:firObj];
        
        if (firObj == nil || firObj == NULL) {
            continue;
        }
        
        [self.dataAry addObject:firObj];
        
    }
}

#pragma mark - 绑定设备的网络请求
- (void)bindServiceRequest {
    NSDictionary *parames = [NSMutableDictionary dictionary];
    [parames setValuesForKeysWithDictionary:@{@"ud.userSn" : [kStanderDefault objectForKey:@"userSn"] ,  @"ud.devSn" : self.serviceModel.devSn , @"ud.devTypeSn" : self.serviceModel.typeSn, @"phoneType":@(2) , @"ud.devTypeNumber":self.serviceModel.typeNumber}];
    
    if ([kStanderDefault objectForKey:@"cityName"] && [kStanderDefault objectForKey:@"provience"]) {
        NSString *city = [kStanderDefault objectForKey:@"cityName"];
        
        NSString *subStr = [city substringWithRange:NSMakeRange(city.length - 1, 1)];
        if (![subStr isEqualToString:@"市"]) {
            city = [NSString stringWithFormat:@"%@市" , city];
        }
        [parames setValuesForKeysWithDictionary:@{@"province" : [kStanderDefault objectForKey:@"provience"] , @"city" : city}];
    }
    
    
    self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(repeatRequestBindURL:) userInfo:parames repeats:YES];
}

- (void)repeatRequestBindURL:(NSTimer *)time {
    
    NSDictionary *parames = [time userInfo];
    
    [kNetWork requestPOSTUrlString:self.serviceModel.bindUrl parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        [self.repeatTimer invalidate];
        self.repeatTimer = nil;
        
        NSLog(@"%@" , responseObject);
        
        NSInteger state = [responseObject[@"state"] integerValue];
        if (state == 0 || state == 2) {
            [UIAlertController creatRightAlertControllerWithHandle:^{
                [self determineAndBindTheDevice];
            } andSuperViewController:self Title:@"此设备绑定成功"];
            
        } else if (state == 1){
            [self addServiceFail];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self addServiceFail];
    }];
}

#pragma mark - 绑定设备失败
- (void)addServiceFail {
    
    if (!self.alertVC) {
        self.alertVC = [UIAlertController creatRightAlertControllerWithHandle:^{
            
            FailContextViewController *failVC = [[FailContextViewController alloc]init];
            failVC.navigationItem.title = @"失败";
            failVC.serviceModel = self.serviceModel;
            [self.navigationController pushViewController:failVC animated:YES];
        } andSuperViewController:[[HelpFunction shareHelpFunction]getPresentedViewController] Title:@"此设备绑定失败"];
    }
}

#pragma mark - 判断并绑定设备
- (void)determineAndBindTheDevice {
    
    MineSerivesViewController *tabVC = [[MineSerivesViewController alloc]init];
    tabVC.fromAddVC = @"YES";
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:[tabVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
    [self.updSocket close];
}

#pragma mark - 设置UI
- (void)setUI {
    
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, kNavibarH, kScreenW, kScreenH / 2);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
    view.backgroundColor = [UIColor redColor];
    tableView.tableHeaderView = view;
    
    self.tableView = tableView;
    
    
    UIButton *refreshBtn = [UIButton creatBtnWithTitle:@"刷新WIFI列表" withLabelFont:k15 withLabelTextColor:[UIColor whiteColor] andSuperView:self.view andBackGroundColor:kMainColor andHighlightedBackGroundColor:[UIColor colorWithRed:250/255.0 green:201/255.0 blue:77/255.0 alpha:1.0] andwhtherNeendCornerRadius:NO WithTarget:self andDoneAtcion:@selector(refreshAtcion)];
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kStandardW, kScreenW / 10));
        make.centerX.mas_equalTo(tableView.mas_centerX);
        make.top.mas_equalTo(tableView.mas_bottom)
        .offset(kScreenW / 12.4);
    }];
    self.refreshBtn = refreshBtn;
    
    UILabel *searchLable = [UILabel creatLableWithTitle:@"正在搜索附近WIFI信息..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    searchLable.layer.borderWidth = 0;
    searchLable.textColor = kWhiteColor;
    [searchLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(refreshBtn.mas_bottom)
        .offset(kScreenW / 12.4);
    }];
    
    
    UILabel *registerLable = [UILabel creatLableWithTitle:@"正在连接设备..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    registerLable.layer.borderWidth = 0;
    registerLable.textColor = kWhiteColor;
    [registerLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(searchLable.mas_bottom);
    }];
    
    
    UILabel *addLable = [UILabel creatLableWithTitle:@"将设备添加到云端..." andSuperView:self.view andFont:k15 andTextAligment:NSTextAlignmentCenter];
    addLable.layer.borderWidth = 0;
    addLable.textColor = kWhiteColor;
    [addLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(registerLable.mas_bottom);
    }];
    self.searchLable = searchLable;
    self.registerLable = registerLable;
    self.addLable = addLable;
}

#pragma mark - UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *celled = @"celled";
    
    UITableViewCell *cell
    =[tableView dequeueReusableCellWithIdentifier:celled];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
    }
    
    NSString *text = self.dataAry[indexPath.row];
    
    cell.textLabel.text = text;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *name = cell.textLabel.text;
    self.wifiNameStr = name;
    [UIAlertController creatAlertControllerWithFirstTextfiledPlaceholder:nil andFirstTextfiledText:name andFirstAtcion:nil andWhetherEdite:NO WithSecondTextfiledPlaceholder:@"请输入WIFI密码" andSecondTextfiledText:nil andSecondAtcion:@selector(secondTextFieldsValueDidChange:) andAlertTitle:@"输入WiFi信息" andAlertMessage:@"输入 wifi 信息后，点击'好的',把当前WIFI信息发送给设备。" andTextfiledAtcionTarget:self andSureHandle:^{
        [self openUDPServer];
        [self sendMessage:self.message];
        self.refreshBtn.userInteractionEnabled = NO;
        self.refreshBtn.backgroundColor = [UIColor grayColor];
        [SVProgressHUD show];
    } andSuperViewController:self];
    
}

- (void)secondTextFieldsValueDidChange:(UITextField *)textFiled {
    self.pwdStr = textFiled.text;
}

#pragma mark - 懒加载
- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

- (NSString *)message {
    if (_message == nil) {
        //密码
        NSString *pwdHexStr = [NSString hexStringFromString:self.pwdStr];
        //账号
        NSString *wifiNameHexStr = [NSString hexStringFromString:self.wifiNameStr];
        NSString *wifiMessage = [NSString stringWithFormat:@"0200%@0D0A%@" , wifiNameHexStr , pwdHexStr];
        NSInteger messageLength = wifiMessage.length;
        
        NSString *mainMessage = [NSString stringWithFormat:@"00%2lX%@" , (long)messageLength / 2, wifiMessage];
        
        _message = [NSString stringWithFormat:@"FF%@%@" , mainMessage , [self hexStrSumStr:mainMessage]];
    }
    return _message;
}

- (NSString *)hexStrSumStr:(NSString *)hexStr {
    
    unsigned long sum = 0;
    for (int i = 0; i < hexStr.length / 2; i++) {
        NSString *subStr = [hexStr substringWithRange:NSMakeRange(i * 2, 2)];
        unsigned long num = strtoul([subStr UTF8String], 0, 16);
        sum += num;
    }
    
    NSString *sumStr = [NSString stringWithFormat:@"%lx" , sum];
    
    if (sum > 255) {
        return [sumStr substringWithRange:NSMakeRange(sumStr.length - 2, 2)];
    } else {
        return sumStr;
    }
}

- (NSMutableArray *)dataAry {
    if (!_dataAry) {
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}


@end
