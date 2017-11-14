//
//  HTMLBaseViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/12/1.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "HTMLBaseViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface HTMLBaseViewController ()<HelpFunctionDelegate , UIWebViewDelegate>

@property (nonatomic , strong) NSMutableDictionary *dic;

@property (nonatomic , strong) NSIndexPath *indexPath;

@property (nonatomic , strong) UIWebView *webView;
@property (nonatomic , strong) UIActivityIndicatorView *searchView;

@property (nonatomic , strong) JSContext *context;

@end

@implementation HTMLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    NSMutableDictionary *parames = [NSMutableDictionary dictionaryWithDictionary:@{@"loginName" : [kStanderDefault objectForKey:@"phone"] , @"password" : [kStanderDefault objectForKey:@"password"] , @"ua.phoneType" : @(2), @"ua.phoneBrand":@"iPhone" , @"ua.phoneModel":[NSString getDeviceName] , @"ua.phoneSystem":[NSString getDeviceSystemVersion]}];
    if ([kStanderDefault objectForKey:@"GeTuiClientId"]) {

        [parames setObject:[kStanderDefault objectForKey:@"GeTuiClientId"] forKey:@"ua.clientId"];
    }
    
    [kNetWork requestPOSTUrlString:kLogin parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        if ([dic[@"state"] integerValue] == 0) {
            
            NSDictionary *user = dic[@"data"];
            
            [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
            [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
            
            _userModel = [[UserModel alloc]init];
            for (NSString *key in [user allKeys]) {
                [_userModel setValue:user[key] forKey:key];
            }
            
            [self webView:_webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] navigationType:UIWebViewNavigationTypeLinkClicked];
        }
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }];
    
    _webView = [[UIWebView alloc]initWithFrame:kScreenFrame];
    [self.view addSubview:_webView];
    _webView.scrollView.scrollEnabled = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.webView.delegate = self;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.serviceModel.indexUrl]]];
    
    _searchView = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_searchView];
    _searchView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_searchView startAnimating];
    
    [self passValueWithBlock];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMachineDeviceAtcion:) name:kServiceOrder object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if (self.serviceModel && self.userModel) {
        [kSocketTCP sendDataToHost:nil andType:kAddService];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_delegate respondsToSelector:@selector(sendServiceModelToParentVC:)] && _delegate) {
        [_delegate sendServiceModelToParentVC:self.serviceModel];
    }
    
    if ([_delegate respondsToSelector:@selector(serviceCurrentConnectedState:)]) {
        [_delegate serviceCurrentConnectedState:self.connectState];
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __block typeof(self)bself = self;
    
    _context[@"PageLoadIOS"] = ^{
        
        if (bself.searchView) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                bself.searchView.hidden = YES;
            });
            
        }
        
        
        NSMutableDictionary *userData = [NSMutableDictionary
                                         dictionary];
        
        if (bself.userModel.sn) {
            [userData setObject:@(bself.userModel.sn) forKey:@"userSn"];
        }
        if (bself.serviceModel.devSn) {
            [userData setObject:bself.serviceModel.devSn forKey:@"devSn"];
        }
        if (bself.serviceModel.userDeviceID) {
            [userData setObject:@(bself.serviceModel.userDeviceID) forKey:@"UserDeviceID"];
        }
        if (KALIHost) {
            [userData setObject:[NSString stringWithFormat:@"http://%@:8080/" , KALIHost] forKey:@"ServieceIP"];
        }

        if (![bself.serviceModel.brand isKindOfClass:[NSNull class]]) {
            [userData setObject:[NSString stringWithFormat:@"%@%@" , bself.serviceModel.brand , bself.serviceModel.typeName] forKey:@"BrandName"];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userData options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSString *orderStr = [NSString stringWithFormat:@"GetUserData(%@)" , jsonStr];
        [bself.context evaluateScript:orderStr];
    };
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    //    __block typeof(self)bself = self;
    __block typeof (self)bself = self;
    _context[@"ShowRemind"] = ^() {
        NSArray *parames = [JSContext currentArguments];
        NSString *arrarString = [[NSString alloc]init];
        for (id obj in parames) {
            arrarString = [arrarString stringByAppendingFormat:@"%@" , obj];
        }
        NSLog(@"%@" , arrarString);
        
        [UIAlertController creatCancleAndRightAlertControllerWithHandle:nil andSuperViewController:bself Title:arrarString];
        
    };
}


- (void)passValueWithBlock {
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __block typeof(self)bself = self;
    context[@"BackIOS"] = ^() {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [bself.navigationController popViewControllerAnimated:YES];
        });
        
    };
    
    context[@"OrderWebToIOS"] = ^() {
        NSArray *parames = [JSContext currentArguments];
        NSString *arrarString = [[NSString alloc]init];
        
        for (id obj in parames) {
            arrarString = [arrarString stringByAppendingFormat:@"%@" , obj];
        }
        
        
        NSArray *array = [arrarString componentsSeparatedByString:@","];
        
        NSMutableString *sumStr = [NSMutableString string];
//        [sumStr appendFormat:@"%@", [NSString stringWithFormat:@"HMFFM%@%@w" , self.serviceModel.devTypeSn, self.serviceModel.devSn]];
        
        for (NSString *sub in array) {
            
            if (sub.length == 1) {
                [sumStr appendFormat:@"0%@", [NSString toHex:sub.integerValue]];
                
            } else {
                [sumStr appendFormat:@"%@", [NSString toHex:sub.integerValue]];
            }
        }
        
//        [sumStr appendString:@"#"];
       
        NSLog(@"发送给TCP的命令%@ , %@" , sumStr , parames);
        
        [kSocketTCP sendDataToHost:sumStr andType:kZhiLing];
    };
}

- (void)getMachineDeviceAtcion:(NSNotification *)post {
    NSMutableString *sumStr = nil;
    sumStr = [NSMutableString stringWithString:post.userInfo[@"Message"]];
    
    for (NSInteger i = sumStr.length - 2; i > 0; i = i - 2) {
        [sumStr insertString:@"," atIndex:i];
    }
    
    
    NSString *callJSstring = nil;
    callJSstring = [NSString stringWithFormat:@"ReceiveOrder('%@')" , sumStr];
    
    NSLog(@"发送给H5的命令%@" , callJSstring);
    
    if (_context == nil || callJSstring == nil) {
        return ;
    }
    
    [_context evaluateScript:callJSstring];
    sumStr = nil;
    
}


- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    NSDictionary *dic = data[0];
    //    NSLog(@"%@" , dic);
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        _userModel = [[UserModel alloc]init];
        for (NSString *key in [user allKeys]) {
            [_userModel setValue:user[key] forKey:key];
        }
        
        [self webView:_webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] navigationType:UIWebViewNavigationTypeLinkClicked];
    }
}

- (void)requestData:(HelpFunction *)request didFailLoadData:(NSError *)error {
    NSLog(@"%@" , error);
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

- (NSMutableDictionary *)dic {
    if (!_dic) {
        _dic = [NSMutableDictionary dictionary];
    }
    return _dic;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

