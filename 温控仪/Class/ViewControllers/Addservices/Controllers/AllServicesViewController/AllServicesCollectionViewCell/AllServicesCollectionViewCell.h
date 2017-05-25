//
//  AllServicesCollectionViewCell.h
//  联侠
//
//  Created by 杭州阿尔法特 on 2016/11/8.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllServicesCollectionViewCell : UICollectionViewCell
@property (nonatomic , copy) NSIndexPath *indexPath;
@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , assign) NSInteger dataCount;
@end
