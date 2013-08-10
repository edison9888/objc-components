//
//  LVRootViewController.m
//  TULocationView
//
//  Created by கார்த்திக் கேயன் on 6/22/13.
//  Copyright (c) 2013 கார்த்திக் கேயன். All rights reserved.
//

#import "LVRootViewController.h"
#import "TULocationView.h"

@interface LVRootViewController () <TULocationViewDelegate>

- (void) findLocation;

@end

@implementation LVRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:VIEW_FRAME];
    [rootView setBackgroundColor:[UIColor whiteColor]];
    [self setView:rootView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(10, self.view.innerHeight - 40, self.view.innerWidth - 20, 30)];
    [button setTitle:@"Find Location" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(findLocation) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) findLocation {
    [SpinnerHandler startSpinnerOnView:[self view]];
    
    __weak typeof(self) weakSelf = self;
    [[LocationManager sharedInstance] findMyLocationWithDetails:^(BOOL success, CLLocation *location, NSString *displayname) {
        LVRootViewController *strongSelf = weakSelf;
        
        if (strongSelf) {
            [SpinnerHandler stopSpinnerOnView:[strongSelf view]];
            if (success) {
                TULocationView *fsLocationView = [[TULocationView alloc] initWithFrame:[[strongSelf view] bounds] coordinate:[location coordinate]];
                [fsLocationView setDelegate:strongSelf];
                [fsLocationView setAlpha:0.0];
                [[weakSelf view] addSubview:fsLocationView];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [fsLocationView setAlpha:1.0];
                [UIView commitAnimations];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location View"
                                                                    message:@"Oops. Something went wrong. Please try again."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

#pragma mark - Location View Delegate

- (void) locationView:(TULocationView *)locationView didSelectLocation:(NSDictionary *)location {
    NSLog(@"%@", location);
    
    [locationView hide];
}

- (void) locationViewCancelled:(TULocationView *)locationView {
    [locationView hide];
}

@end
