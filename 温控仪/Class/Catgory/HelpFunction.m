//
//  HelpFunction.m
//  知晓时代
//
//  Created by laouhn on 15/12/16.
//  Copyright (c) 2015年 laouhn. All rights reserved.
//

#import "HelpFunction.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import "AFNetworking.h"

@interface HelpFunction ()
@property (nonatomic,strong) NSError *error;

@end

static HelpFunction *_request = nil;

@implementation HelpFunction

#pragma mark - 单例
+ (HelpFunction *)shareHelpFunction{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _request = [[HelpFunction alloc]init];
    });
    return _request;
}

- (HelpFunction *)initWithUrl:(NSString *)str andParames:(NSDictionary *)parames andImage:(UIImage *)image andDelegate:(id<HelpFunctionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.urlString = str;
        self.parames = parames;
        self.image = image;
        self.delegate = delegate;
    }
    return self;
}

+ (HelpFunction *)requestDataWithUrlString:(NSString *)urlString andParames:(NSDictionary *)parames andImage:(UIImage *)image andDelegate:(id<HelpFunctionDelegate>)delegate{
    HelpFunction *requsst = [[HelpFunction alloc]initWithUrl:urlString andParames:parames andImage:image andDelegate:delegate];
    [requsst startRequestData:parames andImage:image];

    return requsst;
}

- (void)startRequestData:(NSDictionary *)parames andImage:(UIImage *)image {
    if (self.urlString.length == 0) {
        return ;
    }
    //图片缩放
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    NSString *strUrl = [self.urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:strUrl parameters:parames constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"files" fileName:fileName mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        
        if ( _delegate && [_delegate respondsToSelector:@selector(requestData:didSuccess:)]) {
            [_delegate requestData:self didSuccess:dic];
        } else {
            [_delegate requestData:self didFailLoadData:self.error];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"头像上传失败");
    }];
    
}

@end

