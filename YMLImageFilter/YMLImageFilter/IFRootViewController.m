//
//  IFRootViewController.m
//  YMLImageFilter
//
//  Created by கார்த்திக் கேயன் on 6/22/13.
//  Copyright (c) 2013 கார்த்திக் கேயன். All rights reserved.
//

#import "IFRootViewController.h"
#import "YMLImagePickerController.h"

@interface IFRootViewController () <YMLImagePickerDelegate> {
    UIImageView *imageView;
}

- (void) openImagePicker;

@end

@implementation IFRootViewController

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
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.innerWidth - TU_IMAGE_SIZE.width) * 0.5, (self.view.innerHeight - TU_IMAGE_SIZE.height) * 0.5, TU_IMAGE_SIZE.width, TU_IMAGE_SIZE.height)];
    [[self view] addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(10, self.view.innerHeight - 40, self.view.innerWidth - 20, 30)];
    [button setTitle:@"Open Camera" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openImagePicker) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void) openImagePicker {
    YMLImagePickerController *imagePickerController = [[YMLImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerController setIsImagePickerOnly:YES];
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - YMLImagePicker Delegate

- (void)imagePickerController:(YMLImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [imageView setImage:[UIImage imageWithData:info[@"data"]]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(YMLImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
