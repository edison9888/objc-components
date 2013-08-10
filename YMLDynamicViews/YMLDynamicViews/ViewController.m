//
//  ViewController.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/* 
 layout.sqlite
 
 CREATE TABLE controls(controlid varchar PRIMARY KEY, classname varchar);
 CREATE TABLE layouts(layoutid varchar PRIMARY KEY, controlid varchar, control_attributes varchar, foreign key(controlid) references controls(controlid));
 CREATE TABLE pages(pageid varchar PRIMARY KEY, layoutid varchar, foreign key(layoutid) references layouts(layoutid)); 
 
 data.sqlite
 
 */

#import "ViewController.h"
#import "YMLLayoutEngine.h"
#import "LayoutsViewController.h"

@interface ViewController () <LayoutsViewControllerDelegate> {
    YMLView *presentLayout;
}

- (void) chooseLayout;

@property (nonatomic, retain) YMLView *presentLayout;

@end

@implementation ViewController

@synthesize presentLayout;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(10, 10, 300, 30)];
    [button setTitle:@"Choose Layout" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(chooseLayout) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void) chooseLayout {
    LayoutsViewController *lvc = [[LayoutsViewController alloc] init];
    [lvc setDelegate:self];
    [self presentModalViewController:lvc animated:YES];
    [lvc release], lvc = nil;
}

- (void)layoutViewController:(LayoutsViewController *)layoutViewController didSelectLayoutId:(NSString *)layoutId {
    if (presentLayout) {
        if ([[presentLayout layoutId] isEqualToString:layoutId]) {
            return;
        }
        
        [presentLayout removeFromSuperview];
        [self setPresentLayout:nil];
    }
    
    YMLLayoutManager *layoutManager = [YMLLayoutManager layoutManager];
    
    YMLView *view = [layoutManager layoutForId:layoutId superView:[self view]];
    if (view) {
        [self setPresentLayout:view];
        
        [[self view] addSubview:presentLayout];
        
        UIImageView *imageView = (UIImageView *)[presentLayout viewWithTag:2];
        [imageView setImage:[UIImage imageNamed:@"image.jpg"]];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Dealloc

- (void)dealloc {
    [presentLayout release], presentLayout = nil;
    
    [super dealloc];
}

@end
