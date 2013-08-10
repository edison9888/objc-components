//
//  BuddyListViewController.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPHandler.h"

@interface BuddyListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, XMPPHandlerChatDelegate, XMPPHandlerBuddyDelegate> {
    NSMutableArray *buddys;
    
    UITableView *buddyListTableView;
}

@property (nonatomic, retain) NSMutableArray *buddys;
@property (nonatomic, retain) UITableView *buddyListTableView;

@end
