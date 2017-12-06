//
//  AllServicesCollectionViewCell.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/11/8.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "AllServicesCollectionViewCell.h"

@interface AllServicesCollectionViewCell ()
@property (strong, nonatomic)  UIImageView *backImage;
@property (nonatomic , strong) UILabel *typeName;
@end

@implementation AllServicesCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (kScreenW - kScreenW * 2 / 25) / 2, kScreenH / 5.12)];
    UIView *view = [[UIView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:view];
    self.contentView.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    
    _backImage = [[UIImageView alloc]init];
    [view addSubview:_backImage];
    [_backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(view.width, view.height * 5 / 9));
        make.centerX.mas_equalTo(view.mas_centerX);
        make.top.mas_equalTo(view.mas_top).offset(view.height / 9);
    }];
    _backImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _typeName = [UILabel creatLableWithTitle:@"" andSuperView:view andFont:k13 andTextAligment:NSTextAlignmentCenter];
    [_typeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(view.width - kScreenW / 14, view.height * 3 / 9));
        make.centerX.mas_equalTo(view.mas_centerX);
        make.top.mas_equalTo(_backImage.mas_bottom);
    }];
    _typeName.layer.borderWidth = 0;
    
    
//    UIView *rightFenGeView = [[UIView alloc]init];
//    rightFenGeView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
//    [self.contentView addSubview:rightFenGeView];
//    [rightFenGeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(1, view.height));
//        make.centerY.mas_equalTo(view.mas_centerY);
//        make.right.mas_equalTo(view.mas_right);
//    }];
//    
//    UIView *bottomFenGeView = [[UIView alloc]init];
//    bottomFenGeView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
//    [self.contentView addSubview:bottomFenGeView];
//    [bottomFenGeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(view.width, 1));
//        make.centerX.mas_equalTo(view.mas_centerX);
//        make.bottom.mas_equalTo(view.mas_bottom);
//    }];
    
    return self;
}

- (void)setDataCount:(NSInteger)dataCount {
    _dataCount = dataCount;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    
    _serviceModel = serviceModel;
    
    
    if (self.serviceModel) {
        [self.backImage sd_setImageWithURL:[NSURL URLWithString:self.serviceModel.imageUrl] placeholderImage:[UIImage new]];
        
        if (self.serviceModel.definedName) {
            self.typeName.text = self.serviceModel.definedName;
        } else {

            if (self.serviceModel.brand == nil) {
                self.typeName.text = [NSString stringWithFormat:@"%@" , self.serviceModel.typeName];
            } else {
                self.typeName.text = [NSString stringWithFormat:@"%@%@" , self.serviceModel.brand , self.serviceModel.typeName];
            }
            
        }
    }
    
}

@end
