//
//  YMLColorPickerView.m
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLColorPickerView.h"

@interface YMLColorPickerView () <YMLColorSwatchViewDelegate, YMLColorAdjustmentViewDelegate>

@end


@implementation YMLColorPickerView

@synthesize adjustmentView, swatchView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        swatchView = [[YMLColorSwatchView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 22)];
        [swatchView setDelegate:self];
        [self addSubview:swatchView];
        [swatchView release];
        
        adjustmentView = [[YMLColorAdjustmentView alloc] initWithFrame:CGRectMake(10, swatchView.frame.origin.y + swatchView.frame.size.height + 24, self.bounds.size.width - 20, 140)];
        [adjustmentView setDelegate:self];
        [self addSubview:adjustmentView];
        [adjustmentView release];
    }
    return self;
}


#pragma mark - Setter methods

- (void) setDelegate:(id<YMLColorPickerViewDelegate>)_delegate {
    if (delegate != _delegate) {
        delegate = _delegate;
        
        [swatchView moveToPoint:CGPointMake(9, 9)];
        [adjustmentView moveToPoint:CGPointMake(adjustmentView.bounds.size.width - 9, 9)];
    }
}


#pragma mark - Swatch Delegate

- (void) colorSwatch:(YMLColorSwatchView *)_swatchView didPickColor:(UIColor *)color {
    [adjustmentView createAdjustmentPaletteForColor:color];
}


#pragma mark - Color Adjustment Delegate

- (void) colorAdjustmentView:(YMLColorAdjustmentView *)_adjustmentView didPickColor:(UIColor *)color {
    if ([delegate respondsToSelector:@selector(colorPicker:didPickColor:)]) {
        [delegate colorPicker:self didPickColor:color];
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    delegate = nil;
    swatchView = nil;
    adjustmentView = nil;
    
    [super dealloc];
}

@end
