//
//  LoginViewController.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "BuddyListViewController.h"
#import "FriendsList.h"


@interface LoginViewController () 

- (void) login:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self setView:rootView];
    [rootView release];
}


- (void)dealloc {
    if (facebook) { [facebook release]; }
    facebook = nil;
    [super dealloc];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Login"];
    
    txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 31)];
    [txtUserName setPlaceholder:@"User Name"];
    [txtUserName setBorderStyle:UITextBorderStyleRoundedRect];
    [txtUserName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtUserName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [txtUserName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [[self view] addSubview:txtUserName];
    [txtUserName release];
    
    
    txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(10, 55, 300, 31)];
    [txtPassword setPlaceholder:@"********"];
    [txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
    [txtPassword setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [txtPassword setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [txtPassword setSecureTextEntry:YES];
    [[self view] addSubview:txtPassword];
    [txtPassword release];
    
    
    loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setFrame:CGRectMake(10, 100, 300, 41)];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:loginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[XMPPHandler sharedInstance] setConnectionDelegate:self];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) login:(id)sender {        
    [txtUserName resignFirstResponder];
    [txtPassword resignFirstResponder];
    
//    if ([[txtPassword text] isEqualToString:(NSString *)[NSNull null]] || [[txtPassword text] length] == 0) {
//        return;
//    }
    
    facebook = [[Facebook alloc] initWithAppId:FacebookKey andDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:FacebookLoginNotificationKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSURL *url = (NSURL *)[notification object];
        [facebook handleOpenURL:url];
    }];
    
    [facebook authorize:[NSArray arrayWithObjects:@"user_about_me", @"user_birthday", @"email", @"user_photos", @"read_stream", @"friends_about_me", @"friends_birthday", @"friends_photos", @"xmpp_login", nil]];
}


#pragma mark - FBSession Delegate

- (void)fbDidLogin {    
    NSString *fql = [NSString stringWithFormat:@"select uid, username, name, pic, about_me from user where uid IN (select uid2 from friend where uid1 = me()) OR uid = me()"];
    
    [[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"accesstoken"];
    [[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:@"expires_in"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [facebook requestWithMethodName:@"fql.query" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:fql, @"query", nil] andHttpMethod:@"POST" andDelegate:self];
}


#pragma mark - FBRequest Delegate

- (void)request:(FBRequest *)request didLoad:(id)result {    
    if ([result count] > 0) {
        NSString *email = [NSString stringWithFormat:@"%@@chat.facebook.com", [[result objectAtIndex:([result count] - 1)] objectForKey:@"username"]];
        
        [[FriendsList sharedInstance] createFriendsListWithArray:result];
        
        [[XMPPHandler sharedInstance] connectWithUserName:email andPassword:[txtPassword text]];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", [error description]);
}


#pragma mark - XMPP Handler Connection Delegate

- (void) connectionDidConnectToServer {
    
}

- (void) connectionFailedWithError:(NSError *)error {
    
}

- (void) connectionDidReceiveError {
    
}

- (void) connectionDidAuthenticate {
    BuddyListViewController *buddyList = [[BuddyListViewController alloc] init];
    [[self navigationController] pushViewController:buddyList animated:YES];
    [buddyList release];
}

- (void) connectionDidNotAuthenticate {
    NSLog(@"Fail to authenticate");
}

- (void) connectionDidDisconnectFromServer {
    
}

@end
