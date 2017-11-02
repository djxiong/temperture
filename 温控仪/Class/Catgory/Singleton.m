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
        
    }
    
}

- (void)duanXianChongLianAtcion {
    _isDuanXianChongLian = @"YES";
    [self cutOffSocket];
    [self socketConnectHostWith:self.socketHost port:self.socketPort];
    
    if (self.userSn && self.serviceModel) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendDataToHost:[NSString stringWithFormat:@"HM%@%@N#" , self.userSn , self.serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
        });
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (data) {
        [_duanXianChongLian invalidate];
        _duanXianChongLian = nil;
        
        [SVProgressHUD dismiss];
        
        NSString *str = [NSString convertDataToHexStr:data];
        NSString *newMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        Byte devSnByte[str.length / 2];
        NSMutableArray *devSnSubStr = [NSMutableArray array];
        for (int i = 0; i < str.length / 2; i++) {
            [devSnSubStr addObject: [str substringWithRange:NSMakeRange(i * 2, 2)]];
            devSnByte[i] = strtoul([devSnSubStr[i] UTF8String],0,16);
        }
        
        if (![newMessage isEqualToString:@"QUIT"] && ![newMessage isEqualToString:@"CONNECTED"]) {
            
            str = [str substringFromIndex:18];
            str = [str substringToIndex:str.length - 1];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kServiceOrder object:self userInfo:[NSDictionary dictionaryWithObject:str forKey:@"Message"]]];
            
        } else if ([newMessage isEqualToString:@"QUIT"]){
            
            [self cutOffSocket];
            self.isDuanXianChongLian = @"NO";
           
            [[CZNetworkManager shareCZNetworkManager]removeAllObjectOfStanderDefault];
            
            XMGNavigationController *nav = [[XMGNavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
            kWindowRoot = nav;
            
            [UIAlertController creatRightAlertControllerWithHandle:nil andSuperViewController:kWindowRoot Title:@"您的账号在其他设备登陆"];
            
        } else if ([newMessage isEqualToString:@"CONNECTED"]){
            [self sendDataToHost:[NSString stringWithFormat:@"HM%@N#" , self.userSn] andType:kLianJie andIsNewOrOld:kOld];
        }
    }
    
    [_socket readDataWithTimeout:-1 tag:0];
    
}


- (void)setUserSn:(NSString *)userSn {
    
    _userSn = [NSString toHex:[userSn integerValue]];
}

- (void)enableBackgroundingOnSocket {
    [self.socket enableBackgroundingOnSocket];
}

- (void)sendDataToHost:(NSString *)string andType:(NSString *)type andIsNewOrOld:(NSString *)isNewOrOld{
    //    NSLog(@"%@ , %@ , %@" , string , type , isNewOrOld);
    
    NSString *userSn = self.userSn;
    Byte userSnByte[userSn.length / 2];
    
    NSMutableArray *userSnSubStr = [NSMutableArray array];
    for (int i = 0; i < userSn.length / 2; i++) {
        [userSnSubStr addObject:[userSn substringWithRange:NSMakeRange(2 * i, 2)]];
        userSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
    }
    
    NSString *devSn = self.serviceModel.devSn;
    Byte devSnByte[devSn.length / 2];
    
    NSMutableArray *devSnSubStr = [NSMutableArray array];
    for (int i = 0; i < devSn.length / 2; i++) {
        [devSnSubStr addObject:[devSn substringWithRange:NSMakeRange(2 * i, 2)]];
        devSnByte[i] = strtoul([userSnSubStr[i] UTF8String], 0, 16);
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
        
        NSInteger length = string.length;
        NSString *zhiLingLong = string;
        Byte zhiLing[length / 2 + 1];
        
        NSMutableArray *zhiLingSubAry = [NSMutableArray array];
        for (int i = 0; i < length / 2; i++) {
            [zhiLingSubAry addObject:[zhiLingLong substringWithRange:NSMakeRange(i * 2, 2)]];
            zhiLing[i] = strtoul([zhiLingSubAry[i] UTF8String], 0, 16);
        }
        zhiLing[length / 2] = (Byte)'#';
        
        Byte orderByteAry[length / 2 + 13];
        orderByteAry[0] = (Byte)'H';
        orderByteAry[1] = (Byte)'M';
        orderByteAry[2] = (Byte)'F';
        orderByteAry[3] = (Byte)'F';
        orderByteAry[4] = (Byte)'A';
        for (int i = 5; i < 9; i++) {
            orderByteAry[i] = (Byte)devSnByte[i - 5];
        }
        
        orderByteAry[9] = (Byte)'w';
        for (int i = 10; i <= length / 2 + 10; i++) {
            orderByteAry[i] = (Byte)zhiLing[i - 10];
        }
        
        data = [NSData dataWithBytes:orderByteAry length:sizeof(orderByteAry)];
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
        
        [self sendDataToHost:[NSString stringWithFormat:@"HM%@*#",  self.userSn] andType:kXinTiao andIsNewOrOld:kOld];
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
        
    } else if ([type isEqualToString:kAddService]) {
        
        Byte addServiceBao[14];
        addServiceBao[0] = (Byte)'H';
        addServiceBao[1] = (Byte)'M';
        
        for (int i = 2; i < 6; i++) {
            addServiceBao[i] = (Byte)userSnByte[i - 2];
        }
        
        for (int i = 6; i < 10; i++) {
            addServiceBao[i] = (Byte)devSnByte[i - 6];
        }
        
        addServiceBao[10] = (Byte)'N';
        addServiceBao[11] = (Byte)'#';
        
        data = [NSData dataWithBytes:addServiceBao length:sizeof(addServiceBao)];
        NSLog(@"设备连接成功");
    } else if ([type isEqualToString:kQuite]) {
        
        Byte quiteByteAry[14];
        quiteByteAry[0] = (Byte)'H';
        quiteByteAry[1] = (Byte)'M';
        
        for (int i = 2; i < 6; i++) {
            quiteByteAry[i] = (Byte)userSnByte[i - 2];
        }
        
        for (int i = 6; i < 10; i++) {
            quiteByteAry[i] = (Byte)devSnByte[i - 6];
        }
        
        quiteByteAry[10] = (Byte)'Q';
        quiteByteAry[11] = (Byte)'#';
        
        data = [NSData dataWithBytes:quiteByteAry length:sizeof(quiteByteAry)];
        
    } else if (type == nil) {
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [self.socket writeData:data withTimeout:-1 tag:0];
}



@end
