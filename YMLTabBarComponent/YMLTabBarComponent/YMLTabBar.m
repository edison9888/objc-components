//
//  YMLTabBar.m
//  YMLTabBarComponent
//
//  Created by Sumit Mehra on 11/25/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "YMLTabBar.h"
#import "YMLTabBarController.h"

#define TAB_BAR_BUTTON_TAG   100000

@implementation YMLTabBar

@synthesize tabBarBackgroundView;
@synthesize delegate;
@synthesize tabBarController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithNumberOfViewControllers:(int)viewControllersCount tabBarButtonNormalStateImages:(NSArray *)normalStateImages tabBarButtonActiveStateImages:(NSArray *)activeStateImages frameSize:(CGRect)tabBarFrame andDelegate:(id<YMLTabBarDelegate>)newDelegate {
    
    self = [super initWithFrame:tabBarFrame];
    if (self) {
        delegate = newDelegate;
        
        
        //Background Image View
        UIImage *backgroundImage = [newDelegate tabBarBackgroundImage];
        tabBarBackgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [tabBarBackgroundView setImage:backgroundImage];
        [self addSubview:tabBarBackgroundView];
        
        
        //Buttons For TabBar
        int buttonWidth = tabBarFrame.size.width/viewControllersCount;
        int buttonHeight = tabBarFrame.size.height;
        
        for (int i = 0; i < viewControllersCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:TAB_BAR_BUTTON_TAG + i];
            [button setFrame:CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight)];
            [button setImage:[normalStateImages objectAtIndex:i] forState:UIControlStateNormal];
            [button setImage:[activeStateImages objectAtIndex:i] forState:UIControlStateHighlighted];            
            [button addTarget:self action:@selector(tabBarButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Tab Bar Button Pressed

- (void) tabBarButtonTouchUpInside:(id)sender {
    int previousIndex = [tabBarController selectedItemIndex];
    int selectedIndex = [sender tag] - TAB_BAR_BUTTON_TAG;
    
    if (previousIndex != selectedIndex) {
        UIButton *btnPrevious = (UIButton *) [self viewWithTag:(TAB_BAR_BUTTON_TAG + previousIndex)];
        [btnPrevious setImage:[[tabBarController normalStateImages] objectAtIndex:previousIndex] forState:UIControlStateNormal];
        
        UIButton *btnSelected = (UIButton *) [self viewWithTag:(TAB_BAR_BUTTON_TAG + selectedIndex)];
        [btnSelected setImage:[[tabBarController activeStateImages] objectAtIndex:selectedIndex] forState:UIControlStateNormal];
        
        [delegate tabBarButtonTouchUpInsideWithButtonIndex:selectedIndex]; 
    }
}


#pragma mark - Public Methods

- (void) tabBarChangeButtonIndex:(int)newIndex {
    int previousIndex = [tabBarController selectedItemIndex];
    
    UIButton *btnPrevious = (UIButton *) [self viewWithTag:(TAB_BAR_BUTTON_TAG + previousIndex)];
    [btnPrevious setImage:[[tabBarController normalStateImages] objectAtIndex:previousIndex] forState:UIControlStateNormal];
    
    UIButton *btnSelected = (UIButton *) [self viewWithTag:(TAB_BAR_BUTTON_TAG + newIndex)];
    [btnSelected setImage:[[tabBarController activeStateImages] objectAtIndex:newIndex] forState:UIControlStateNormal];
    
    [delegate tabBarButtonTouchUpInsideWithButtonIndex:newIndex];
}


#pragma mark - Dealloc

- (void)dealloc {
    [tabBarBackgroundView release], tabBarBackgroundView = nil;
    
    [super dealloc];
}

@end
