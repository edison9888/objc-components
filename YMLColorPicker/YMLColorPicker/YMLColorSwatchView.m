//
//  YMLColorSwatchView.m
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLColorSwatchView.h"
#import "UIImageView+Extension.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLColorSwatchView () {
    UIImageView *gradientView, *thumbView;
}

- (void) moveThumbViewForTouches:(NSSet *)touches;

@end

@implementation YMLColorSwatchView

@synthesize currentColor;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setCurrentColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
        
        CGFloat thumbWidth = 25.0, thumbHeight = 25.0;
        
        NSMutableArray *colors = [[NSMutableArray alloc] init];
        [colors addObject:(id)[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:237.0/255.0 green:254.0/255.0 blue:0.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:0.0 green:1.0 blue:249.0/255.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:247.0/255.0 green:0.0 blue:1.0 alpha:1.0] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:229.0/255.0 green:0.0 blue:33.0/255.0 alpha:1.0] CGColor]];
        
        gradientView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [[gradientView layer] setCornerRadius:10.0];
        [self addSubview:gradientView];
        [gradientView release];
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        [gradientLayer setFrame:[self bounds]];
        [gradientLayer setCornerRadius:10.0];
        [gradientLayer setColors:colors];
        [gradientLayer setStartPoint:CGPointMake(0.0, 0.0)];
        [gradientLayer setEndPoint:CGPointMake(1.0, 0)];        
        [gradientView setImage:[UIImage imageWithData:[gradientLayer contents]]];
        
        UIGraphicsBeginImageContext(gradientView.bounds.size);
        [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
        [gradientView setImage:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        
        [gradientLayer release], gradientLayer = nil;
        [colors release], colors = nil;
        
        UIImageView *innerShadowView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [innerShadowView setImage:[[UIImage imageNamed:@"img_innershadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 11, 10, 10)]];
        [self addSubview:innerShadowView];
        [innerShadowView release], innerShadowView = nil;
        
        thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - thumbHeight)/2, thumbWidth, thumbHeight)];
        [thumbView setImage:[UIImage imageNamed:@"img_colorpickerthumb"]];
        [self addSubview:thumbView];
        [thumbView release];
    }
    return self;
}


#pragma mark - Private Methods

- (void) moveThumbViewForTouches:(NSSet *)touches {
    UIView *touchedView = [[touches anyObject] view];
    CGPoint point = [[touches anyObject] locationInView:touchedView];
    
    [self moveToPoint:point];
}


#pragma mark - Public Methods

- (void) moveToPoint:(CGPoint)point {
    if (point.x > 8 && point.x < (self.bounds.size.width - 8)) {
        [thumbView setCenter:CGPointMake(point.x, thumbView.center.y)];
        
        [self setCurrentColor:[gradientView colorAtPoint:[thumbView center]]];
        if ([delegate respondsToSelector:@selector(colorSwatch:didPickColor:)]) {            
            [delegate colorSwatch:self didPickColor:currentColor];
        }
    }
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


#pragma mark - Delloc

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
