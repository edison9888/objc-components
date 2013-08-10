//
//  ViewController.m
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "YMLColorPickerView.h"

@interface ViewController () <YMLColorPickerViewDelegate> {
    UIView *colorView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    colorView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    [[self view] addSubview:colorView];
    [colorView release];
	
    YMLColorPickerView *colorPickerView = [[YMLColorPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200)];
    [colorPickerView setDelegate:self];
    [[self view] addSubview:colorPickerView];
    [colorPickerView release], colorPickerView = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Color Picker Delegate

- (void) colorPicker:(YMLColorPickerView *)colorPicker didPickColor:(UIColor *)color {
    [colorView setBackgroundColor:color];
}


@end
