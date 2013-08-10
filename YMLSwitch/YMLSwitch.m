//
//  CustomSwitch.m
//  fanlala
//
//  Created by Sumit Mehra on 4/24/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "YMLSwitch.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLSwitch () {
    id target;
    SEL action;
}

- (void) rightSwip:(UISwipeGestureRecognizer *)gesture;
- (void) leftSwip:(UISwipeGestureRecognizer *)gesture;
- (void) topSwip:(UISwipeGestureRecognizer *)gesture;
- (void) bottomSwip:(UISwipeGestureRecognizer *)gesture;

@end

@implementation YMLSwitch

@synthesize switchThumb, backgroundView;
@synthesize onLabel, offLabel;
@synthesize isOn, isVertical;

- (id)initWithFrame:(CGRect)frame {    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[self layer] setCornerRadius:6.0];
        [[self layer] setMasksToBounds:YES];
        [self setBackgroundColor:[UIColor blueColor]];
        
        backgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [self addSubview:backgroundView];
        [backgroundView release];
        
        onLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (frame.size.width/2), frame.size.height)];
        [onLabel setBackgroundColor:[UIColor clearColor]];
        [onLabel setTextAlignment:UITextAlignmentCenter];
        [onLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0]];
        [onLabel setTextColor:[UIColor whiteColor]];
        [onLabel setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65]];
        [onLabel setShadowOffset:CGSizeMake(0, 1)];
        [onLabel setText:NSLocalizedString(@"ON", @"")];
        [self addSubview:onLabel];
        [onLabel release];
        
        offLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2), 0, (frame.size.width/2), frame.size.height)];
        [offLabel setBackgroundColor:[UIColor clearColor]];
        [offLabel setTextAlignment:UITextAlignmentCenter];
        [offLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0]];
        [offLabel setTextColor:[UIColor whiteColor]];
        [offLabel setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65]];
        [offLabel setShadowOffset:CGSizeMake(0, 1)];
        [offLabel setText:NSLocalizedString(@"OFF", @"")];
        [self addSubview:offLabel];
        [offLabel release];
        
        switchThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height)];
        [switchThumb setBackgroundColor:[UIColor whiteColor]];
        [[switchThumb layer] setCornerRadius:6.0];
        [[switchThumb layer] setMasksToBounds:YES];
        [self addSubview:switchThumb];
        [switchThumb release];
        
        UISwipeGestureRecognizer *rightSwipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwip:)];
        [rightSwipGesture setNumberOfTouchesRequired:1];
        [rightSwipGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:rightSwipGesture];
        ReleaseObject(rightSwipGesture);
        
        
        UISwipeGestureRecognizer *leftSwipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwip:)];
        [leftSwipGesture setNumberOfTouchesRequired:1];
        [leftSwipGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:leftSwipGesture];
        ReleaseObject(leftSwipGesture);
        
        UISwipeGestureRecognizer *topSwipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(topSwip:)];
        [topSwipGesture setNumberOfTouchesRequired:1];
        [topSwipGesture setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:topSwipGesture];
        ReleaseObject(topSwipGesture);
        
        
        UISwipeGestureRecognizer *bottomSwipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bottomSwip:)];
        [bottomSwipGesture setNumberOfTouchesRequired:1];
        [bottomSwipGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [self addGestureRecognizer:bottomSwipGesture];
        ReleaseObject(bottomSwipGesture);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Private Methods

- (void) rightSwip:(UISwipeGestureRecognizer *)gesture {
    if (!isOn && !isVertical) {
        [self setIsOn:YES animation:YES];
    }
}

- (void) leftSwip:(UISwipeGestureRecognizer *)gesture {
    if (isOn && !isVertical) {
        [self setIsOn:NO animation:YES];
    }
}

- (void) topSwip:(UISwipeGestureRecognizer *)gesture {
    if (!isOn && isVertical) {
        [self setIsOn:YES animation:YES];
    }
}

- (void) bottomSwip:(UISwipeGestureRecognizer *)gesture {
    if (isOn && isVertical) {
        [self setIsOn:NO animation:YES];
    }
}


#pragma mark - Public Methods

- (void) setIsOn:(BOOL)_isOn {
    [self setIsOn:_isOn animation:NO];
}

- (void) setIsOn:(BOOL)_isOn animation:(BOOL)animation {
    @synchronized (self) {
        isOn = _isOn;
        
        if (animation) {
            [UIView animateWithDuration:0.3 
                             animations:^{
                                 if (isVertical) {
                                     [switchThumb setFrame:CGRectOffset([switchThumb frame], 0, (self.frame.size.height - switchThumb.frame.size.height) * ((isOn)? -1:1))];
                                 }
                                 else {
                                     [switchThumb setFrame:CGRectOffset([switchThumb frame], (self.frame.size.width - switchThumb.frame.size.width) * ((isOn)? 1:-1), 0)];
                                 }
                             } completion:^(BOOL finished) {
                                 if (target) {
                                     [target performSelector:action withObject:self];
                                 }
                             }];
        }
        else {
            if (isVertical) {
                [switchThumb setFrame:CGRectOffset([switchThumb frame], 0, (self.frame.size.height - switchThumb.frame.size.height) * ((isOn)? 1:-1))];
            }
            else {
                [switchThumb setFrame:CGRectOffset([switchThumb frame], (self.frame.size.width - switchThumb.frame.size.width) * ((isOn)? 1:-1), 0)];
            }
            
            if (target) {
                [target performSelector:action withObject:self];
            }
        }
    }
}

- (void) addTarget:(id)_target action:(SEL)_action {
    target = _target;
    action = _action;
}

- (void) setOnText:(NSString *)onText {
    [onLabel setText:onText];
}

- (void) setOffText:(NSString *)offText {
    [offLabel setText:offText];
}

- (void) setBackground:(UIImage *)background {
    if (background) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    [backgroundView setImage:background];
}

- (void) setThumb:(UIImage *)thumb {
    if (thumb) {
        [switchThumb setBackgroundColor:[UIColor clearColor]];
    }
    [switchThumb setImage:thumb];
}

- (void) setVertical:(BOOL)vertical {
    isVertical = vertical;
}

- (void) layoutControlForVertical:(BOOL)vertical {
    CGRect frame = [self bounds];
    
    if (isVertical) {
        [backgroundView setFrame:[self bounds]];
        [switchThumb setFrame:CGRectMake(0, (isOn)?0:frame.size.height - switchThumb.frame.size.width, frame.size.width, frame.size.height/2)];      //Previous width is present height
        [onLabel setHidden:YES];
        [offLabel setHidden:YES];
    }
    else {
        [backgroundView setFrame:[self bounds]];
        [switchThumb setFrame:CGRectMake((isOn)?frame.size.width/2:0, 0, frame.size.width/2, frame.size.height)];
        [onLabel setHidden:NO];
        [offLabel setHidden:NO];
    }
}


#pragma mark - Dealloc

- (void) dealloc {
    backgroundView = nil;
    switchThumb = nil;
    
    [super dealloc];
}

@end
