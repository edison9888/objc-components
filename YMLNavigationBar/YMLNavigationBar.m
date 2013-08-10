//
//  NavigationBar.m
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLNavigationBar () 

- (void) setupNavigationControls;

@end

@implementation YMLNavigationBar

@synthesize titleLabel;
@synthesize backgroundImageView, titleImage;
@synthesize leftBarButton, rightBarButton;


- (id)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(VIEW_FRAME.size.width, NAVIGATIONBAR_HEIGHT);
    frame.origin = CGPointMake(0, 0);
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupNavigationControls];
    }
    
    return self;
}


#pragma mark - Settters

- (void)setLeftBarButton:(YMLBarButton *)_leftBarButton {
    if (leftBarButton == _leftBarButton) { return; }
    
    if (leftBarButton) {
        [leftBarButton removeFromSuperview];
        [leftBarButton release];
    }
    
    CGRect rect = [_leftBarButton frame];
    rect.origin.x = 5;
    [_leftBarButton setFrame:rect];
    
    leftBarButton = [_leftBarButton retain];
    [self insertSubview:leftBarButton aboveSubview:titleLabel];
}

- (void)setRightBarButton:(YMLBarButton *)_rightBarButton {
    if (rightBarButton == _rightBarButton) { return; }
    
    if (rightBarButton) {
        [rightBarButton removeFromSuperview];
        [rightBarButton release];
    }
    
    CGRect rect = [_rightBarButton frame];
    rect.origin.x = VIEW_FRAME.size.width - (rect.size.width + 5);
    [_rightBarButton setFrame:rect];
    
    rightBarButton = [_rightBarButton retain];
    [self insertSubview:rightBarButton aboveSubview:titleLabel];
}


#pragma mark - Private Methods

- (void) setupNavigationControls {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self layer] setShadowOffset:CGSizeMake(0, 1)];
    [[self layer] setShadowOpacity:0.5];
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
    [backgroundImageView setImage:[self stretchableImageWithName:@"bg_navbar" extension:@"png" topCap:0 leftCap:0 bottomCap:0 andRightCap:0]];
    [self addSubview:backgroundImageView];
    
    //Title Label
    float height = 40.0;
    float y = 2.0;
    float margin = 80.0;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, (self.bounds.size.width - (2 * margin)), height)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:NAVIGATIONBAR_TITLE_FONT];
    [titleLabel setTextColor:NAVIGATIONBAR_TITLE_FONT_COLOR];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setShadowColor:NAVIGATIONBAR_TITLE_SHADOW_COLOR];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self addSubview:titleLabel];
    
    
    //Title Image
    titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(margin, y, (self.bounds.size.width - (2 * margin)), height)];
    [self addSubview:titleImage];
}


#pragma mark - Public Methods

- (NSString *) title {
    return [titleLabel text];
}

- (void) setTitle:(NSString *)title {    
    [titleLabel setText:title];
}

- (void) setTitleColor:(UIColor *)titleColor {
    [titleLabel setTextColor:titleColor];
}

- (void) setImage:(UIImage *)image {
    [titleImage setImage:image];
    [titleImage setFrame:CGRectMake(((self.frame.size.width - image.size.width)/2), ((self.frame.size.height - image.size.height)/2), image.size.width, image.size.height)];
}

- (void) setBackgroundImage:(UIImage *)backgroundImage {
    [backgroundImageView setImage:backgroundImage];
}

- (void) setShowTitleShadow:(BOOL)shadow {
    if (shadow) {
        [titleLabel setShadowColor:NAVIGATIONBAR_TITLE_SHADOW_COLOR];
    }
    else {
        [titleLabel setShadowColor:[UIColor clearColor]];
    }
}

- (void) setDefaultBackground {
    [backgroundImageView setImage:[self stretchableImageWithName:@"bg_navbar" extension:@"png" topCap:0 leftCap:0 bottomCap:0 andRightCap:0]];
}



#pragma mark - Dealloc 

- (void)dealloc {
    backgroundImageView = nil;
    leftBarButton = nil;
    rightBarButton = nil;
    
    leftBarButton = nil;
    rightBarButton = nil;
    
    [super dealloc];
}


@end
