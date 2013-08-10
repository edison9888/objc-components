//
//  TUNavigationViewController.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/2/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUViewController.h"
#import "YMLNavigationBar.h"

@interface TUNavigationViewController : TUViewController <YMLNavigationBarDelegate> {
    YMLNavigationBar *navigationBar;
}

@property (nonatomic, readonly) YMLNavigationBar *navigationBar;

- (void) UISetupNavigationBar;

- (void) back;

@end
