//
//  YMLTabBarController.h
//  YMLTabBarComponent
//
//  Created by Sumit Mehra on 11/25/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLTabBar.h"

@interface YMLTabBarController : UIViewController <YMLTabBarDelegate> {
    int selectedItemIndex;
    
    NSArray *viewControllers, *normalStateImages, *activeStateImages;
    
    UIViewController *selectedViewController;
    
    YMLTabBar *tabBar;
    
@private
    UIView *contentView;
    CGRect rootViewFrame;
}

@property (nonatomic, assign) int selectedItemIndex;
@property (nonatomic, retain) NSArray *viewControllers, *normalStateImages, *activeStateImages;
@property (nonatomic, readonly) UIViewController *selectedViewController;
@property (nonatomic, readonly) YMLTabBar *tabBar;

@end
