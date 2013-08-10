//
//  ViewController.m
//  test
//
//  Created by Karthik Keyan B on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "YMLArrangeableScrollView.h"

@interface ViewController () <YMLArrangeableScrollViewDataSource, YMLArrangeableScrollViewDelegate> {
    YMLArrangeableScrollView *scrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    scrollView = [[YMLArrangeableScrollView alloc] initWithFrame:[[self view] bounds]];
    [scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [scrollView setDelegate:self];
    [scrollView setDataSource:self];
    [scrollView reload];
    [[self view] addSubview:scrollView];
    [scrollView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (!scrollView) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
            [scrollView setHorizontal:YES];
        }
        else {
            [scrollView setHorizontal:NO];
        }
    }];
}


#pragma mark - Delegate

- (NSUInteger) numberOfSubViewsInScrollView:(YMLArrangeableScrollView *)scrollView {
    return 12;
}

- (UIView *) scrollView:(YMLArrangeableScrollView *)scrollView subViewAtIndex:(NSUInteger)index {
    YMLThumbView *view = [[[YMLThumbView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
    [view setBackgroundColor:[UIColor blackColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[NSString stringWithFormat:@"%d", index]];
    [label setTextAlignment:UITextAlignmentCenter];
    [view addSubview:label];
    [label release], label = nil;
    
    return view;
}

- (CGSize) scrollView:(YMLArrangeableScrollView *)scrollView subViewsSizeInHorizontalLayout:(BOOL)isHorizontalLayout {
    CGSize size = CGSizeMake(80, 100);
    if (isHorizontalLayout) {
        size = CGSizeMake(80, 100);
    }
    
    return size;
}

- (CGFloat) scrollView:(YMLArrangeableScrollView *)scrollView verticalSpaceInHorizontalLayout:(BOOL)isHorizontalLayout {    
    return 40;
}

- (CGFloat) scrollView:(YMLArrangeableScrollView *)scrollView horizontalSpaceInHorizontalLayout:(BOOL)isHorizontalLayout {
    if (isHorizontalLayout) {
        return 40;
    }
    
    return 20;
}

@end
