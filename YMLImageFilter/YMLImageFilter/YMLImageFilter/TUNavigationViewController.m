//
//  TUNavigationViewController.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/2/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUNavigationViewController.h"

@interface TUNavigationViewController ()

@end

@implementation TUNavigationViewController

@synthesize navigationBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    navigationBar = [[YMLNavigationBar alloc] initWithFrame:CGRectMake(0, 0, VIEW_FRAME.size.width, NAVIGATIONBAR_HEIGHT)];
    [navigationBar setDelegate:self];
    [[self view] addSubview:navigationBar];
    
    CGRect rect = [[navigationBar titleLabel] frame];
    rect.origin.y -= 2;
    [[navigationBar titleLabel] setFrame:rect];
    
    [self UISetupNavigationBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self view] bringSubviewToFront:navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIMethods

- (void) UISetupNavigationBar {
    [navigationBar setImage:[UIImage imageNameInBundle:@"img_navbarlogo" withExtension:@"png"]];
}


#pragma mark - Public Methods

- (void) back {
    if ([self navigationController]) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Navigation Bar Delegate

- (void) navigationBarDidTapped:(YMLNavigationBar *)navigationBar {
    //
}


#pragma mark - Dealloc

- (void) nullify {
    navigationBar = nil;
    
    [super nullify];
}

- (void) dealloc {
    [self nullify];
}

@end
