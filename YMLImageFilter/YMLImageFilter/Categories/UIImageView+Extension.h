//
//  UIImageView+Extension.h
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extension)

- (UIColor *) colorAtPoint:(CGPoint)point;
- (CGSize) imageScaleSizeForContentMode:(UIViewContentMode)contentMode image:(UIImage *)image;
+ (CGSize) imageScaleSizeForContentMode:(UIViewContentMode)contentMode image:(UIImage *)image viewSize:(CGSize)viewSize;

@end

