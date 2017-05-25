//
//  ServiceBaseCollectionCell.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/4/12.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "ServiceBaseCollectionCell.h"

@interface ServiceBaseCollectionCell ()

@end

@implementation ServiceBaseCollectionCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (kScreenW - 1) / 2, kScreenH / 4.16)];
        [self.contentView addSubview:view];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _backImage = [[UIImageView alloc]init];
        [view addSubview:_backImage];
        [_backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(view.width, view.height * 5 / 9));
            make.centerX.mas_equalTo(view.mas_centerX);
            make.top.mas_equalTo(view.mas_top).offset(view.height / 9);
        }];
        _backImage.contentMode = UIViewContentModeScaleAspectFit;
        
        _typeName = [UILabel creatLableWithTitle:@"" andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentLeft];
        [_typeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(view.width - kScreenW / 14, view.height / 6));
            make.centerX.mas_equalTo(view.mas_centerX);
            make.top.mas_equalTo(_backImage.mas_bottom);
        }];
        _typeName.layer.borderWidth = 0;
        
        _numberLabel = [UILabel creatLableWithTitle:@"" andSuperView:view andFont:k12 andTextAligment:NSTextAlignmentLeft];
        [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(view.width / 2, view.height / 10));
            make.left.mas_equalTo(_typeName.mas_left);
            make.top.mas_equalTo(_typeName.mas_bottom);
        }];
        _numberLabel.textColor = [UIColor colorWithHexString:@"767676"];
        _numberLabel.layer.borderWidth = 0;
        
        UIImageView *pointImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_come"]];
        [view addSubview:pointImageView];
        [pointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(view.height / 8, view.height / 8));
            make.centerY.mas_equalTo(_numberLabel.mas_top);
            make.right.mas_equalTo(view.mas_right).offset(-kScreenW / 37.5);
        }];
        
//        _selectedImage = [[UIImageView alloc]initWithFrame:view.bounds];
//        [self.contentView addSubview:_selectedImage];
//        _selectedImage.image = [UIImage imageNamed:@"k_bg_down"];
//        _selectedImage.hidden = YES;
        
        UIView *rightFenGeView = [[UIView alloc]init];
        rightFenGeView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
        [view addSubview:rightFenGeView];
        [rightFenGeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1, view.height));
            make.centerY.mas_equalTo(view.mas_centerY);
            make.right.mas_equalTo(view.mas_right);
        }];
        
        UIView *bottomFenGeView = [[UIView alloc]init];
        bottomFenGeView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
        [view addSubview:bottomFenGeView];
        [bottomFenGeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(view.width, 1));
            make.centerX.mas_equalTo(view.mas_centerX);
            make.bottom.mas_equalTo(view.mas_bottom).offset(-1);
        }];
    }
    return self;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    _serviceModel = serviceModel;
}

@end
