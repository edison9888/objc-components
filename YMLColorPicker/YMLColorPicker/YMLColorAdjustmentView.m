//
//  YMLColorAdjustmentView.m
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLColorAdjustmentView.h"
#import "UIImageView+Extension.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLColorAdjustmentView () {
    UIImageView *thumbView, *gradientView;
}

@end

@implementation YMLColorAdjustmentView

@synthesize currentColor;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setCurrentColor:[UIColor whiteColor]];
        
        gradientView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [[gradientView layer] setCornerRadius:10.0];
        [[gradientView layer] setMasksToBounds:YES];
        [self addSubview:gradientView];
        [gradientView release];
        
        UIImageView *innerShadowView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [innerShadowView setImage:[[UIImage imageNamed:@"img_innershadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 11, 10, 10)]];
        [self addSubview:innerShadowView];
        [innerShadowView release], innerShadowView = nil;
        
        CGFloat thumbWidth = 25.0, thumbHeight = 25.0;
        
        thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - thumbHeight)/2, thumbWidth, thumbHeight)];
        [thumbView setImage:[UIImage imageNamed:@"img_colorpickerthumb"]];
        [self addSubview:thumbView];
        [thumbView release];
    }
    return self;
}


#pragma mark - Public Methods

- (void) createAdjustmentPaletteForColor:(UIColor *)color {
    CALayer *containerLayer = [[CALayer alloc] init];
    [containerLayer setFrame:[self bounds]];
    
    CAGradientLayer *gradiantLayer = [[CAGradientLayer alloc] init];
    [gradiantLayer setFrame:[containerLayer bounds]];
    [gradiantLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[color CGColor], nil]];
    [gradiantLayer setStartPoint:CGPointMake(0, 0)];
    [gradiantLayer setEndPoint:CGPointMake(1.0, 0.0)];
    [containerLayer addSublayer:gradiantLayer];
    [gradiantLayer release], gradiantLayer = nil;
    
    CAGradientLayer *blackGradientLayer = [[CAGradientLayer alloc] init];
    [blackGradientLayer setFrame:CGRectMake(0, containerLayer.bounds.size.height/2, containerLayer.bounds.size.width, containerLayer.bounds.size.height/2)];
    [blackGradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], (id)[[UIColor blackColor] CGColor], nil]];
    [blackGradientLayer setStartPoint:CGPointMake(0, 0)];
    [blackGradientLayer setEndPoint:CGPointMake(0, 1.0)];
    [containerLayer addSublayer:blackGradientLayer];
    [blackGradientLayer release], blackGradientLayer = nil;
    
    UIGraphicsBeginImageContext(gradientView.bounds.size);
    [containerLayer renderInContext:UIGraphicsGetCurrentContext()];
    [gradientView setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    [containerLayer release], containerLayer = nil;
    
    [self moveToPoint:[thumbView center]];
}

- (void) moveToPoint:(CGPoint)point {
    if (point.x > 8 && point.x < (self.bounds.size.width - 8) && point.y > 8 && point.y < (self.bounds.size.height - 8)) {
        [thumbView setCenter:CGPointMake(point.x, point.y)];
        
        [self setCurrentColor:[gradientView colorAtPoint:[thumbView center]]];
        if ([delegate respondsToSelector:@selector(colorAdjustmentView:didPickColor:)]) {            
            [delegate colorAdjustmentView:self didPickColor:currentColor];
        }
    }
}


#pragma mark - Private Methods

- (void) moveThumbViewForTouches:(NSSet *)touches {
    UIView *touchedView = [[touches anyObject] view];
    CGPoint point = [[touches anyObject] locationInView:touchedView];
    
    [self moveToPoint:point];
}


#pragma mark - Touch Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveThumbViewForTouches:touches];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveThumbViewForTouches:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveThumbViewForTouches:touches];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveThumbViewForTouches:touches];
}


#pragma mark - Dealloc

- (void)dealloc {
    delegate = nil;
    gradientView = nil;
    thumbView = nil;
    
    if (currentColor) {
        [currentColor release], currentColor = nil;
    }
    
    [super dealloc];
}

@end
