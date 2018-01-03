//
//  searchServicesViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/26.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "SearchServicesViewController.h"
#import "FailContextViewController.h"

#import "GCDAsyncUdpSocket.h"

#import "MineSerivesViewController.h"
#import "LXGradientProcessView.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SearchServicesViewController ()<GCDAsyncUdpSocketDelegate ,  UITableViewDelegate , UITableViewDataSource>

@property (nonatomic , strong) GCDAsyncUdpSocket *sendUdpSocket;


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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
    [SVProgressHUD dismiss];
    [self.sendUdpSocket close];
    self.sendUdpSocket = nil;
}

- (void)refreshAtcion {
    [self openUDPServer];
}

#pragma mark - UDP
-(void)openUDPServer{
    [SVProgressHUD show];
    
    [self.sendUdpSocket close];
    self.sendUdpSocket = nil;
    
    //1.创建一个 udp socket用来和服务器端进行通讯
    GCDAsyncUdpSocket *sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    //2.banding一个端口(可选),如果不绑定端口, 那么就会随机产生一个随机的电脑唯一的端口
    //端口数字范围(1024,2^16-1)
    NSError * error = nil;
    [sendUdpSocket bindToPort:8085 error:&error];
    //启用广播
    [sendUdpSocket enableBroadcast:YES error:&error];
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        [sendUdpSocket beginReceiving:&error];
    }
    
    self.sendUdpSocket = sendUdpSocket;
    
    [self sendMessage:@"FF00010102"];
    
}

//连接建好后处理相应send Events
-(void)sendMessage:(NSString*)message
{
    NSLog(@"UDP发送数据--\n%@" , message);
    
    NSData *data = [NSString hexStringToData:message];
    [self.sendUdpSocket sendData:data toHost:KQILIANHost port:kQILIAN_UDP_Port withTimeout:-1 tag:0];
}

#pragma mark -GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    [SVProgressHUD dismiss];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchLable.textColor = kMainColor;
    });
    
    if (data == nil) {
        [UIAlertController creatRightAlertControllerWithHandle:^{
            [self.navigationController popViewControllerAnimated:YES];
        } andSuperViewController:self Title:@"配网失败请重试。"];
    }
    
    NSString *str = [NSString convertDataToHexStr:data];
    if (str.length == 14) {
        if ([str isEqualToString:@"FF000382010187"] || [str isEqualToString:@"ff000382010187"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.addLable.textColor = kMainColor;
            });
            [self determineAndBindTheDevice];
            return ;
        }
    }
    [self calculateData:str];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.registerLable.textColor = kMainColor;
    });
    
    [sock receiveOnce:nil];
    
    //    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    //    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    //    // 继续来等待接收下一次消息
    //    NSLog(@"收到服务端的响应 [%@:%d] %@", ip, port, data);
    //    //此处根据实际和硬件商定的需求决定是否主动回一条消息
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        NSString *msg = @"我收到了";
    //        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    //        [sock sendData:data toHost:ip port:port withTimeout:0.1 tag:200];
    //    });
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocket关闭");
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
        
        if (firObj == nil || firObj == NULL || [firObj isKindOfClass:[NSNull class]] || [firObj isEqualToString:@""]) {
            continue;
        }
        
        firObj = [NSString stringFromHexString:firObj];
        
        if (firObj == nil || firObj == NULL || [firObj isKindOfClass:[NSNull class]] || [firObj isEqualToString:@""]) {
            continue;
        }
        
        [self.dataAry addObject:firObj];
        
    }
}

#pragma mark - 判断并绑定设备
- (void)determineAndBindTheDevice {
    
    [UIAlertController creatRightAlertControllerWithHandle:^{
        MineSerivesViewController *tabVC = [[MineSerivesViewController alloc]init];
        tabVC.fromAddVC = @"YES";
        for (UIViewController *vc in self.navigationController.childViewControllers) {
            if ([vc isKindOfClass:[tabVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    } andSuperViewController:self Title:@"配网成功"];
    [self.sendUdpSocket close];
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

