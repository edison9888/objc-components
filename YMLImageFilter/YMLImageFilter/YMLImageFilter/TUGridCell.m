//
//  TUGridCell.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/24/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUGridCell.h"

#import <QuartzCore/QuartzCore.h>

@interface TUGridCell () {
    UIImageView *imageView;
}

@end

@implementation TUGridCell

@synthesize enableHighlighting;

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:CLEAR_COLOR];
//        [[self contentView] setBackgroundColor:CLEAR_COLOR];
        [[self contentView] setBackgroundColor:WHITE_COLOR];
        
        [[[self contentView] layer] setBorderColor:[[UIColor colorWith255Red:102 green:102 blue:102 alpha:1.0] CGColor]];
        [[[self contentView] layer] setBorderWidth:1.0];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset([[self contentView] frame], 2, 2)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [[self contentView] addSubview:imageView];
        
        enableHighlighting = YES;
    }
    return self;
}


#pragma mark - Public Methods

- (void) setHighlighted:(BOOL)value animated:(BOOL)animated {
    if (enableHighlighting) {
        [super setHighlighted:value animated:animated];
        
        [_selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        [self bringSubviewToFront:_selectedBackgroundView];
    }
}

- (void) setImage:(UIImage *)image {
    [imageView setImage:image];
}

- (void) clear {
    [imageView setImage:nil];
}


#pragma mark - Dealloc

- (void) dealloc {
    imageView = nil;
}

@end
