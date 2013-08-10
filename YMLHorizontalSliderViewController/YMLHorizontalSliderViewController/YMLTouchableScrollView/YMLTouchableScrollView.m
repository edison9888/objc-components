//
//  YMLTouchableScrollView.m
//  Shutterfly
//
//  Created by Karthik Keyan B on 6/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import "YMLTouchableScrollView.h"

@implementation YMLTouchableScrollView

@synthesize touchDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Touch Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([touchDelegate respondsToSelector:@selector(touchableScrollView:touchesBegan:withEvent:)]) {
        [touchDelegate touchableScrollView:self touchesBegan:touches withEvent:event];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if ([touchDelegate respondsToSelector:@selector(touchableScrollView:touchesMoved:withEvent:)]) {
        [touchDelegate touchableScrollView:self touchesMoved:touches withEvent:event];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if ([touchDelegate respondsToSelector:@selector(touchableScrollView:touchesEnded:withEvent:)]) {
        [touchDelegate touchableScrollView:self touchesEnded:touches withEvent:event];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if ([touchDelegate respondsToSelector:@selector(touchableScrollView:touchesCancelled:withEvent:)]) {
        [touchDelegate touchableScrollView:self touchesCancelled:touches withEvent:event];
    }
}


#pragma mark - Dealloc

- (void) dealloc {
    touchDelegate = nil;

    [super dealloc];
}

@end
