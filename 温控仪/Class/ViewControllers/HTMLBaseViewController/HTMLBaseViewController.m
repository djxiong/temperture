//
//  HTMLBaseViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/12/1.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "HTMLBaseViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface HTMLBaseViewController ()<UIWebViewDelegate>

@property (nonatomic , strong) NSMutableDictionary *dic;

@property (nonatomic , strong) UIWebView *webView;
@property (nonatomic , strong) UIActivityIndicatorView *searchView;
@property (nonatomic , strong) JSContext *context;

@property (nonatomic , assign) BOOL whetherNetWork;
@property (nonatomic , assign) BOOL delegateService;
@end

@implementation HTMLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegateService = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMachineDeviceAtcion:) name:kServiceOrder object:nil];
    
    [self setData];
    [self webView];
    [self searchView];
    
    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    
    [self passValueWithBlock];
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
    
    if ([_delegate respondsToSelector:@selector(whetherDelegateService:)]) {
        [_delegate whetherDelegateService:self.delegateService];
    }
    
}

- (void)setData {
    NSDictionary *userData = [kPlistTools readDataFromFile:UserData];
    [self setUserData:userData];
}

- (void)setUserData:(NSDictionary *)dic {
    
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        _userModel = [[UserModel alloc]init];
        
        [_userModel yy_modelSetWithDictionary:user];
    }
}

#pragma mark - 懒加载
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:kScreenFrame];
        [self.view addSubview:_webView];
        _webView.scrollView.scrollEnabled = NO;
        _webView.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        _webView.delegate = self;
        
//        [kNetWork requestPOSTUrlString:kAllTypeServiceURL parameters:nil isSuccess:^(NSDictionary * _Nullable responseObject) {
//            self.whetherNetWork = YES;
//            if(self.serviceModel.indexUrl) {
//                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.serviceModel.indexUrl]]];
//            } else {
//                [self loadLocalWEB];
//            }
//        } failure:^(NSError * _Nonnull error) {
//            self.whetherNetWork = NO;
//            [self loadLocalWEB];
//        }];
        
        if (self.connectState == CONNECTED_ZHILIAN) {
            [self loadLocalWEB];
        } else {
            if(self.serviceModel.indexUrl) {
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.serviceModel.indexUrl]]];
            } else {
                [self loadLocalWEB];
            }
        }
        
    }
    return _webView;
}

- (void)loadLocalWEB {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlString = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:htmlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (UIActivityIndicatorView *)searchView {
    if (!_searchView) {
        _searchView = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_searchView];
        _searchView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_searchView startAnimating];
    }
    return _searchView;
}

#pragma mark - WebView 代理
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
        if ([kStanderDefault objectForKey:@"password"]) {
            [userData setObject:[kStanderDefault objectForKey:@"password"] forKey:@"identity"];
        }
        if (bself.userModel.sn) {
            [userData setObject:@(bself.userModel.sn) forKey:@"userSn"];
        }
        if (bself.serviceModel.devSn) {
            [userData setObject:bself.serviceModel.devSn forKey:@"devSn"];
        }
        if (bself.serviceModel.devTypeNumber) {
            [userData setObject:bself.serviceModel.devTypeNumber forKey:@"devTypeNumber"];
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
        
        NSArray *ary = [JSContext currentArguments];
        
        if (ary.count != 0) {
            self.delegateService = YES;
        }
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
        
        for (NSString *sub in array) {
            if (sub.length == 1) {
                [sumStr appendFormat:@"0%@", [NSString toHex:sub.integerValue]];
            } else {
                [sumStr appendFormat:@"%@", [NSString toHex:sub.integerValue]];
            }
        }
       
        NSLog(@"发送给TCP的命令%@ , %@" , sumStr , parames);
        
        if (!self.whetherNetWork) {
            if (self.connectState != CONNECTED_ZHILIAN) {
                [UIAlertController creatRightAlertControllerWithHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                } andSuperViewController:self Title:@"当前连接的WIFI无网络或手机无网络，请切换到可用的网络。"];
            }
        }
        
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

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
    if (self.connectState == CONNECTED_ZHILIAN) {
        _serviceModel.indexUrl = nil;
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

