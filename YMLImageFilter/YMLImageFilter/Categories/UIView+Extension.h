//
//  UIView+Extension.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

- (UIImage *) imageByRenderingView;
- (UIImage *) imageByRenderAndFlipView;

- (CGFloat) top;
- (CGFloat) bottom;
- (CGFloat) right;
- (CGFloat) left;
- (CGFloat) innerWidth;
- (CGFloat) width;
- (CGFloat) innerHeight;
- (CGFloat) height;
- (void) makeSubViewVerticalCenter:(UIView *)subView;
- (void) makeSubViewHorizontalCenter:(UIView *)subView;

@end
