//
//  LoginViewController.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "XMPPHandler.h"

@interface LoginViewController : UIViewController<FBSessionDelegate, FBRequestDelegate, XMPPHandlerConnectionDelegate> {
    UITextField *txtUserName, *txtPassword;
    UIButton *loginButton;
    
    Facebook *facebook;
}

@end
