//
//  YMLExpandableChildViewController.m
//  YMLExpandableViewController
//
//  Created by Karthik Keyan B on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLExpandableChildViewController.h"
#import "YMLTouchableScrollView.h"

@interface YMLExpandableChildViewController ()

@end

@implementation YMLExpandableChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    YMLTouchableScrollView *rootView = [[YMLTouchableScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    [rootView setShowsVerticalScrollIndicator:NO];
    [rootView setShowsHorizontalScrollIndicator:NO];
    [self setView:rootView];
    [rootView release], rootView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
