//
//  UIImage+Extension.h
//  联侠
//
//  Created by 杭州阿尔法特 on 16/7/19.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 *  颜色转换为图片
 *
 *
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  vImage图片模糊
 *
 *
 */
+ (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

/**
 *  高斯图片模糊
 *
 *
 */
+ (UIImage *)coreBlurImage:(UIImage *)image
            withBlurNumber:(CGFloat)blur;


/**
 解决 colorWithPatternImage 方法平铺的问题

 @param img 选取的图片
 @param newSize 需要添加到的  父类 的  size
 @return 图片
 */
+ (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize;

@end
