//
//  BarButton.m
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLBarButton.h"

@implementation YMLBarButton

- (id) init {    
    return [self initWithBarButtonType:YMLBarButtonTypeNone];
}

- (id) initWithFrame:(CGRect)frame {
    return [self initWithBarButtonType:YMLBarButtonTypeNone];
}

- (id) initWithBarButtonType:(YMLBarButtonType)buttonType {
    self = [super initWithFrame:CGRectZero];
    
    float margin = 10.0, x = margin, y = 0, width = 0, height = 0;
    BOOL isImageButton = NO;
    
    if (self) {
        [[self titleLabel] setFont:BARBUTTON_TITLE_FONT];
        [self setTitleColor:BARBUTTON_TITLE_COLOR forState:UIControlStateNormal];
        [self setTitleColor:BARBUTTON_TITLE_COLOR forState:UIControlStateHighlighted];
        [self setTitleShadowColor:BARBUTTON_TITLE_SHADOW_COLOR forState:UIControlStateNormal];
        [self setTitleShadowColor:BARBUTTON_TITLE_SHADOW_COLOR forState:UIControlStateHighlighted];
        [[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        
        
        switch (buttonType) {
            case YMLBarButtonTypeBack:
                [self setBackgroundImage:[self stretchableImageWithName:@"navbtn_left" extension:@"png" topCap:0 leftCap:17 bottomCap:0 andRightCap:14] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"back", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(4, 6, 0, 0)];
                
                width = 60;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeClose:
                [self setBackgroundImage:[self stretchableImageWithName:@"bg_navbtn" extension:@"png" topCap:0 leftCap:10 bottomCap:0 andRightCap:16] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"close", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 4, 0, 0)];
                
                width = 60;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeCancel:
                [self setBackgroundImage:[self stretchableImageWithName:@"bg_navbtn" extension:@"png" topCap:0 leftCap:10 bottomCap:0 andRightCap:16] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
                [self setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
                
                width = 70;
                height = [self backgroundImageForState:UIControlStateNormal].size.height;
                break;
                
            case YMLBarButtonTypeDone:
                break;
                
            case YMLBarButtonTypeNext:
                break;
                
            case YMLBarButtonTypePrevious:
                break;
                
            case YMLBarButtonTypeSave:
                [self setBackgroundImage:[self stretchableImageWithName:@"bg_navbtn" extension:@"png" topCap:0 leftCap:10 bottomCap:0 andRightCap:16] forState:UIControlStateNormal];
                [self setTitle:NSLocalizedString(@"save", @"") forState:UIControlStateNormal];
                
                width = 58;
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

- (void) setHorizontalPadding:(CGFloat)padding {
    CGRect rect = [self frame];
    rect.size.width += (2 * padding);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [self setFrame:rect];
    [UIView commitAnimations];
}


#pragma mark - Dealloc


@end
