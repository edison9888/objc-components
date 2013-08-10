//
//  BuddyListViewController.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/19/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "BuddyListViewController.h"
#import "ChatViewController.h"
#import "FriendsList.h"

@implementation BuddyListViewController

@synthesize buddys;
@synthesize buddyListTableView;

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
- (void)loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self setView:rootView];
    [rootView release];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Buddy List"];
    
    buddyListTableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [buddyListTableView setDelegate:self];
    [buddyListTableView setDataSource:self];
    [buddyListTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self view] addSubview:buddyListTableView];
    [buddyListTableView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [[XMPPHandler sharedInstance] setBuddyDelegate:self];
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = 0;
    if (section == 0) {
        rows = [[[FriendsList sharedInstance] onlineFriends] count];
    }
    else if (section == 1) {
        rows = [[[FriendsList sharedInstance] offlineFriends] count];
    }
    
    return rows;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Online Friends";
    if (section == 1) {
        title = @"Offline Friends";
    }
    
    return title;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }
    
    [[cell textLabel] setText:@""];
    
    FriendsList *friendsList = [FriendsList sharedInstance];
    
    if ([indexPath section] == 0) {
        NSString *key = [[[friendsList onlineFriends] allKeys] objectAtIndex:[indexPath row]];
        
        [[cell textLabel] setText:[[[friendsList onlineFriends] objectForKey:key] objectForKey:@"name"]];
    }
    else if ([indexPath section] == 1) {
        NSString *key = [[[friendsList offlineFriends] allKeys] objectAtIndex:[indexPath row]];
        
        [[cell textLabel] setText:[[[friendsList offlineFriends] objectForKey:key] objectForKey:@"name"]];
    }
    
    return cell;
}


#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        FriendsList *friendsList = [FriendsList sharedInstance];
        NSString *key = [[[friendsList onlineFriends] allKeys] objectAtIndex:[indexPath row]];
        
        NSString *to = [NSString stringWithFormat:@"%@", [[[friendsList onlineFriends] objectForKey:key] objectForKey:@"uid"]];
        
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        [chatVC setFriendID:to];
        [[self navigationController] pushViewController:chatVC animated:YES];
        [chatVC release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Buddy Delegate

- (void)buddyDidComeOnlineWithUserID:(NSString *)userID {
    [[FriendsList sharedInstance] friendCameOnlineWithID:userID];
    [buddyListTableView reloadData];
}

- (void)buddyDidWentOfflineWithUserID:(NSString *)userID {
    [[FriendsList sharedInstance] friendWentOfflineWithID:userID];
    [buddyListTableView reloadData];
}


#pragma mark - XMPP Chat Delegate

- (void)chatDidReceiveMessage:(NSString *)message from:(NSString *)from to:(NSString *)to {
    
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    [messageDict setObject:from forKey:@"from"];
    [messageDict setObject:message forKey:@"message"];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [messages addObject:messageDict];
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    [chatVC setFriendID:[[FriendsList sharedInstance] userIDFromFacebookChatID:from]];
    [chatVC setChatMessages:messages];
    [[self navigationController] pushViewController:chatVC animated:YES];
    [chatVC release];
    
    [messages release];
    [messageDict release];
}


- (void)dealloc {
    [buddys release], buddys = nil;
    buddyListTableView = nil;
    
    [super dealloc];
}

@end
