//
//  AboutOusTableViewCell.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/2/10.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "AboutOusTableViewCell.h"

@interface AboutOusTableViewCell ()

@end

@implementation AboutOusTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setIndexpath:(NSIndexPath *)indexpath {
    
    [super setIndexpath:indexpath];
        
    if (self.indexpath.row == 0) {
        self.lable.text = NSLocalizedString(@"Go To Evaluate", nil);
        self.imageViw.image = [UIImage imageNamed:@"icon_evaluation"];
        self.fenGeView.hidden = NO;
//        [self setTopCorner];
        self.backImage.image = [UIImage imageNamed:@"topleftandright"];
    } else {
        self.lable.text = NSLocalizedString(@"Contact Us", nil);
        self.imageViw.image = [UIImage imageNamed:@"icon_phone"];
//        [self setBottomCorner];
        self.backImage.image = [UIImage imageNamed:@"bottomleftandright"];
    }
    
}

@end
