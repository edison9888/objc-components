//
//  AppDelegate.m
//  YMLTabBarComponent
//
//  Created by Sumit Mehra on 11/25/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "AppDelegate.h"

#import "YMLTabBarController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    UIImage *firstVCImage = [UIImage imageNamed:@"square_normal.png"];
    UIImage *firstVCImageActive = [UIImage imageNamed:@"square_pressed.png"];
    
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    UIImage *secondVCImage = [UIImage imageNamed:@"camera.png"];
    UIImage *secondVCImageActive = [UIImage imageNamed:@"camera.png"];
    
    ThirdViewController *thirdVC = [[ThirdViewController alloc] init];
    UIImage *thirdVCImage = [UIImage imageNamed:@"profile_normal.png"];
    UIImage *thirdVCImageActive = [UIImage imageNamed:@"profile_pressed.png"];
    
    YMLTabBarController *rootViewController = [[YMLTabBarController alloc] init];
    [rootViewController setViewControllers:[NSArray arrayWithObjects:firstVC, secondVC, thirdVC, nil]];
    [rootViewController setNormalStateImages:[NSArray arrayWithObjects:firstVCImage, secondVCImage, thirdVCImage, nil]];
    [rootViewController setActiveStateImages:[NSArray arrayWithObjects:firstVCImageActive, secondVCImageActive, thirdVCImageActive, nil]];
    [rootViewController setSelectedItemIndex:2];
    [[self window] setRootViewController:rootViewController];
    [rootViewController release];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
