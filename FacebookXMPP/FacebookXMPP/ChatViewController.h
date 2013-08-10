//
//  ChatViewController.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPHandler.h"

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, XMPPHandlerChatDelegate> {
    NSString *friendID;
    NSString *friendName;
    NSMutableArray *chatMessages;
    
    UITableView *chatTableView;
    UITextField *txtMessage;
    UIButton *sendMessageButton;
    UIView *inputView;
}

@property (nonatomic, copy) NSString *friendID, *friendName;
@property (nonatomic, retain) NSMutableArray *chatMessages;

@end
