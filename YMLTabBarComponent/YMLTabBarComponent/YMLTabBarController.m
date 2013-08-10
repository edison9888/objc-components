//
//  YMLTabBarController.m
//  YMLTabBarComponent
//
//  Created by Sumit Mehra on 11/25/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "YMLTabBarController.h"
#import "YMLTabBar.h"

@implementation YMLTabBarController

@synthesize viewControllers, normalStateImages, activeStateImages;
@synthesize selectedViewController;
@synthesize selectedItemIndex;
@synthesize tabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedItemIndex = 0;
    }
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        selectedItemIndex = 0;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    rootViewFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *rootView = [[UIView alloc] initWithFrame:rootViewFrame];
    [self setView:rootView];
    [rootView release], rootView = nil;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tabBar = [[YMLTabBar alloc] initWithNumberOfViewControllers:[viewControllers count] 
                          tabBarButtonNormalStateImages:normalStateImages 
                       tabBarButtonActiveStateImages:activeStateImages 
                                              frameSize:CGRectMake(0, (self.view.frame.size.height - 49), self.view.frame.size.width, 49) 
                                            andDelegate:self];
    [tabBar setDelegate:self];
    [tabBar setTabBarController:self];
    [tabBar tabBarChangeButtonIndex:selectedItemIndex];
    [[self view] addSubview:tabBar];
    [tabBar release];
    
    
    //Content View where the view controller's view is going to display
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rootViewFrame.size.width, (rootViewFrame.size.height - tabBar.frame.size.height))];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:contentView];
    [contentView release];
    
    
    //Add First View controller's view to content view
    selectedViewController = [viewControllers objectAtIndex:selectedItemIndex];
    [[selectedViewController view] setFrame:[contentView bounds]];
    [contentView addSubview:[selectedViewController view]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Setter Methods

- (void) setSelectedItemIndex:(int)newIndex {
    [tabBar tabBarChangeButtonIndex:newIndex];
    
    selectedItemIndex = newIndex;
}

- (void) setViewControllers:(NSArray *)newViewControllers {
    [newViewControllers retain];
    [viewControllers release];
    viewControllers = newViewControllers;
}


#pragma mark - Tab Bar Delegate

- (void)tabBarButtonTouchUpInsideWithButtonIndex:(int)selectedButtonIndex {
    [[selectedViewController view] removeFromSuperview];
    
    selectedItemIndex = selectedButtonIndex;
    
    selectedViewController = [viewControllers objectAtIndex:selectedItemIndex];
    [[selectedViewController view] setFrame:[contentView bounds]];    
    
    [contentView addSubview:[selectedViewController view]];
}

- (UIImage *)tabBarBackgroundImage {
    static UIImage *image = nil;
    
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bottombar" ofType:@"png"]];
    }
    
    return image;
}


#pragma mark - Deallo

- (void)dealloc {
    if (viewControllers) { [viewControllers release]; }
    viewControllers = nil;
    
    if (normalStateImages) { [normalStateImages release]; }
    normalStateImages = nil;
    
    if (activeStateImages) { [activeStateImages release]; }
    activeStateImages = nil;
    
    selectedViewController = nil;
    
    tabBar = nil;
    
    [super dealloc];
}


@end
