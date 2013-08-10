//
//  TUViewController.m
//  Tourean
//
//  Created by vivek Rajanna on 25/08/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation TUViewController

- (void) loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:VIEW_FRAME];
    [[rootView layer] setCornerRadius:5];
    [rootView setClipsToBounds:YES];
    [rootView setBackgroundColor:VIEW_BACKGROUND_COLOR];
    [self setView:rootView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - nullify

- (void) nullify {
    
}

- (void) dealloc {
    [self nullify];
}

@end
