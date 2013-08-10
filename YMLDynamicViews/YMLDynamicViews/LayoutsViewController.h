//
//  LayoutsViewController.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LayoutsViewControllerDelegate;

@interface LayoutsViewController : UIViewController {
    id<LayoutsViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<LayoutsViewControllerDelegate> delegate;

@end


@protocol LayoutsViewControllerDelegate <NSObject>

@optional
- (void) layoutViewController:(LayoutsViewController *)layoutViewController didSelectLayoutId:(NSString *)layoutId;

@end
