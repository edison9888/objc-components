//
//  NavigationBar.m
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

CGFloat DEFAULT_MARGIN = 5.0;

@interface YMLNavigationBar () 

- (void) setupNavigationControls;
- (void) tapped:(UITapGestureRecognizer *)tapGesture;
- (void) singleTapped:(UITapGestureRecognizer *)tapGesture;

@end

@implementation YMLNavigationBar

@synthesize titleLabel;
@synthesize backgroundImageView, titleImage;
@synthesize leftBarButton, rightBarButton;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(VIEW_FRAME.size.width, NAVIGATIONBAR_HEIGHT + 2);
    frame.origin = CGPointMake(0, 0);
    
    self = [super initWithFrame:frame];
    if (self) {
        _actAsBarButton = YES;
        
//        [[self layer] setShadowOffset:CGSizeMake(0, 2)];
//        [[self layer] setShadowOpacity:0.2];
        
        // Initialization code
        [self setupNavigationControls];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tapGesture setNumberOfTapsRequired:2];
        [titleLabel setUserInteractionEnabled:YES];
        [titleLabel addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tapGesture2 setNumberOfTapsRequired:2];
        [titleImage setUserInteractionEnabled:YES];
        [titleImage addGestureRecognizer:tapGesture2];
        
        UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
        [tapGesture3 setNumberOfTapsRequired:1];
        [titleImage setUserInteractionEnabled:YES];
        [titleImage addGestureRecognizer:tapGesture3];
        
        UITapGestureRecognizer *tapGesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
        [tapGesture4 setNumberOfTapsRequired:1];
        [titleImage setUserInteractionEnabled:YES];
        [titleImage addGestureRecognizer:tapGesture4];
    }
    
    return self;
}


#pragma mark - Settters

- (void) setLeftBarButton:(YMLBarButton *)_leftBarButton {
    [self setLeftBarButton:_leftBarButton withMargin:DEFAULT_MARGIN];
}

- (void) setLeftBarButton:(YMLBarButton *)_leftBarButton withMargin:(int)margin {
    if (leftBarButton == _leftBarButton) { return; }
    
    if (leftBarButton) {
        [leftBarButton removeFromSuperview];
    }
    
    CGRect rect = [_leftBarButton frame];
    rect.origin.x = margin;
    [_leftBarButton setFrame:rect];
    
    leftBarButton = _leftBarButton;
    [self insertSubview:leftBarButton aboveSubview:titleImage];
}

- (void) setRightBarButton:(YMLBarButton *)_rightBarButton {
    [self setRightBarButton:_rightBarButton withMargin:DEFAULT_MARGIN];
}

- (void) setRightBarButton:(YMLBarButton *)_rightBarButton withMargin:(int)margin {
    if (rightBarButton == _rightBarButton) { return; }
    
    if (rightBarButton) {
        [rightBarButton removeFromSuperview];
    }
    
    CGRect rect = [_rightBarButton frame];
    rect.origin.x = VIEW_FRAME.size.width - (rect.size.width + margin);
    [_rightBarButton setFrame:rect];
    
    rightBarButton = _rightBarButton;
    [self insertSubview:rightBarButton aboveSubview:titleImage];
}


#pragma mark - Private Methods

- (void) setupNavigationControls {    
    backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self addSubview:backgroundImageView];
    [self setDefaultBackground];
    
    //Title Label
    float height = 40.0;
    float y = 2.0;
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, (self.bounds.size.width - (2 * margin)), height)];
    titleLabel = [[UILabel alloc] initWithFrame:[self bounds]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:NAVIGATIONBAR_TITLE_FONT];
    [titleLabel setTextColor:NAVIGATIONBAR_TITLE_FONT_COLOR];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setShadowColor:NAVIGATIONBAR_TITLE_SHADOW_COLOR];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self addSubview:titleLabel];
    
    //Title Image
    titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, height)];
    [titleImage setContentMode:UIViewContentModeCenter];
    [self addSubview:titleImage];
}

- (void) tapped:(UITapGestureRecognizer *)tapGesture {
    if (delegate && [delegate respondsToSelector:@selector(navigationBarDidTapped:)]) {
        [delegate navigationBarDidTapped:self];
    }
}

- (void) singleTapped:(UITapGestureRecognizer *)tapGesture {
    if (!_actAsBarButton) { return; }
    
    CGPoint tappedPoint = [tapGesture locationInView:self];
    if (tappedPoint.x <= ((self.innerWidth/2) - 40)) {
        if ([self leftBarButton] && [[self leftBarButton] isEnabled] && ![[self leftBarButton] isHidden] && [[self leftBarButton] alpha] == 1.0) {
            [[self leftBarButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if (tappedPoint.x >= ((self.innerWidth/2) + 40)) {
        if ([self rightBarButton] && [[self rightBarButton] isEnabled] && ![[self rightBarButton] isHidden] && [[self rightBarButton] alpha] == 1.0) {
            [[self rightBarButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}


#pragma mark - Public Methods

- (NSString *) title {
    return [titleLabel text];
}

- (void) setTitle:(NSString *)title {
    [titleImage setImage:nil];
    [titleLabel setText:title];
}

- (void) setTitleColor:(UIColor *)titleColor {
    [titleLabel setTextColor:titleColor];
}

- (void) setImage:(UIImage *)image {
    [titleLabel setText:@""];
    [titleImage setImage:image];
}

- (void) setBackgroundImage:(UIImage *)backgroundImage {
    [backgroundImageView setImage:backgroundImage];
}

- (void) setDefaultBackground {
    [backgroundImageView setImage:[UIImage stretchableImageWithName:@"bg_navbar" extension:@"png" topCap:0 leftCap:0 bottomCap:0 andRightCap:0]];
}

- (void) setControlsMargin:(CGPoint)margin {
    CGRect frame;
    
    if (leftBarButton) {
        frame = [leftBarButton frame];
        frame.origin.x += margin.x;
        frame.origin.y += margin.y;
        [leftBarButton setFrame:frame];
    }
    
    frame = [titleLabel frame];
    frame.origin.x += margin.x;
    frame.origin.y += margin.y;
    [titleLabel setFrame:frame];
    
    frame = [titleImage frame];
    frame.origin.x += margin.x;
    frame.origin.y += margin.y;
    [titleImage setFrame:frame];
    
    if (rightBarButton) {
        frame = [rightBarButton frame];
        frame.origin.x += margin.x;
        frame.origin.y += margin.y;
        [rightBarButton setFrame:frame];
    }
}


#pragma mark - Dealloc

- (void) dealloc {
    
}

@end
