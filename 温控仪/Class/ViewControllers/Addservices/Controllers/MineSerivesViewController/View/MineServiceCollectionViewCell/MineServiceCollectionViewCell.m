//
//  MineServiceCollectionViewCell.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/4/16.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "MineServiceCollectionViewCell.h"

@interface MineServiceCollectionViewCell ()

@end

@implementation MineServiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)setServiceModel:(ServicesModel *)serviceModel {
    
    [super setServiceModel:serviceModel];
    self.pointImageView.hidden = YES;
    
    if (self.serviceModel) {
        [self.backImage sd_setImageWithURL:[NSURL URLWithString:self.serviceModel.imageUrl] placeholderImage:[UIImage new]];
        
        if (self.serviceModel.definedName) {
            self.typeName.text = self.serviceModel.definedName;
        } else {
            
            if (self.serviceModel.brand) {
                self.typeName.text = [NSString stringWithFormat:@"%@%@" , self.serviceModel.brand , self.serviceModel.typeName];
            } else {
                self.typeName.text = [NSString stringWithFormat:@"%@" , self.serviceModel.typeName];
            }
            
        }
        self.numberLabel.text = [NSString stringWithFormat:@"No.%ld" ,((long)self.indexPath.row + 1)];
        
        if (self.serviceModel.ifConn == 1) {
            self.onlieLabel.text = NSLocalizedString(@"onLine", nil);
            self.onlieLabel.textColor = [UIColor colorWithRed: 28/255.0  green: 164/255.0  blue: 252/255.0  alpha: 1.0];
        } else {
            self.onlieLabel.text = NSLocalizedString(@"offLine", nil);
            self.onlieLabel.textColor = [UIColor colorWithHexString:@"767676"];
        }
        
        self.layer.masksToBounds = YES;
    }
    
}

@end
