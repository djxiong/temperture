//
//  CustomStyleBtn.h
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/5/22.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomStyleBtn : UIButton

- (CustomStyleBtn *_Nonnull)initWithTitle:(NSString * _Nonnull)title andBorderColor:(UIColor *_Nonnull)borderColor WithTarget:(nullable id)delegate andDoneAtcion:(nonnull SEL)doneAtcion andSuperView:(UIView * _Nonnull)superView;

@end
