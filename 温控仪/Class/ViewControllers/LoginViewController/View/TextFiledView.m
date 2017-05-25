//
//  TextFiledView.m
//  温控仪
//
//  Created by 杭州阿尔法特 on 2017/5/22.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "TextFiledView.h"

@interface TextFiledView ()<UITextFieldDelegate>
@property (nonatomic , assign) CGFloat alpthFloat;
@property (nonatomic , copy) UIColor *backColor;
@property (nonatomic , strong) UIImageView *backImage;
@end

@implementation TextFiledView

- (instancetype)initWithColor:(UIColor *)color andAlpthFloat:(CGFloat)alpthFloat andTextFiledPlaceHold:(NSString *)placeHolder andSuperView:(UIView *)superView{
    self = [super init];
    if (self) {
        self.backColor = color;
        self.alpthFloat = alpthFloat;
        self.frame = CGRectMake(0, 0, kScreenW, kScreenW / 10);
        [superView addSubview:self];
        self.backgroundColor = [color colorWithAlphaComponent:alpthFloat];
        UITextField *textFiled = [UITextField creatTextfiledWithPlaceHolder:placeHolder andSuperView:self];
        [textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kStandardW  , kScreenW / 10));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFiled.delegate = self;
        [textFiled setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textFiled setValue:[UIFont fontWithName:kFontWithName size:k16] forKeyPath:@"_placeholderLabel.font"];
        textFiled.textColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)setWhetherdark:(BOOL)whetherdark {
    _whetherdark = whetherdark;
    if (self.whetherdark) {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat + .1];
    } else {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (self.whetherdark) {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat + .3];
    } else {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat + .2];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (self.whetherdark) {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat + .1];
    } else {
        self.backgroundColor = [self.backColor colorWithAlphaComponent:self.alpthFloat];
    }
}

@end
