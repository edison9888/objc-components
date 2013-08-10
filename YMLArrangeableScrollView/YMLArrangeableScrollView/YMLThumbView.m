//
//  YMLThumbView.m
//  test
//
//  Created by Karthik Keyan B on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLThumbView.h"
#import <QuartzCore/QuartzCore.h>

@implementation YMLThumbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) startShakeAnimation {
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];    
    [anim setFromValue:[NSNumber numberWithDouble:-M_PI/64]];
    [anim setToValue:[NSNumber numberWithFloat:M_PI/64]];    
    [anim setDuration:0.1];
    [anim setRepeatCount:NSUIntegerMax];
    [anim setAutoreverses:YES];
    [self.layer addAnimation:anim forKey:@"SpringboardShake"];
}

- (void) stopShakeAnimation {
    [[self layer] removeAllAnimations];
    [[self layer] setTransform:CATransform3DRotate(CATransform3DIdentity, 0, 0.0, 0.0, 1.0)];
}

@end
