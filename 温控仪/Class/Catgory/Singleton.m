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
    _socketHost = socketHost;
}

- (void)setSocketPort:(UInt16)socketPort {
    _socketPort = socketPort;
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
   
}

// socket连接
-(void)socketConnectHostWith:(NSString *)host port:(NSInteger)port{
    
    [self cutOffSocket];
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    self.isDuanXianChongLian = @"YES";
    [self.socket connectToHost:host onPort:port withTimeout:-1 error:&error];
    self.socketHost = host;
    self.socketPort = port;
    
}

// 连接成功回调
#pragma mark  - 连接成功回调
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"%@" , host);
    
//    [self sendDataToHost:nil andType:kLianJie];
    
    [_duanXianChongLian invalidate];
    _duanXianChongLian = nil;
    [_socket readDataWithTimeout:-1 tag:0];
}

// 心跳连接
-(void)longConnectToSocket{
    
    [self sendDataToHost:nil andType:kXinTiao];
    
}
// 切断socket
-(void)cutOffSocket{
    
    [self.duanXianChongLian invalidate];
    self.duanXianChongLian = nil;
    
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
        
    }
    
}

- (void)duanXianChongLianAtcion {
    _isDuanXianChongLian = @"YES";
    [self cutOffSocket];
    [self socketConnectHostWith:self.socketHost port:self.socketPort];
    
    [self sendDataToHost:nil andType:kAddService];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    if (data) {
        [_duanXianChongLian invalidate];
        _duanXianChongLian = nil;
        
        [SVProgressHUD dismiss];
        
        NSString *str = [NSString convertDataToHexStr:data];
        NSString *newMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
//        Byte devSnByte[str.length / 2];
//        NSMutableArray *devSnSubStr = [NSMutableArray array];
//        for (int i = 0; i < str.length / 2; i++) {
//            [devSnSubStr addObject: [str substringWithRange:NSMakeRange(i * 2, 2)]];
//            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
//        }
        
        if (![newMessage isEqualToString:@"QUIT"] && ![newMessage isEqualToString:@"CONNECTED"]) {
            
//            if (self.serviceModel.devSn &&[str hasPrefix:self.serviceModel.devSn]) {
//
//            }
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kServiceOrder object:self userInfo:[NSDictionary dictionaryWithObject:str forKey:@"Message"]]];
            
        } else if ([newMessage isEqualToString:@"QUIT"]){
            
            [self cutOffSocket];
            self.isDuanXianChongLian = @"NO";
           
            [[CZNetworkManager shareCZNetworkManager]removeAllObjectOfStanderDefault];
            
            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
            kWindowRoot = nav;
            
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:kWindowRoot Title:@"您的账号在其他设备登陆"];
            
        }
        else if ([newMessage isEqualToString:@"CONNECTED"]){
            [self sendDataToHost:nil andType:kLianJie];
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

- (void)sendDataToHost:(NSString *)string andType:(NSString *)type {
//    NSLog(@"%@ , %@ , %@" , string , type , isNewOrOld);
    
    Byte userSnByte[4];
    if (self.userSn) {
        NSString *userSn = self.userSn;
        for (int i = 0; i < 4; i++) {
            NSString *subStr = nil;
            if (i != 3) {
                subStr = [userSn substringToIndex:2];
                userSn = [userSn substringFromIndex:2];
            } else {
                subStr = userSn;
            }
            userSnByte[i] = strtoul([subStr UTF8String], 0, 16);
        }
    }
    
    Byte devSnByte[self.serviceModel.devSn.length / 2];
    NSInteger devSnLength = 0;
    if (self.serviceModel.devSn) {
        NSString *devSn = self.serviceModel.devSn;
        devSnLength = devSn.length / 2;
        for (int i = 0; i < devSn.length / 2; i++) {
            NSString *subStr = [devSn substringWithRange:NSMakeRange(2 * i, 2)];
            devSnByte[i] = strtoul([subStr UTF8String], 0, 16);
        }
    }
    
    NSData *data = nil;
    if ([type isEqualToString:kXinTiao]) {
        
        Byte xinTiaoBao[8];
        xinTiaoBao[0] = (Byte)'H';
        xinTiaoBao[1] = (Byte)'M';
        xinTiaoBao[2] = (Byte)userSnByte[0];
        xinTiaoBao[3] = (Byte)userSnByte[1];
        xinTiaoBao[4] = (Byte)userSnByte[2];
        xinTiaoBao[5] = (Byte)userSnByte[3];
        xinTiaoBao[6] = (Byte)'*';
        xinTiaoBao[7] = (Byte)'#';

        data = [NSData dataWithBytes:xinTiaoBao length:sizeof(xinTiaoBao)];
        
    } else if ([type isEqualToString:kZhiLing]) {
        
//        if (!self.whetherConnected) {
//            string = [NSString stringWithFormat:@"%@%@" , self.serviceModel.devSn , string];
//        }
        
        NSInteger length = string.length;
        NSString *zhiLingLong = string;
        Byte zhiLing[length / 2];
        
        for (int i = 0; i < length / 2; i++) {
            NSString *subStr = [zhiLingLong substringWithRange:NSMakeRange(2 * i, 2)];
            zhiLing[i] = strtoul([subStr UTF8String], 0, 16);
        }
        
        data = [NSData dataWithBytes:zhiLing length:sizeof(zhiLing)];
        
    } else if ([type isEqualToString:kLianJie]) {
        
        Byte connectByteAry[8];
        connectByteAry[0] = (Byte)'H';
        connectByteAry[1] = (Byte)'M';
        
        for (int i = 2; i < 6; i++) {
            connectByteAry[i] = (Byte)userSnByte[i - 2];
        }
        
        connectByteAry[6] = (Byte)'N';
        connectByteAry[7] = (Byte)'#';
        
        data = [NSData dataWithBytes:connectByteAry length:sizeof(connectByteAry)];
        
        [self sendDataToHost:nil andType:kXinTiao];
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
        
    } else if ([type isEqualToString:kAddService]) {
        
        NSInteger count = 8 + devSnLength;
        Byte addServiceBao[count];
        addServiceBao[0] = (Byte)'H';
        addServiceBao[1] = (Byte)'M';
        
        for (int i = 2; i < 6; i++) {
            addServiceBao[i] = (Byte)userSnByte[i - 2];
        }
        
        for (int i = 6; i < 6 + devSnLength; i++) {
            addServiceBao[i] = (Byte)devSnByte[i - 6];
        }
        
        addServiceBao[count - 2] = (Byte)'N';
        addServiceBao[count - 1] = (Byte)'#';
        
        data = [NSData dataWithBytes:addServiceBao length:sizeof(addServiceBao)];
        NSLog(@"设备连接成功");
    } else if ([type isEqualToString:kQuite]) {
        
        NSInteger count = 8 + devSnLength;
        Byte quiteByteAry[count];
        quiteByteAry[0] = (Byte)'H';
        quiteByteAry[1] = (Byte)'M';
        
        for (int i = 2; i < 6; i++) {
            quiteByteAry[i] = (Byte)userSnByte[i - 2];
        }
        
        for (int i = 6; i < 6 + devSnLength; i++) {
            quiteByteAry[i] = (Byte)devSnByte[i - 6];
        }
        
        quiteByteAry[count - 2] = (Byte)'Q';
        quiteByteAry[count - 1] = (Byte)'#';
        
        data = [NSData dataWithBytes:quiteByteAry length:sizeof(quiteByteAry)];
        
    } else if (type == nil) {
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [self.socket writeData:data withTimeout:-1 tag:0];
}
@end
