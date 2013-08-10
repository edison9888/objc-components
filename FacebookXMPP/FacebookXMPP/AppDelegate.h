//
//  AppDelegate.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {    
    NSString *password;
    
    UINavigationController *navController;
}

@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) UIWindow *window;

@end
