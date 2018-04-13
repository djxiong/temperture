//
//  AboutProductCell.m
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/4/12.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import "AboutProductCell.h"

@implementation AboutProductCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setIndexpath:(NSIndexPath *)indexpath {
    [super setIndexpath:indexpath];
    
    if (self.indexpath.row == 0) {
        self.imageViw.image = [UIImage imageNamed:@"icon_product_explain"];
        self.lable.text = NSLocalizedString(@"Product Manual", nil);
        self.fenGeView.hidden = NO;
    } else if (self.indexpath.row == 1) {
        self.imageViw.image = [UIImage imageNamed:@"icon_feedback"];
        self.lable.text = NSLocalizedString(@"FeedBack", nil);
        self.fenGeView.hidden = NO;
    } else {
        self.imageViw.image = [UIImage imageNamed:@"icon_log"];
        self.lable.text = NSLocalizedString(@"Update Log", nil);
//        [self setBottomCorner];
        self.backImage.image = [UIImage imageNamed:@"bottomleftandright"];
    }
    
}



@end
