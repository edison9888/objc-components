//
//  NavigationBar.h
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//


//Custom NavigationBar - just a UIView
//It is just uiview with BarButton, image and title label added
//User BarButton to add left and right bar buttons


#import <UIKit/UIKit.h>
#import "YMLBarButton.h"

#define NAVIGATIONBAR_TITLE_FONT                    [UIFont fontWithName:@"Archer-Bold" size:24.0]
#define NAVIGATIONBAR_TITLE_FONT_COLOR              [UIColor colorWithRed:135.0/255.0 green:130.0/255.0 blue:123.0/255.0 alpha:1.0]
#define NAVIGATIONBAR_TITLE_SHADOW_COLOR            [UIColor whiteColor]

@interface YMLNavigationBar : UIView {
    UILabel *titleLabel;
    UIImageView *backgroundImageView, *titleImage;
    YMLBarButton * leftBarButton, * rightBarButton;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *backgroundImageView, *titleImage;
@property (nonatomic, retain) YMLBarButton *leftBarButton, *rightBarButton;

- (NSString *) title;
- (void) setTitle:(NSString *)title;
- (void) setTitleColor:(UIColor *)titleColor;
- (void) setImage:(UIImage *)image;
- (void) setBackgroundImage:(UIImage *)backgroundImage;
- (void) setShowTitleShadow:(BOOL)shadow;
- (void) setDefaultBackground;

@end
