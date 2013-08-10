//
//  YMLCropViewOverlay.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "YMLCropViewOverlay.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLCropViewOverlay () {
    CALayer *borderLayer;
}

@end

@implementation YMLCropViewOverlay

@synthesize overlayColor;
@synthesize cropRect;

- (id) initWithFrame:(CGRect)frame cropRect:(CGRect)_cropRect {
    self = [super initWithFrame:frame];
    if (self) {
        cropRect = _cropRect;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
        
        borderLayer = [CALayer layer];
        [borderLayer setFrame:cropRect];
        [borderLayer setBorderColor:[[UIColor blackColor] CGColor]];
        [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [borderLayer setBorderWidth:1.0];
        [borderLayer setCornerRadius:4.0];
        [[self layer] addSublayer:borderLayer];
    }
    
    return self;
}

- (void) setCropRect:(CGRect)__cropRect {
    cropRect = __cropRect;
    [borderLayer setFrame:cropRect];
}

- (void) drawRect:(CGRect)rect {
    UIColor *color = [self backgroundColor];
    if (overlayColor) {
        color = overlayColor;
    }
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *mainPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    CGContextAddPath(context, clipPath.CGPath);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillPath(context);
    
    //[clipPath appendPath:aPath];
    [clipPath appendPath:[UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:4.0]];
    clipPath.usesEvenOddFillRule = YES;
    [clipPath addClip];
    
    CGContextAddPath(context, mainPath.CGPath);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillPath(context);
}


#pragma mark - Dealloc

- (void) dealloc {
    overlayColor = nil;
    borderLayer = nil;
}

@end
