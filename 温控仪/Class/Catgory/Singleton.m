//
//  Singleton.m
//  socket_tutorial
//
//  Created by xiaoliangwang on 14-7-4.
//  Copyright (c) 2014年 芳仔小脚印. All rights reserved.
//

#import "Singleton.h"
#import "LoginViewController.h"
#import "XMGNavigationController.h"
#import <sys/socket.h>

#import <netinet/in.h>

#import <arpa/inet.h>

#import <unistd.h>


#define kStanderDefault [NSUserDefaults standardUserDefaults]

#define kLocalHost @"192.168.1.110"

#define ksPort 8899

@interface Singleton ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong) NSTimer *duanXianChongLian;

//心跳
@property (nonatomic, retain) NSTimer *connectTimer;
@property (nonatomic , strong) UIAlertController *alertController;

@end

@implementation Singleton

+(Singleton *) sharedInstance
{
    
    static Singleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
        
    });
    
    return sharedInstace;
}

- (void)setSocketHost:(NSString *)socketHost {
    _socketHost = kLocalHost;
    
}

- (void)setSocketPort:(UInt16)socketPort {
    _socketPort = ksPort;
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

// socket连接
-(void)socketConnectHost{
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    self.isDuanXianChongLian = @"YES";
    [self.socket connectToHost:kLocalHost onPort:ksPort withTimeout:-1 error:&error];
    
}

- (void)connectHost {
    
    NSError *error = nil;
    [self.socket connectToHost:kLocalHost onPort:ksPort withTimeout:-1 error:&error];
}

// 连接成功回调
#pragma mark  - 连接成功回调
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"%@" , host);
    [_duanXianChongLian invalidate];
    _duanXianChongLian = nil;
    [_socket readDataWithTimeout:-1 tag:0];
}

// 心跳连接
-(void)longConnectToSocket{
    
    [self sendDataToHost:[NSString stringWithFormat:@"HM%@*#",  self.userSn] andType:kXinTiao andIsNewOrOld:kOld];
    
}
// 切断socket
-(void)cutOffSocket{
    
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    [_socket disconnect];
    _socket = nil;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"SSSSSSSSDDDDDDD");
    [self.connectTimer invalidate];
    
    
    
    if ([self.isDuanXianChongLian isEqualToString:@"YES"] && (self.userSn != nil || ![self.userSn isKindOfClass:[NSNull class]])) {
        [_duanXianChongLian invalidate];
        _duanXianChongLian = nil;
        _duanXianChongLian = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(duanXianChongLianAtcion) userInfo:nil repeats:YES];
        NSString *message = @"网络连接异常，请稍等。";
        
        if (!_alertController) {
            
            _alertController = [UIAlertController creatRightAlertControllerWithHandle:^{
                
                [_alertController dismissViewControllerAnimated:YES completion:^{
                    _alertController = nil;
                }];
                
            } andSuperViewController:kWindowRoot Title:message];
        } else if (_alertController) {
            
            if (![_alertController.message isEqualToString:message]) {
                _alertController.message = message;
            }
        }
    }
    
}

- (void)duanXianChongLianAtcion {
    _isDuanXianChongLian = @"YES";
    [self cutOffSocket];
    [self socketConnectHost];
    
    if (self.userSn && self.serviceModel) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendDataToHost:[NSString stringWithFormat:@"HM%@%@%@N#" , self.userSn , self.serviceModel.devTypeSn , self.serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
        });
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    
    if (data.length < 50 && data) {
        [_duanXianChongLian invalidate];
        _duanXianChongLian = nil;
        
        if (_alertController) {
            [_alertController dismissViewControllerAnimated:YES completion:nil];
            _alertController = nil;
        }
        
        NSString *str = [NSString convertDataToHexStr:data];
        NSString *newMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        Byte devSnByte[60];
        NSMutableArray *devSnSubStr = [NSMutableArray array];
        for (int i = 0; i < str.length / 2; i++) {
            [devSnSubStr addObject: [str substringWithRange:NSMakeRange(i * 2, 2)]];
            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
        }
        
        //    NSLog(@"%@ , %@" , sock.connectedHost , newMessage);
        
        if (![newMessage isEqualToString:@"QUIT"] && ![newMessage isEqualToString:@"CONNECTED"]) {
            
            NSString *typeSn = nil;
            if (str.length == 56 || str.length == 42) {
                typeSn = [NSString stringWithFormat:@"%x%x" , devSnByte[4] , devSnByte[5]];
            } else {
                typeSn = [NSString stringWithFormat:@"%x%x" , devSnByte[5] , devSnByte[6]];
            }
            
            //        NSLog(@"%@ , %@ , %@ , %@" , sock.connectedHost , newMessage , str , typeSn);
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kServiceOrder object:self userInfo:[NSDictionary dictionaryWithObject:str forKey:@"Message"]]];
            
        } else if ([newMessage isEqualToString:@"QUIT"]){
            
            //        [self sendDataToHost:@"QUIT" andType:nil andIsNewOrOld:kOld];
            [self cutOffSocket];
            self.isDuanXianChongLian = @"NO";
            [kStanderDefault removeObjectForKey:@"Login"];
            [kStanderDefault removeObjectForKey:@"cityName"];
            [kStanderDefault removeObjectForKey:@"password"];
            [kStanderDefault removeObjectForKey:@"phone"];
            [kStanderDefault removeObjectForKey:@"userSn"];
            [kStanderDefault removeObjectForKey:@"userId"];
            [kStanderDefault removeObjectForKey:@"zhuYe"];
            
            [kStanderDefault removeObjectForKey:@"offBtn"];
            [kStanderDefault removeObjectForKey:@"GanYiJiData"];
            [kStanderDefault removeObjectForKey:@"ganYiJiHongGanDic"];
            [kStanderDefault removeObjectForKey:@"GanYiJiIsWork"];
            [kStanderDefault removeObjectForKey:@"AirData"];
            [kStanderDefault removeObjectForKey:@"AirDingShiData"];
            [kStanderDefault removeObjectForKey:@"kongZhiTai"];
            [kStanderDefault removeObjectForKey:@"data"];
            [kStanderDefault removeObjectForKey:@"wearthDic"];
            [kStanderDefault removeObjectForKey:@"requestWeatherTime"];
            [kStanderDefault removeObjectForKey:@"GeRenInfo"];
            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
            kWindowRoot = nav;
            
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:kWindowRoot Title:@"您的账号在其他设备登陆"];
            
        } else if ([newMessage isEqualToString:@"CONNECTED"]){
            
            if (newMessage.length == 126) {
                
            } else {
                [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%@N#" , self.userSn] andType:kLianJie andIsNewOrOld:kOld];
            }
        }
        
        
    }
    
    [_socket readDataWithTimeout:-1 tag:0];
    
}


- (void)setUserSn:(NSString *)userSn {
    _userSn = userSn;
    
}

- (void)enableBackgroundingOnSocket {
    [self.socket enableBackgroundingOnSocket];
}


- (void)sendDataToHost:(NSString *)string andType:(NSString *)type andIsNewOrOld:(NSString *)isNewOrOld{
    //    NSLog(@"%@ , %@ , %@" , string , type , isNewOrOld);
    
    if ([type isEqualToString:kXinTiao]) {
        
        NSInteger userSn = [string substringWithRange:NSMakeRange(2, 9)].integerValue;
        
        NSString *hexUserSn = [NSString toHex:userSn];
        
        if (hexUserSn.length / 2 != 0) {
            hexUserSn = [NSString stringWithFormat:@"0%@" , hexUserSn];
        }
        
        Byte userSnByte[4];
        
        NSMutableArray *userSnSubStr = [NSMutableArray array];
        for (int i = 0; i < hexUserSn.length / 2; i++) {
            [userSnSubStr addObject:[hexUserSn substringWithRange:NSMakeRange(2 * i, 2)]];
            userSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
        }
        
        Byte xinTiaoBao[8];
        xinTiaoBao[0] = (Byte)'H';
        xinTiaoBao[1] = (Byte)'M';
        xinTiaoBao[2] = (Byte)userSnByte[0];
        xinTiaoBao[3] = (Byte)userSnByte[1];
        xinTiaoBao[4] = (Byte)userSnByte[2];
        xinTiaoBao[5] = (Byte)userSnByte[3];
        xinTiaoBao[6] = (Byte)'*';
        xinTiaoBao[7] = (Byte)'#';

        NSData *data = [NSData dataWithBytes:xinTiaoBao length:sizeof(xinTiaoBao)];
        [self.socket writeData:data withTimeout:-1 tag:0];
        
    } else if ([type isEqualToString:kZhiLing]) {
        
        NSInteger length = string.length;
        
//        NSString *typeSn = [string substringWithRange:NSMakeRange(5, 4)];
//        NSString *devSn = [string substringWithRange:NSMakeRange(9, 12)];
        NSString *zhiLingLong = string;
        
//        Byte typeSnByte[2];
//        Byte devSnByte[6];
        Byte zhiLing[length / 2];
        
        
//        NSMutableArray *typeSnSubStr = [NSMutableArray array];
//        for (int i = 0; i < typeSn.length / 2; i++) {
//            [typeSnSubStr addObject:[typeSn substringWithRange:NSMakeRange(i * 2, 2)]];
//            typeSnByte[i] = strtoul([typeSnSubStr[i] UTF8String], 0, 16);
//        }
//
//        NSMutableArray *devSnSubStr = [NSMutableArray array];
//        for (int i = 0; i < devSn.length / 2; i++) {
//            [devSnSubStr addObject: [devSn substringWithRange:NSMakeRange(i * 2, 2)]];
//
//            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
//        }
        
        NSMutableArray *zhiLingSubAry = [NSMutableArray array];
        for (int i = 0; i < zhiLingLong.length / 2; i++) {
            [zhiLingSubAry addObject:[zhiLingLong substringWithRange:NSMakeRange(i * 2, 2)]];
            zhiLing[i] = strtoul([zhiLingSubAry[i] UTF8String], 0, 16);
        }
        
//        Byte xinTiaoBao[length / 2];
//        xinTiaoBao[0] = (Byte)'H';
//        xinTiaoBao[1] = (Byte)'M';
//        xinTiaoBao[2] = (Byte)'F';
//        xinTiaoBao[3] = (Byte)'F';
//        xinTiaoBao[4] = (Byte)'M';
//        xinTiaoBao[5] = (Byte)typeSnByte[0];
//        xinTiaoBao[6] = (Byte)typeSnByte[1];
//        xinTiaoBao[7] = (Byte)devSnByte[0];
//        xinTiaoBao[8] = (Byte)devSnByte[1];
//        xinTiaoBao[9] = (Byte)devSnByte[2];
//        xinTiaoBao[10] = (Byte)devSnByte[3];
//        xinTiaoBao[11] = (Byte)devSnByte[4];
//        xinTiaoBao[12] = (Byte)devSnByte[5];
//        xinTiaoBao[13] = (Byte)'w';
//
//        for (int i = 14; i< 14 + length / 2; i++) {
//            xinTiaoBao[i] = (Byte)zhiLing[i - 14];
//        }
//
//        xinTiaoBao[14 + length / 2] = (Byte)'#';
//        for (int i = 0; i < sizeof(zhiLing); i++) {
//            NSLog(@"%x" , zhiLing[i]);
//        }
        
        NSData *data = [NSData dataWithBytes:zhiLing length:sizeof(zhiLing)];
        [self.socket writeData:data withTimeout:-1 tag:0];
    } else if ([type isEqualToString:kLianJie]) {
        NSInteger userSn = [string substringWithRange:NSMakeRange(2, 9)].integerValue;
        
        NSString *hexUserSn = [NSString toHex:userSn];
        
        if (hexUserSn.length / 2 != 0) {
            hexUserSn = [NSString stringWithFormat:@"0%@" , hexUserSn];
        }
        Byte userSnByte[4];
        
        NSMutableArray *userSnSubStr = [NSMutableArray array];
        for (int i = 0; i < hexUserSn.length / 2; i++) {
            [userSnSubStr addObject:[hexUserSn substringWithRange:NSMakeRange(2 * i, 2)]];
            userSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
        }
        
        Byte xinTiaoBao[8];
        xinTiaoBao[0] = (Byte)'H';
        xinTiaoBao[1] = (Byte)'M';
        xinTiaoBao[2] = (Byte)userSnByte[0];
        xinTiaoBao[3] = (Byte)userSnByte[1];
        xinTiaoBao[4] = (Byte)userSnByte[2];
        xinTiaoBao[5] = (Byte)userSnByte[3];
        xinTiaoBao[6] = (Byte)'N';
        xinTiaoBao[7] = (Byte)'#';
        
        //        for (int i = 0; i < sizeof(xinTiaoBao); i++) {
        //            NSLog(@"%x" , xinTiaoBao[i]);
        //        }
        
        NSData *data = [NSData dataWithBytes:xinTiaoBao length:sizeof(xinTiaoBao)];
        [self.socket writeData:data withTimeout:-1 tag:0];
        
        [self sendDataToHost:[NSString stringWithFormat:@"HM%@*#",  self.userSn] andType:kXinTiao andIsNewOrOld:kOld];
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
        
    } else if ([type isEqualToString:kAddService]) {
        
        NSInteger userSn = [string substringWithRange:NSMakeRange(2, 9)].integerValue;
        NSString *typeSn = [string substringWithRange:NSMakeRange(11, 4)];
        NSString *devSn = [string substringWithRange:NSMakeRange(15, 12)];
        
        //        NSLog(@"%ld , %@ , %@" , userSn , typeSn, devSn);
        
        Byte userSnByte[4];
        Byte typeSnByte[2];
        Byte devSnByte[6];
        
        
        NSString *hexUserSn = [NSString toHex:userSn];
        if (hexUserSn.length / 2 != 0) {
            hexUserSn = [NSString stringWithFormat:@"0%@" , hexUserSn];
        }
        NSMutableArray *userSnSubStr = [NSMutableArray array];
        for (int i = 0; i < hexUserSn.length / 2; i++) {
            [userSnSubStr addObject:[hexUserSn substringWithRange:NSMakeRange(2 * i, 2)]];
            userSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
        }
        
        NSMutableArray *typeSnSubStr = [NSMutableArray array];
        for (int i = 0; i < typeSn.length / 2; i++) {
            [typeSnSubStr addObject:[typeSn substringWithRange:NSMakeRange(i * 2, 2)]];
            typeSnByte[i] = strtoul([typeSnSubStr[i] UTF8String], 0, 16);
        }
        
        
        NSMutableArray *devSnSubStr = [NSMutableArray array];
        for (int i = 0; i < devSn.length / 2; i++) {
            [devSnSubStr addObject: [devSn substringWithRange:NSMakeRange(i * 2, 2)]];
            
            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
        }
        
        
        Byte addServiceBao[16];
        addServiceBao[0] = (Byte)'H';
        addServiceBao[1] = (Byte)'M';
        addServiceBao[2] = (Byte)userSnByte[0];
        addServiceBao[3] = (Byte)userSnByte[1];
        addServiceBao[4] = (Byte)userSnByte[2];
        addServiceBao[5] = (Byte)userSnByte[3];
        
        addServiceBao[6] = (Byte)typeSnByte[0];
        addServiceBao[7] = (Byte)typeSnByte[1];
        
        addServiceBao[8] = (Byte)devSnByte[0];
        addServiceBao[9] = (Byte)devSnByte[1];
        addServiceBao[10] = (Byte)devSnByte[2];
        addServiceBao[11] = (Byte)devSnByte[3];
        addServiceBao[12] = (Byte)devSnByte[4];
        addServiceBao[13] = (Byte)devSnByte[5];
        addServiceBao[14] = (Byte)'N';
        addServiceBao[15] = (Byte)'#';
        
        //        for (int i = 0; i < sizeof(addServiceBao); i++) {
        //            NSLog(@"%x" , addServiceBao[i]);
        //        }
        
        
        NSData *data = [NSData dataWithBytes:addServiceBao length:sizeof(addServiceBao)];
        [self.socket writeData:data withTimeout:-1 tag:0];
        NSLog(@"设备连接成功");
    } else if ([type isEqualToString:kQuite]) {
        
        NSInteger userSn = [string substringWithRange:NSMakeRange(2, 9)].integerValue;
        NSString *typeSn = [string substringWithRange:NSMakeRange(11, 4)];
        NSString *devSn = [string substringWithRange:NSMakeRange(15, 12)];
        
        //        NSLog(@"%ld , %@ , %@" , userSn , typeSn, devSn);
        
        Byte userSnByte[4];
        Byte typeSnByte[2];
        Byte devSnByte[6];
        
        
        NSString *hexUserSn = [NSString toHex:userSn];
        if (hexUserSn.length / 2 != 0) {
            hexUserSn = [NSString stringWithFormat:@"0%@" , hexUserSn];
        }
        NSMutableArray *userSnSubStr = [NSMutableArray array];
        for (int i = 0; i < hexUserSn.length / 2; i++) {
            [userSnSubStr addObject:[hexUserSn substringWithRange:NSMakeRange(2 * i, 2)]];
            userSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
        }
        
        NSMutableArray *typeSnSubStr = [NSMutableArray array];
        for (int i = 0; i < typeSn.length / 2; i++) {
            [typeSnSubStr addObject:[typeSn substringWithRange:NSMakeRange(i * 2, 2)]];
            typeSnByte[i] = strtoul([typeSnSubStr[i] UTF8String], 0, 16);
        }
        
        
        NSMutableArray *devSnSubStr = [NSMutableArray array];
        for (int i = 0; i < devSn.length / 2; i++) {
            [devSnSubStr addObject: [devSn substringWithRange:NSMakeRange(i * 2, 2)]];
            
            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
        }
        
        
        Byte addServiceBao[16];
        addServiceBao[0] = (Byte)'H';
        addServiceBao[1] = (Byte)'M';
        addServiceBao[2] = (Byte)userSnByte[0];
        addServiceBao[3] = (Byte)userSnByte[1];
        addServiceBao[4] = (Byte)userSnByte[2];
        addServiceBao[5] = (Byte)userSnByte[3];
        
        addServiceBao[6] = (Byte)typeSnByte[0];
        addServiceBao[7] = (Byte)typeSnByte[1];
        
        addServiceBao[8] = (Byte)devSnByte[0];
        addServiceBao[9] = (Byte)devSnByte[1];
        addServiceBao[10] = (Byte)devSnByte[2];
        addServiceBao[11] = (Byte)devSnByte[3];
        addServiceBao[12] = (Byte)devSnByte[4];
        addServiceBao[13] = (Byte)devSnByte[5];
        addServiceBao[14] = (Byte)'Q';
        addServiceBao[15] = (Byte)'#';
        
        //        for (int i = 0; i < sizeof(addServiceBao); i++) {
        //            NSLog(@"%x" , addServiceBao[i]);
        //        }
        
        NSData *data = [NSData dataWithBytes:addServiceBao length:sizeof(addServiceBao)];
        [self.socket writeData:data withTimeout:-1 tag:0];
        
    } else if (type == nil) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:-1 tag:0];
    }
    
}



@end
