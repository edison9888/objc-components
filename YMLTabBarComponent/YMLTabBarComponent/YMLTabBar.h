//
//  YMLTabBar.h
//  YMLTabBarComponent
//
//  Created by Sumit Mehra on 11/25/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YMLTabBarController;

@protocol YMLTabBarDelegate <NSObject>

@required
- (void) tabBarButtonTouchUpInsideWithButtonIndex:(int)selectedButtonIndex;

@optional
- (UIImage *) tabBarBackgroundImage;

@end


@interface YMLTabBar : UIView {
    UIImageView *tabBarBackgroundView;
    
    id<YMLTabBarDelegate> delegate;
    YMLTabBarController *tabBarController;
}

@property (nonatomic, retain) UIImageView *tabBarBackgroundView;
@property (nonatomic, assign) id<YMLTabBarDelegate> delegate;
@property (nonatomic, assign) YMLTabBarController *tabBarController;

- (id) initWithNumberOfViewControllers:(int)viewControllersCount tabBarButtonNormalStateImages:(NSArray *)normalStateImages tabBarButtonActiveStateImages:(NSArray *)activeStateImages frameSize:(CGRect)tabBarFrame andDelegate:(id<YMLTabBarDelegate>)newDelegate;
- (void) tabBarButtonTouchUpInside:(id)sender;
- (void) tabBarChangeButtonIndex:(int)newIndex;

@end
