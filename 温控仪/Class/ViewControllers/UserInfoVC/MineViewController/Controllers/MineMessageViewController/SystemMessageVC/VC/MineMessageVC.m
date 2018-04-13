//
//  MineMessageVC.m
//  温控仪
//
//  Created by 杭州阿尔法特 on 2018/4/10.
//  Copyright © 2018年 张海昌. All rights reserved.
//

#import "MineMessageVC.h"

@interface MineMessageVC ()

@end

@implementation MineMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setui];
    
}

- (void)setui {
    UIView *markView = [[UIView alloc]init];
    [self.view addSubview:markView];
    [markView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    markView.backgroundColor = [UIColor whiteColor];
    markView.layer.shadowColor = [UIColor blackColor].CGColor;
    markView.layer.shadowOffset = CGSizeMake(0,0);
    markView.layer.shadowRadius = 4.f;
    markView.layer.shadowOpacity = 0.5;
    
    
    UILabel *titleLabel = [UILabel creatLableWithTitle:self.model.title andSuperView:markView andFont:k20 andTextAligment:NSTextAlignmentCenter];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(markView.mas_centerX);
        make.top.mas_equalTo(markView.mas_top).offset(35);
    }];
    
    UILabel *timelabel = [UILabel creatLableWithTitle:self.model.addTime andSuperView:markView andFont:k13 andTextAligment:NSTextAlignmentCenter];
    [timelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(markView.mas_centerX).offset(-10);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
    }];
    
    UILabel *authorlabel = [UILabel creatLableWithTitle:@"编辑: 启联者" andSuperView:markView andFont:k13 andTextAligment:NSTextAlignmentCenter];
    [authorlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(markView.mas_centerX).offset(10);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
    }];
    
    UILabel *contentlabel = [UILabel creatLableWithTitle:self.model.content andSuperView:markView andFont:k15 andTextAligment:NSTextAlignmentCenter];
    contentlabel.numberOfLines = 0;
    [contentlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(markView.mas_centerX).offset(10);
        make.top.mas_equalTo(timelabel.mas_bottom).offset(20);
        make.left.mas_equalTo(25);
        make.right.mas_equalTo(markView.mas_right).offset(-25);
    }];
}

- (void)setModel:(SystemMessageModel *)model {
    _model = model;
}

@end
