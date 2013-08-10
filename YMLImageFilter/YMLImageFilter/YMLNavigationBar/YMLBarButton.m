//
//  BarButton.m
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLBarButton.h"

@interface YMLBarButton () {
    CGPoint badgeMargin;
    UIButton *badgeButton;
}

- (void) createBadgeButton;

@end

@implementation YMLBarButton

@synthesize badgeAlignment;
@synthesize type;

- (id) init {    
    return [self initWithBarButtonType:YMLBarButtonTypeNone];
}

- (id) initWithFrame:(CGRect)frame {
    return [self initWithBarButtonType:YMLBarButtonTypeNone];
}

- (id) initWithBarButtonType:(YMLBarButtonType)buttonType {
    self = [super initWithFrame:CGRectZero];
    badgeMargin = CGPointZero;
    
    badgeAlignment = YMLBarButtonBadgeAlignmentRight;
    
    float margin = 0.0, x = margin, y = 0, width = 0, height = 0;
    BOOL isImageButton = NO;
    
    if (self) {
        type = buttonType;
        
        [[self titleLabel] setFont:BARBUTTON_TITLE_FONT];
        [self setTitleColor:BARBUTTON_TITLE_COLOR forState:UIControlStateNormal];
        [self setTitleColor:BARBUTTON_TITLE_COLOR forState:UIControlStateHighlighted];
        
        
        switch (buttonType) {
            case YMLBarButtonTypeBack:
                [self setImage:[UIImage imageNameInBundle:@"ico_back2" withExtension:@"png"] forState:UIControlStateNormal];
                [self setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 4)];
                
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeStream:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_back" extension:@"png" topCap:0 leftCap:16 bottomCap:0 andRightCap:6] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"Stream", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
                
                width = 62;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeSolidStream:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_solidback" extension:@"png" topCap:0 leftCap:18 bottomCap:0 andRightCap:13] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"Stream", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 7, 0, 0)];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
                [self setTitleColor:[UIColor colorWith255Red:224 green:224 blue:224 alpha:1.0] forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWith255Red:224 green:224 blue:224 alpha:1.0] forState:UIControlStateHighlighted];
                
                width = 70;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeGradiantBack:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_back" extension:@"png" topCap:0 leftCap:16 bottomCap:0 andRightCap:6] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
                
                width = 60;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeGreenPlus:
                [self setImage:[UIImage imageNameInBundle:@"ico_chatplus" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeCircle:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_circle" extension:@"png" topCap:0 leftCap:18 bottomCap:0 andRightCap:13] forState:UIControlStateNormal];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
                [self setTitleColor:[UIColor colorWith255Red:224 green:224 blue:224 alpha:1.0] forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWith255Red:224 green:224 blue:224 alpha:1.0] forState:UIControlStateHighlighted];
                
                width = 39;
                height = 39;
                badgeMargin = CGPointMake(-3, 9);
                break;
                
                
            case YMLBarButtonTypeCircleBack:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_circle" extension:@"png" topCap:0 leftCap:18 bottomCap:0 andRightCap:13] forState:UIControlStateNormal];
                [self setImage:[UIImage imageNameInBundle:@"ico_back_white" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 39;
                height = 39;
                badgeMargin = CGPointMake(-3, 9);
                break;
                
            case YMLBarButtonTypeClose:
                [self setImage:[UIImage imageNameInBundle:@"ico_navclose" withExtension:@"png"] forState:UIControlStateNormal];
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeCancel:
//                [self setImage:[UIImage imageNameInBundle:@"ico_navclose" withExtension:@"png"] forState:UIControlStateNormal];
                [self setImage:[UIImage imageNameInBundle:@"ico_back2" withExtension:@"png"] forState:UIControlStateNormal];
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeMenu:
                [self setImage:[UIImage imageNameInBundle:@"ico_menu" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                
                badgeMargin = CGPointMake(-10, 12);
                break;
                
            case YMLBarButtonTypeSettings:
                [self setImage:[UIImage imageNameInBundle:@"ico_navsettings" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeSearch:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn" extension:@"png" topCap:5 leftCap:5 bottomCap:6 andRightCap:6] forState:UIControlStateNormal];
                [self setImage:[UIImage imageNameInBundle:@"ico_search" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeChat:
                [self setImage:[UIImage imageNameInBundle:@"ico_navchat" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                
                badgeMargin = CGPointMake(10, 12);
                break;
                
            case YMLBarButtonTypeRefresh:
                [self setImage:[UIImage imageNameInBundle:@"ico_refresh_big" withExtension:@"png"] forState:UIControlStateNormal];
                
                width = 44;
                height = 44;
                break;
                
            case YMLBarButtonTypeEmptyDone:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"bg_navbtndone" extension:@"png" topCap:0 leftCap:7 bottomCap:0 andRightCap:6] forState:UIControlStateNormal];
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"bg_navbtn" extension:@"png" topCap:0 leftCap:7 bottomCap:0 andRightCap:6] forState:UIControlStateDisabled];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
                
                width = 70;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeEmptyNormal:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"bg_navbtn" extension:@"png" topCap:0 leftCap:8 bottomCap:0 andRightCap:7] forState:UIControlStateNormal];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
                
                width = 70;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeEmptyLeftArrowed:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"navbtn_back" extension:@"png" topCap:0 leftCap:16 bottomCap:0 andRightCap:6] forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
                
                width = 70;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeEmptyBorder:
                [self setBackgroundImage:[UIImage stretchableImageWithName:@"bg_navbtn_border" extension:@"png" topCap:0 leftCap:8 bottomCap:0 andRightCap:7] forState:UIControlStateNormal];
                [[self titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
                [self setTitleColor:[UIColor colorWith255Red:94 green:99 blue:107 alpha:1.0] forState:UIControlStateNormal];
                
                width = 77;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            default:
                break;
        }
        
        if (isImageButton) {
            width = [self imageForState:UIControlStateNormal].size.width;
            height = [self imageForState:UIControlStateNormal].size.height;
        }
        
        y = (NAVIGATIONBAR_HEIGHT - height)/2.0;
        
        CGRect frame = CGRectMake(x, y, width, height);
        [self setFrame:frame];
        [self createBadgeButton];
    }
    
    return self;
}

- (id) initWithCustomView:(UIView *)customView {
    self = [super init];
    
    if (self) {
        float x, y, width, height, navBarShadow = 1.5, padding = 5.0;
        x = VIEW_FRAME.size.width - (customView.frame.size.width + padding);
        width = customView.frame.size.width;
        height = customView.frame.size.height;
        
        y = (NAVIGATIONBAR_HEIGHT - (height + navBarShadow))/2.0;
        
        CGRect viewFrame = CGRectMake(x, y, width, height);
        [self setFrame:viewFrame];
        
        [self addSubview:customView];
    }
    
    return self;
}


- (void) setBadgeAlignment:(YMLBarButtonBadgeAlignment)__badgeAlignment {
    badgeAlignment = __badgeAlignment;
    
    CGSize size = [badgeButton frame].size;
    
    CGFloat x = 0;
    if (badgeAlignment == YMLBarButtonBadgeAlignmentRight) {
        x = (self.width - size.width/2) + badgeMargin.x;
    }
    else {
        x = -(size.width/2);
        x += badgeMargin.x;
    }
    
    CGPoint origin = CGPointMake(x, (self.top - size.height/2) + badgeMargin.y);
    [badgeButton setFrame:(CGRect){.origin = origin, .size = size}];
}


#pragma mark - Private Methods

- (void) createBadgeButton {
    if (!badgeButton) {
        badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [badgeButton setFrame:(CGRect){.origin = CGPointMake((self.width - 9) + badgeMargin.x, (self.top - 9) + badgeMargin.y), .size = CGSizeMake(18, 19)}];
        [badgeButton setHidden:NO];        
        [badgeButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 1, 0, 0)];
        [badgeButton setTitleShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] forState:UIControlStateNormal];
        [[badgeButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
        [[badgeButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]];
        [badgeButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_notificationcount" extension:@"png" topCap:0 leftCap:8 bottomCap:0 andRightCap:9] forState:UIControlStateNormal];
        [badgeButton setImage:nil forState:UIControlStateNormal];
        [badgeButton setHidden:YES];
        [badgeButton setUserInteractionEnabled:NO];
        [self addSubview:badgeButton];
    }
}


#pragma mark - Public Methods

- (void) setHorizontalPadding:(CGFloat)padding {
    CGRect rect = [self frame];
    rect.size.width += (2 * padding);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [self setFrame:rect];
    [UIView commitAnimations];
}

- (void) setText:(NSString *)text {
    [self setTitle:text forState:UIControlStateNormal];
}

- (NSString *) text {
    return [self titleForState:UIControlStateNormal];
}

- (void) setBadgeNumber:(NSUInteger)number {
    if (number > 0) {
        [badgeButton setHidden:NO];
        
        NSString *countString = [NSString stringWithFormat:@"%d", number];
        
        CGSize size = [countString sizeWithFont:[[badgeButton titleLabel] font]];
        if (size.width + 10 > 18) {
            size = CGSizeMake(size.width + 10, 19);
            
            CGFloat x = 0;
            if (badgeAlignment == YMLBarButtonBadgeAlignmentRight) {
                x = (self.width - size.width/2) + badgeMargin.x;
            }
            else {
                x = -(size.width/2);
                x += badgeMargin.x;
            }
            
            CGPoint origin = CGPointMake(x, (self.top - size.height/2) + badgeMargin.y);
            
            [badgeButton setFrame:(CGRect){.origin = origin, .size = size}];
        }
        
        [badgeButton setTitle:countString forState:UIControlStateNormal];
    }
    else {
        [badgeButton setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
        [badgeButton setHidden:YES];
    }
}

- (void) setBadgeIcon:(UIImage *)icon {
    if (icon) {
        [badgeButton setHidden:NO];
    }
    else {
        [badgeButton setHidden:YES];
    }
    
    [badgeButton setImage:icon forState:UIControlStateNormal];
}

- (NSUInteger) badgeNumber {
    return [[badgeButton titleForState:UIControlStateNormal] intValue];
}


#pragma mark - Dealloc

- (void) dealloc {
    badgeButton = nil;
}


@end
