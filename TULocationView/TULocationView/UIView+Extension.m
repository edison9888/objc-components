//
//  UIView+Extension.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "UIView+Extension.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Extension)

- (UIImage *) imageByRenderingView {
	CGFloat oldAlpha = self.alpha;
    BOOL previousHiddenState = [self isHidden];
    
	self.alpha = 1;
    [self setHidden:NO];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    }
    else {
        UIGraphicsBeginImageContext(self.bounds.size);
    }
	[[self layer] renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    [self setHidden:previousHiddenState];
	self.alpha = oldAlpha;
	
	return resultingImage;
}

- (UIImage *) imageByRenderAndFlipView {
    CGFloat oldAlpha = self.alpha;
    BOOL previousHiddenState = [self isHidden];
    
	self.alpha = 1;
    [self setHidden:NO];
	
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    }
    else {
        UIGraphicsBeginImageContext(self.bounds.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(context, flipVertical);
    [self.layer renderInContext:context];
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	[self setHidden:previousHiddenState];
	self.alpha = oldAlpha;
	
	return resultingImage;
}

- (CGFloat) top {
    return self.frame.origin.y;
}

- (CGFloat) bottom {
    return self.top + self.height;
}

- (CGFloat) right {
    return self.left + self.width;
}

- (CGFloat) left {
    return self.frame.origin.x;
}

- (CGFloat) innerWidth {
    return self.bounds.size.width;
}

- (CGFloat) width {
    return self.frame.size.width;
}

- (CGFloat) innerHeight {
    return self.bounds.size.height;
}

- (CGFloat) height {
    return self.frame.size.height;
}

- (void) makeSubViewVerticalCenter:(UIView *)subView {
    CGRect rect = [subView frame];
    rect.origin.y = ((self.height - rect.size.height) * 0.5);
    [subView setFrame:rect];
}

- (void) makeSubViewHorizontalCenter:(UIView *)subView {
    CGRect rect = [subView frame];
    rect.origin.x = ((self.width - rect.size.width) * 0.5);
    [subView setFrame:rect];
}

@end
