//
//  YMLExpandableViewController.h
//  YMLExpandableViewController
//
//  Created by Karthik Keyan B on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMLExpandableViewController : UIViewController {
    NSMutableArray *childViewControllers;
}

@property (nonatomic, retain) NSMutableArray *childViewControllers;

@end
