//
//  YMLExpandableViewController.m
//  YMLExpandableViewController
//
//  Created by Karthik Keyan B on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLExpandableViewController.h"
#import "YMLExpandableChildViewController.h"
#import "YMLTouchableScrollView.h"

@interface YMLExpandableViewController () <YMLTouchableScrollViewDelegate>


@end

@implementation YMLExpandableViewController

@synthesize childViewControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) loadView {
    UIScrollView *rootView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    [rootView setBackgroundColor:[UIColor blackColor]];
    [rootView setShowsVerticalScrollIndicator:NO];
    [rootView setShowsHorizontalScrollIndicator:NO];
    [rootView setPagingEnabled:YES];
    [self setView:rootView];
    [rootView release], rootView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float titleBarWidth = self.view.bounds.size.width/[childViewControllers count];
    float maxX = ([childViewControllers count] - 1) * self.view.bounds.size.width;
    
    NSLog(@"%f", maxX);
    
    int j = [childViewControllers count] - 1;
    for (int i = 0; i < [childViewControllers count]; i++) {
        YMLExpandableChildViewController *childViewController = (YMLExpandableChildViewController *)[childViewControllers objectAtIndex:i];
        YMLTouchableScrollView *scrollView = (YMLTouchableScrollView *)[childViewController view];
        [scrollView setTouchDelegate:self];
        [scrollView setTag:(j + 1)];
        [scrollView setUserInteractionEnabled:YES];
//        [scrollView setFrame:CGRectMake((j * self.view.bounds.size.width), scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height)];
        [scrollView setFrame:CGRectMake(maxX - (i * titleBarWidth), scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height)];
        [[self view] addSubview:scrollView];
        
        j--;
    }
     
    [(UIScrollView *)[self view] setScrollEnabled:NO];
    [(UIScrollView *)[self view] setContentSize:CGSizeMake(self.view.bounds.size.width * [childViewControllers count], 0)];
    [(UIScrollView *)[self view] setContentOffset:CGPointMake(self.view.bounds.size.width * ([childViewControllers count] - 1), 0)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark - Touchable Scrollview Delegate

- (void) touchableScrollView:(YMLTouchableScrollView *)touchableScrollView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [(UIScrollView *)[self view] setScrollEnabled:YES];
    
    __block int touchedViewIndex = 0;
    
    [UIView animateWithDuration:0.4 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{ 
                         touchedViewIndex = [touchableScrollView tag] - 1;
                         
                         int j = [childViewControllers count] - 1;
                         for (int i = 0; i < [childViewControllers count]; i++) {
                             YMLExpandableChildViewController *childViewController = (YMLExpandableChildViewController *)[childViewControllers objectAtIndex:i];
                             YMLTouchableScrollView *scrollView = (YMLTouchableScrollView *)[childViewController view];
                             [scrollView setFrame:CGRectMake((j * self.view.bounds.size.width), scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height)];
                             j--;
                         }
                         
                         [(UIScrollView *)[self view] setContentOffset:CGPointMake(self.view.bounds.size.width * touchedViewIndex, 0)];
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark - Dealloc

- (void)dealloc {
    [childViewControllers release], childViewControllers = nil;
    
    [super dealloc];
}

@end
