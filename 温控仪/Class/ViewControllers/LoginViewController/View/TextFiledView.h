//
//  TextFiledView.h
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/5/22.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFiledView : UIView

@property (nonatomic , assign) BOOL whetherdark;

- (instancetype)initWithColor:(UIColor *)color andAlpthFloat:(CGFloat)alpthFloat andTextFiledPlaceHold:(NSString *)placeHolder andSuperView:(UIView *)superView;
@end
