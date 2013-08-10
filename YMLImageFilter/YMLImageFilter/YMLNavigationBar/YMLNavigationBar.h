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

#define NAVIGATIONBAR_BG_COLOR                      [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]
#define NAVIGATIONBAR_TITLE_FONT                    [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]
//#define NAVIGATIONBAR_TITLE_FONT_COLOR              [UIColor colorWithRed:176.0/255.0 green:178.0/255.0 blue:179.0/255.0 alpha:1.0]
#define NAVIGATIONBAR_TITLE_FONT_COLOR              [UIColor colorWithRed:94.0/255.0 green:99.0/255.0 blue:107.0/255.0 alpha:1.0]
#define NAVIGATIONBAR_TITLE_SHADOW_COLOR            [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75]

@protocol YMLNavigationBarDelegate;

@interface YMLNavigationBar : UIView {
    UILabel *titleLabel;
    UIImageView *backgroundImageView, *titleImage;
    YMLBarButton * leftBarButton, * rightBarButton;
    
    __weak id<YMLNavigationBarDelegate> delegate;
}

@property (nonatomic, readwrite) BOOL actAsBarButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *backgroundImageView, *titleImage;
@property (nonatomic, retain) YMLBarButton *leftBarButton, *rightBarButton;
@property (nonatomic,  weak) id<YMLNavigationBarDelegate> delegate;

- (void) setLeftBarButton:(YMLBarButton *)_leftBarButton withMargin:(int)margin;
- (void) setRightBarButton:(YMLBarButton *)_rightBarButton withMargin:(int)margin;

- (NSString *) title;
- (void) setTitle:(NSString *)title;
- (void) setTitleColor:(UIColor *)titleColor;
- (void) setImage:(UIImage *)image;
- (void) setBackgroundImage:(UIImage *)backgroundImage;
- (void) setDefaultBackground;
- (void) setControlsMargin:(CGPoint)margin;

@end


@protocol YMLNavigationBarDelegate <NSObject>

@optional
- (void) navigationBarDidTapped:(YMLNavigationBar *)navigationBar;

@end
