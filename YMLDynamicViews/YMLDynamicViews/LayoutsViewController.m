//
//  LayoutsViewController.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayoutsViewController.h"
#import "iCarousel.h"

@interface LayoutsViewController () <iCarouselDelegate, iCarouselDataSource>

@end

@implementation LayoutsViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self setView:rootView];
    [rootView release], rootView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:[[self view] bounds]];
    [carousel setType:iCarouselTypeCoverFlow];
    [carousel setDecelerationRate:0.35];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [[self view] addSubview:carousel];
    [carousel release], carousel = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Carousel Datasource

- (NSUInteger) numberOfItemsInCarousel:(iCarousel *)carousel {
    return 2;
}

- (NSUInteger) numberOfVisibleItemsInCarousel:(iCarousel *)carousel {
    return 2;
}

- (CGFloat) carouselItemWidth:(iCarousel *)carousel {
    return 320;
}

- (CGFloat) carouselOffsetMultiplier:(iCarousel *)carousel {
    return 0.5f;
}

- (UIView *) carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 400)];
    }
    
    [(UIImageView *)view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"layout%d.png", (index + 1)]]];
    
    return view;
}


#pragma mark - Carousel Delegate

- (void) carousel:(iCarousel *)carousel didFinishedAnimationWithCurrentIndex:(NSInteger)currentItemIndex {
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if ([delegate respondsToSelector:@selector(layoutViewController:didSelectLayoutId:)]) {
        [delegate layoutViewController:self didSelectLayoutId:[NSString stringWithFormat:@"%d", (index + 1)]];
    }
}

@end
