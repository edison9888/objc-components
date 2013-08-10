//
//  TULocationView.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/19/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUUsersTableViewCell.h"
#import "YMLNavigationBar.h"
#import "LocationManager.h"
#import "TULocationView.h"

#import <QuartzCore/QuartzCore.h>

@interface TULocationView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    CLLocationCoordinate2D coordinate;
    
    NSArray *locations;
    
    UITableView *locationTableView;
    UITextField *txtNewLocation;
    UIImageView *inputView;
    UIView *inputOverlayView;
    YMLBarButton *addNewButton, *cancelButton, *doneButton;
    YMLNavigationBar *navigationBar;
}

@property (nonatomic, strong) NSArray *locations;

- (void) UICreateNavigationBar;
- (void) UICreateInputView;
- (void) cancel;
- (void) addNew;
- (void) done;

@end

@implementation TULocationView

@synthesize locations;
@synthesize delegate;

/*

    {
        category = "Comedy Club";
        distance = 94;
        icon = "https://foursquare.com/img/categories/arts_entertainment/comedyclub.png";
        id = 4adce812f964a5206a6221e3;
        latitude = "51.51010800267787";
        longitude = "-0.13235092163085938";
        name = "The Comedy Store";
    }

*/

- (id) initWithFrame:(CGRect)frame coordinate:(CLLocationCoordinate2D)_coordinate {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        coordinate = _coordinate;
        
        locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
        [locationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [locationTableView setDelegate:self];
        [locationTableView setDataSource:self];
//        [locationTableView setBackgroundColor:CLEAR_COLOR];
        [locationTableView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:locationTableView];
        
        [self UICreateInputView];
        [self UICreateNavigationBar];
        
        [SpinnerHandler startSpinnerOnView:self];
        typeof(self) __weak weakSelf = self;
        [[LocationManager sharedInstance] findFourSquarePlaces:coordinate callBackOn:^(BOOL success, NSArray *places) {
            TULocationView *strongSelf = weakSelf;
            if (strongSelf) {
                [SpinnerHandler stopSpinnerOnView:strongSelf];
                if (success) {
                    [strongSelf setLocations:places];
                    [strongSelf->locationTableView reloadData];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location View"
                                                                        message:@"Oops. Somthing went wrong. Please try again."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }];
    }
    return self;
}


- (void) UICreateNavigationBar {
    navigationBar = [[YMLNavigationBar alloc] initWithFrame:CGRectZero];
    [navigationBar setTitle:NSLocalizedString(@"Places", @"")];
    [self addSubview:navigationBar];
    
    cancelButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeCancel];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setLeftBarButton:cancelButton withMargin:1];
    
    addNewButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeGreenPlus];
    [addNewButton addTarget:self action:@selector(addNew) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setRightBarButton:addNewButton];
    
    doneButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeEmptyDone];
    [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
}

- (void) UICreateInputView {
    inputOverlayView = [[UIView alloc] initWithFrame:[self bounds]];
    [inputOverlayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    [inputOverlayView setAlpha:0.0];
    [self addSubview:inputOverlayView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [inputOverlayView addGestureRecognizer:tapGesture];
    
    
    inputView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.innerHeight, self.innerWidth, 45)];
    [inputView setImage:[UIImage stretchableImageWithName:@"bg_inputview" extension:@"png" topCap:1 leftCap:0 bottomCap:39 andRightCap:0]];
    [[inputView layer] setShadowOffset:CGSizeMake(0, -1)];
    [[inputView layer] setShadowOpacity:0.3];
    [inputView setUserInteractionEnabled:YES];
    [self addSubview:inputView];
    
    
    UIImageView *txtBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7, (inputView.innerWidth - 24), 30)];
    [txtBackgroundView setImage:[UIImage stretchableImageWithName:@"bg_searchtext" extension:@"png" topCap:7 leftCap:7 bottomCap:8 andRightCap:8]];
    [txtBackgroundView setUserInteractionEnabled:YES];
    [inputView addSubview:txtBackgroundView];
    
    
    txtNewLocation = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, (txtBackgroundView.innerWidth - 20), 26)];
    [txtNewLocation setDelegate:self];
    [txtNewLocation setBackgroundColor:CLEAR_COLOR];
    [txtNewLocation setBorderStyle:UITextBorderStyleNone];
    [txtNewLocation setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    [txtNewLocation setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    [txtNewLocation setTextColor:[UIColor colorWith255Red:178 green:178 blue:178 alpha:1.0]];
    [txtNewLocation setTextColor:[UIColor blackColor]];
    [txtNewLocation setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [txtNewLocation setAutocorrectionType:UITextAutocorrectionTypeYes];
    [txtNewLocation setReturnKeyType:UIReturnKeyDone];
    [txtNewLocation setKeyboardType:UIKeyboardTypeASCIICapable];
    [txtNewLocation setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtBackgroundView addSubview:txtNewLocation];
    
//    CALayer *topLine = [CALayer layer];
//    [topLine setFrame:CGRectMake(0, 0, inputView.innerWidth, 1)];
//    [topLine setBackgroundColor:[[UIColor colorWith255Red:198 green:198 blue:198 alpha:1.0] CGColor]];
//    [[inputView layer] addSublayer:topLine];
}


#pragma mark - TableView Data Source Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locations count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[TUUsersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell setBackgroundLayerColor:[[UIColor whiteColor] CGColor]];
    }
    
    NSDictionary *dict = [locations objectAtIndex:[indexPath row]];
    
    [cell setIndexPath:indexPath];
    [cell setName:[dict objectForKey:@"name"]];
    [cell setEnableAccessoryView:YES];
    [cell setHideFollowButton:YES];
    [cell setEnableFollowButton:NO];
    
    // Use your own asynch image download logic
    // get image url from : [dict objectForKey:@"icon"]
    // NSString *imageURL = [dict objectForKey:@"icon"];
    [cell setProfileImage:[UIImage imageNameInBundle:@"img_location_placeholder" withExtension:@"png"]];
    
    return cell;
}


#pragma mark - TableView Delegate Methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([txtNewLocation isFirstResponder]) {
        [txtNewLocation resignFirstResponder];
    }
    else {
        if (delegate && [delegate respondsToSelector:@selector(locationView:didSelectLocation:)]) {
            [delegate locationView:self didSelectLocation:[locations objectAtIndex:[indexPath row]]];
        }
    }
}


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [navigationBar setHidden:NO];
}


#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         TULocationView *strongSelf = weakSelf;
                         
                         if (strongSelf) {
                             CGRect rect = [strongSelf->inputView frame];
                             rect.origin.y = [strongSelf innerHeight] - (216 + strongSelf->inputView.height);
                             [strongSelf->inputView setFrame:rect];
                             [strongSelf->inputOverlayView setAlpha:1.0];
                         }
                     }
                     completion:nil];
    
    return YES;
}

//- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([string isEqualToString:@""]) {
//        return YES;
//    }
//    
//    if (([[textField text] length] + [string length]) > 40) {
//        return NO;
//    }
//    
//    return YES;
//}


- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         TULocationView *strongSelf = weakSelf;
                         if (strongSelf) {
                             CGRect rect = [strongSelf->inputView frame];
                             rect.origin.y = [strongSelf innerHeight];
                             [strongSelf->inputView setFrame:rect];
                             [strongSelf->inputOverlayView setAlpha:0.0];
                         }
                     }
                     completion:nil];
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self done];
    
    return YES;
}


#pragma mark - Public Methods

- (void) hide {
    typeof(self) __weak weakSelf = self;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         TULocationView *strongSelf = weakSelf;
                         if (strongSelf) {
                             [strongSelf setAlpha:0.0];
                         }
                     }
                     completion:^(BOOL finished) {
                         TULocationView *strongSelf = weakSelf;
                         if (strongSelf) {
                             [strongSelf removeFromSuperview];
                         }
                     }];
}

- (void) cancel {
    if ([txtNewLocation isFirstResponder]) {
        [txtNewLocation setText:@""];
        [navigationBar setLeftBarButton:nil];
        [navigationBar setRightBarButton:nil];
        
        [navigationBar setLeftBarButton:cancelButton withMargin:1];
        [navigationBar setRightBarButton:addNewButton];
        
        [txtNewLocation resignFirstResponder];
    }
    else {
        [self hide];
        
        if (delegate && [delegate respondsToSelector:@selector(locationViewCancelled:)]) {
            [delegate locationViewCancelled:self];
        }
    }
}

- (void) addNew {
    [navigationBar setRightBarButton:nil];
    [navigationBar setRightBarButton:doneButton];
    
    [txtNewLocation becomeFirstResponder];
}

- (void) done {
    if ([txtNewLocation text]) {
        NSDictionary *placesDict = @{
                                        @"name":[txtNewLocation text],
                                        @"latitude":[NSString stringWithFormat:@"%f", coordinate.latitude],
                                        @"longitude":[NSString stringWithFormat:@"%f", coordinate.longitude]
                                     };
        
        if (delegate && [delegate respondsToSelector:@selector(locationView:didSelectLocation:)]) {
            [delegate locationView:self didSelectLocation:placesDict];
        }
    }
    
    [txtNewLocation setText:@""];
    [navigationBar setLeftBarButton:nil];
    [navigationBar setRightBarButton:nil];
    
    [navigationBar setLeftBarButton:cancelButton withMargin:1];
    [navigationBar setRightBarButton:addNewButton];
}


#pragma mark - Dealloc

- (void) dealloc {
    [self setLocations:nil];
    
    locationTableView = nil;
    txtNewLocation = nil;
    inputView = nil;
    inputOverlayView = nil;
    addNewButton = nil;
    cancelButton = nil;
    doneButton = nil;
    navigationBar = nil;
    
    [SpinnerHandler stopSpinnerOnView:self];
}

@end
