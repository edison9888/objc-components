//
//  AppDelegate.m
//  YMLHorizontalSliderViewController
//
//  Created by Karthik Keyan B on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "YMLExpandableViewController.h"
#import "YMLExpandableChildViewController.h"

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
    
    YMLExpandableChildViewController *VC1 = [[YMLExpandableChildViewController alloc] init];
    [[VC1 view] setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC2 = [[YMLExpandableChildViewController alloc] init];
    [[VC2 view] setBackgroundColor:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC3 = [[YMLExpandableChildViewController alloc] init];
    [[VC3 view] setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC4 = [[YMLExpandableChildViewController alloc] init];
    [[VC4 view] setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC5 = [[YMLExpandableChildViewController alloc] init];
    [[VC5 view] setBackgroundColor:[UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC6 = [[YMLExpandableChildViewController alloc] init];
    [[VC6 view] setBackgroundColor:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0]];
    
    YMLExpandableChildViewController *VC7 = [[YMLExpandableChildViewController alloc] init];
    [[VC7 view] setBackgroundColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]];
    
    
    YMLExpandableViewController *rootViewController = [[YMLExpandableViewController alloc] init];
    [rootViewController setChildViewControllers:[NSMutableArray arrayWithObjects:VC1, VC2, VC3, VC4, VC5, VC6, VC7, nil]];
    [[self window] setRootViewController:rootViewController];
    [rootViewController release], rootViewController = nil;
    
    
    [VC1 release], VC1 = nil;
    [VC2 release], VC2 = nil;
    [VC3 release], VC3 = nil;
    [VC4 release], VC4 = nil;
    [VC5 release], VC5 = nil;
    [VC6 release], VC6 = nil;
    [VC7 release], VC7 = nil;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
