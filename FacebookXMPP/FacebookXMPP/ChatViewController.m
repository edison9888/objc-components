//
//  ChatViewController.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "FriendsList.h"

@interface ChatViewController ()

- (void) sendMessage:(id)sender;
- (void) keyboardDidAppear;
- (void) keyboardWillHide;

@end

@implementation ChatViewController

@synthesize friendID, friendName;
@synthesize chatMessages;

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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[[[[FriendsList sharedInstance] friends] objectForKey:friendID] objectForKey:@"name"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    if (!chatMessages) {
        chatMessages = [[NSMutableArray alloc] init];
    }
    
    chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 420) style:UITableViewStylePlain];
    [chatTableView setDelegate:self];
    [chatTableView setDataSource:self];
    [chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self view] addSubview:chatTableView];
    [chatTableView reloadData];
    [chatTableView release];
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    txtMessage = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 250, 30)];
    [txtMessage setBorderStyle:UITextBorderStyleRoundedRect];
    [txtMessage setReturnKeyType:UIReturnKeySend];
    [txtMessage setDelegate:self];
    [inputView addSubview:txtMessage];
    [txtMessage release];
    
    sendMessageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendMessageButton setFrame:CGRectMake(270, 5, 40, 30)];
    [sendMessageButton setTitle:@"Send" forState:UIControlStateNormal];
    [[sendMessageButton titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
    [sendMessageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:sendMessageButton];
    
    [[self view] addSubview:inputView];
    [inputView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[XMPPHandler sharedInstance] setChatDelegate:self];
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


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)  {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary *dict = [chatMessages objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[dict objectForKey:@"message"]];
    [[cell detailTextLabel] setText:[dict objectForKey:@"from"]];
    
    return cell;
}


#pragma mark - Chat Delegate

- (void)chatDidReceiveMessage:(NSString *)message from:(NSString *)from to:(NSString *)to {
    if ([from isEqualToString:[[FriendsList sharedInstance] facebookChatIDForUserID:friendID]]) {
        NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
        [messageDict setObject:[self title] forKey:@"from"];
        [messageDict setObject:message forKey:@"message"];
        
        [chatMessages addObject:messageDict];
        [chatTableView reloadData];
        
        [messageDict release];
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0) {
        [self sendMessage:nil];
    }
    
    return YES;
}


#pragma mark - Private Methods

- (void) sendMessage:(id)sender {
    if ([[[txtMessage text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return;
    }
    
    [[XMPPHandler sharedInstance] sendMessage:[txtMessage text] to:[[FriendsList sharedInstance] facebookChatIDForUserID:friendID]];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"me", @"from", [txtMessage text], @"message", nil];
    [chatMessages addObject:dict];
    [dict release];
    
    [chatTableView reloadData];
    
    [txtMessage setText:@""];
}

- (void)keyboardDidAppear {
    [UIView beginAnimations:nil context:nil];
    [chatTableView setFrame:CGRectMake(0, 40, 320, 150)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide {
    [UIView beginAnimations:nil context:nil];
    [chatTableView setFrame:CGRectMake(0, 40, 320, 420)];
    [UIView commitAnimations];
}


- (void)dealloc {
    if (friendID) { [friendID release]; }
    friendID = nil;
    
    if (friendName) { [friendName release]; }
    friendName = nil;
    
    [chatMessages release], chatMessages = nil;
    
    [super dealloc];
}

@end
