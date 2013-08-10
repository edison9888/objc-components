//
//  TUChatStateManager.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/2/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "XMPPUserMemoryStorage.h"
#import "TUChatMessageManager.h"
#import "TUChatManager.h"
#import "YMLSSoundUtil.h"
#import "XMPPHandler.h"
#import "XMPPUser.h"

NSString *TUChatManagerMessageTypeKey = @"TUChatManagerMessageTypeKey";
NSString *TUChatManagerDateTypeKey = @"TUChatManagerDateTypeKey";
NSString *TUChatManagerMessageKey = @"TUChatManagerMessageKey";
NSString *TUChatManagerRecentBuddiesArchiveKey = @"TUChatManagerRecentBuddiesArchiveKey";
NSString *TUChatManagerAuthorizedBuddiesArchiveKey = @"TUChatManagerAuthorizedBuddiesArchiveKey";

#define TU_CHAT_DATE_FORMAT         @"dd MMMM yyyy, HH:mm:ss"

@interface TUChatManager () <XMPPHandlerBuddyDelegate, XMPPHandlerChatDelegate, XMPPHandlerConnectionDelegate> {
    BOOL needsUpdate;
//    TUChatManagerState statusToChange;
    
    NSString *userName, *password;
    
    XMPPHandler *xmppHandler;
    
    NSMutableArray *delegates, *pendingRequest, *sentRequest, *onlineUsers, *awayUsers, *offlineUsers, *currentSessionUsers, *invisibleUsers;
    YMLSSoundUtil *chatSound;
}

@property (nonatomic, copy) NSString *userName, *password;
@property (nonatomic, strong) NSMutableArray *delegates, *pendingRequest, *sentRequest, *onlineUsers, *awayUsers, *offlineUsers, *currentSessionUsers, *invisibleUsers;

- (void) removeBuddy:(TUBuddy *)buddy;
- (void) clearData;
- (void) saveRecentBuddies;
- (void) saveAuthorizedBuddies;
- (void) logoutNotification;

@end

static TUChatManager *chatManager = nil;

@implementation TUChatManager

@synthesize isConnecting;
@synthesize state;
@synthesize allBuddies;
@synthesize currentBuddy;
@synthesize userName, password;
@synthesize delegates, pendingRequest, sentRequest, onlineUsers, awayUsers, offlineUsers, currentSessionUsers, invisibleUsers;

+ (TUChatManager *) chatManager {
    if (chatManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            chatManager = [[[self class] alloc] init];
        });
    }
    
    return chatManager;
}


#pragma mark - Singleton Override Methods

+ (id)allocWithZone:(NSZone *)zone {
    if (chatManager == nil) {
        chatManager = [super allocWithZone:zone];
        return chatManager;
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
//        statusToChange = TUChatManagerStateOnline;
        delegates = [[NSMutableArray alloc] init];
        allBuddies = [[NSMutableDictionary alloc] init];
        
        pendingRequest = [[NSMutableArray alloc] init];
        sentRequest = [[NSMutableArray alloc] init];
        onlineUsers = [[NSMutableArray alloc] init];
        awayUsers = [[NSMutableArray alloc] init];
        offlineUsers = [[NSMutableArray alloc] init];
        currentSessionUsers = [[NSMutableArray alloc] init];
        invisibleUsers = [[NSMutableArray alloc] init];
        
        xmppHandler = [XMPPHandler sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutNotification)
                                                     name:(NSString *)TUCurrentUserSignOutNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutNotification)
                                                     name:(NSString *)TUCurrentUserTokenExpireNotification
                                                   object:nil];
        
        chatSound = [YMLSSoundUtil soundEffectWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tick" ofType:@"mp3"]];
    }
    return self;
}

#pragma mark - Setter Methods

- (void) setState:(TUChatManagerState)_state {
//    if (![xmppHandler isConnected]) {
//        [self connect];
//        return;
//    }
    
    if (state != _state) {
        TLog(@"Status Changed to %d", _state);
        
        state = _state;
        
        switch (state) {
            case TUChatManagerStateOffline:
                [xmppHandler setUnavailable];
                break;
                
            case TUChatManagerStateOnline:
                [xmppHandler setAvailable];
                break;
                
            case TUChatManagerStateAway:
                [xmppHandler setAway];
                break;
                
            case TUChatManagerStateInvisible:
                [xmppHandler setInvisible];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Private Methods

- (void) removeBuddy:(TUBuddy *)buddy {
    NSString *userID = [buddy userID];
    
    if (buddy) {
        switch ([buddy status]) {
            case TUBuddyStatusRequestSent:
                [sentRequest removeObject:userID];
                break;
                
            case TUBuddyStatusRequestReceived:
                [pendingRequest removeObject:userID];
                break;
                
            case TUBuddyStatusCurrentSession:
                [currentSessionUsers removeObject:userID];
                break;
                
            case TUBuddyStatusOnline:
                [onlineUsers removeObject:userID];
                break;
                
            case TUBuddyStatusAway:
                [awayUsers removeObject:userID];
                break;
                
            case TUBuddyStatusOffline:
                [offlineUsers removeObject:userID];
                break;
                
            case TUBuddyStatusInvisible:
                [invisibleUsers removeObject:userID];
                break;
                
            default:
                break;
        }
        
        [allBuddies removeObjectForKey:userID];
    }
}

- (void) clearData {
    TLog(@"Data Cleared");
    
    [allBuddies removeAllObjects];
    
    [self setPendingRequest:nil];
    [self setSentRequest:nil];
    [self setOnlineUsers:nil];
    [self setAwayUsers:nil];
    [self setOfflineUsers:nil];
    [self setCurrentSessionUsers:nil];
    [self setInvisibleUsers:nil];
    [self setDelegates:nil];
    [self setCurrentBuddy:nil];
    [self resetUnreadCount];
    
    pendingRequest = [[NSMutableArray alloc] init];
    sentRequest = [[NSMutableArray alloc] init];
    onlineUsers = [[NSMutableArray alloc] init];
    awayUsers = [[NSMutableArray alloc] init];
    offlineUsers = [[NSMutableArray alloc] init];
    currentSessionUsers = [[NSMutableArray alloc] init];
    invisibleUsers = [[NSMutableArray alloc] init];
    delegates = [[NSMutableArray alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TUChatManagerRecentBuddiesArchiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    state = TUChatManagerStateOffline;
    
//    for (id<TUChatManagerDelegate>delegate in delegates) {
//        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidClearUserData)]) {
//            [delegate chatManagerDidClearUserData];
//        }
//    }
}


#pragma mark - Public Methods

#pragma mark Connection

- (void) connect {
    TLog(@"Connect");
    if (!isConnecting) {
        if (userName && password) {
            TLog(@"Connection initiated");
            [xmppHandler addConnectionDelegate:self];
            [xmppHandler addBuddyDelegate:self];
            [xmppHandler addChatDelegate:self];
            
            isConnecting = YES;
            [xmppHandler connectWithUserName:userName andPassword:password];
        }
        else {
            TLog(@"User name and password is not available.");
            [self setState:TUChatManagerStateOffline];
        }
    }
}

- (void) disconnect {
    TLog(@"Disconnect");
    [xmppHandler disconnect];
}

- (BOOL) isConnected {
    return [xmppHandler isConnected];
}

- (BOOL) isCredentialsAvailable {
    return (![self isNilOrNull:userName] && ![self isNilOrNull:password]);
}

- (void) setUserName:(NSString *)_userName password:(NSString *)_password {
    [self setUserName:[_userName lowercaseString]];
    [self setPassword:_password];
}

- (void) sendPresence:(TUChatManagerState)presence toUserWithID:(NSString *)userID {
    TLog(@"sending presence to user %@", userID);
    switch (presence) {
        case TUChatManagerStateOffline:
            [xmppHandler sendPresence:@"unavailable" toUser:userID];
            break;
            
        case TUChatManagerStateOnline:
            [xmppHandler sendPresence:@"available" toUser:userID];
            break;
            
        case TUChatManagerStateAway:
            [xmppHandler sendPresence:@"away" toUser:userID];
            break;
            
        case TUChatManagerStateInvisible:
            [xmppHandler sendPresence:@"invisible" toUser:userID];
            break;
            
        default:
            break;
    }
}

- (void) sleep {
    TLog(@"Chat entered into background");
    if (isConnecting) {
        isConnecting = NO;
    }
//    statusToChange = state;
    
    if ([[xmppHandler xmppStream] isConnected]) {
//        [chatManager setState:TUChatManagerStateAway];
        [chatManager setState:TUChatManagerStateOffline];
    }
    else {
        state = TUChatManagerStateOffline;
        [xmppHandler clearStream];
    }
}

- (void) awake {
    TLog(@"Chat become active");
    if (![[xmppHandler xmppStream] isConnected]) {
        _isCompleteBuddyFetching = NO;
        
        state = TUChatManagerStateOffline;
        [xmppHandler clearStream];
        [xmppHandler clearData];
        
        [allBuddies removeAllObjects];
        [pendingRequest removeAllObjects];
        [sentRequest removeAllObjects];
        [onlineUsers removeAllObjects];
        [awayUsers removeAllObjects];
        [offlineUsers removeAllObjects];
        [currentSessionUsers removeAllObjects];
        [invisibleUsers removeAllObjects];
        [self resetUnreadCount];
        state = TUChatManagerStateOffline;
        
        [self connect];
    }
    else {
//        [self setState:statusToChange];
        [self setState:TUChatManagerStateOnline];
    }
}


#pragma mark Delegate

- (void) addDelegate:(id<TUChatManagerDelegate>)delegate {
    if (delegate && ![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

- (void) addDelegates:(NSArray *)__delegates {
    for (id delegate in __delegates) {
        if (delegate && ![delegates containsObject:delegate]) {
            [delegates addObject:delegate];
        }
    }
}

- (void) removeDelegate:(id<TUChatManagerDelegate>)delegate {
    if (delegate && [delegates containsObject:delegate]) {
        [delegates removeObject:delegate];
    }
}

- (void) removeDelegates:(NSArray *)__delegates {
    for (id delegate in __delegates) {
        if (delegate && [delegates containsObject:delegate]) {
            [delegates removeObject:delegate];
        }
    }
}


#pragma mark Message

- (void) composingToBuddy:(TUBuddy *)to {
    [xmppHandler sendChatState:@"composing" to:[to userID]];
}

- (TUChatMessage *) sendOfflineMessage:(NSString *)_message toBuddy:(TUBuddy *)to {
    TUChatMessage *message = [self messageObjectFromMessage:_message toBuddy:to isSent:YES];
    [message setIsOfflineMessage:YES];
    
    TUBuddy *buddy = [allBuddies objectForKey:[to userID]];
    if (buddy) {
        [buddy setLastMessage:message];
        [self saveRecentBuddies];
        [self saveAuthorizedBuddies];
    }
    
    [[TUChatMessageManager chatMessageManager] addMessage:message];
    
    return message;
}

- (TUChatMessage *) sendMessage:(NSString *)_message toBuddy:(TUBuddy *)to {
    TLog(@"Send message %@ to %@", _message, [to userID]);
    
    TUChatMessage *message = [self messageObjectFromMessage:_message toBuddy:to isSent:YES];
    
    TUBuddy *buddy = [allBuddies objectForKey:[to userID]];
    if (buddy) {
        [buddy setLastMessage:message];
        [self saveRecentBuddies];
        [self saveAuthorizedBuddies];
    }
    
    [xmppHandler sendMessage:_message to:[to userID]];
    [[TUChatMessageManager chatMessageManager] addMessage:message];
    
    return message;
}

- (void) retryMessage:(TUChatMessage *)message {
    [xmppHandler sendMessage:[message message] to:[message to]];
    [[TUChatMessageManager chatMessageManager] updateMessage:message isOffline:NO];
    [message setIsOfflineMessage:NO];
    
    TUBuddy *buddy = [allBuddies objectForKey:[message to]];
    if (buddy) {
        [buddy setLastMessage:message];
        [self saveRecentBuddies];
        [self saveAuthorizedBuddies];
    }
}

- (void) sendHiddenMessage:(NSDictionary *)message toBuddy:(TUBuddy *)buddy {
    NSString *messageString = [message JSONRepresentation];
    [xmppHandler sendMessage:messageString to:[buddy userID]];
}

- (TUChatMessage *) storeChatTimeWithBuddy:(TUBuddy *)to {
    TUChatMessage *message = [[TUChatMessage alloc] init];
    [message setFrom:[[[TUCurrentUser currentUser] userName] lowercaseString]];
    [message setTo:[[to userID] lowercaseString]];
    [message setMessage:@""];
    [message setStatus:TUChatMessageStatusTimeSeparator];
    
    [[TUChatMessageManager chatMessageManager] addMessage:message];
    
    TUChatMessage *tempMessage = [[TUChatMessageManager chatMessageManager] lastMessageWithUser:[to userID]];
    [message setTime:[tempMessage time]];
    
    return message;
}

- (TUChatMessage *) messageObjectFromMessage:(NSString *)_message toBuddy:(TUBuddy *)to isSent:(BOOL)isSent {
    TUChatMessage *message = [[TUChatMessage alloc] init];
    [message setFrom:[[[TUCurrentUser currentUser] userName] lowercaseString]];
    [message setTo:[[to userID] lowercaseString]];
    [message setMessage:_message];
    [message setTime:[NSDate date]];
    [message setIsSent:isSent];
    
    return message;
}

- (TUChatMessage *) saveMessage:(TUChatMessage *)message isSent:(BOOL)isSent {
    [[TUChatMessageManager chatMessageManager] addMessage:message];
    TUChatMessage *tempMessage = [[TUChatMessageManager chatMessageManager] lastMessageWithUser:(isSent)?[message to]:[message from]];
    [message setTime:[tempMessage time]];
    
    return message;
}


#pragma mark Buddy

- (void) changeBuddy:(TUBuddy *)buddy toStatus:(TUBuddyStatus)status {
    NSString *userID = [buddy userID];
    
    switch ([buddy status]) {
        case TUBuddyStatusRequestReceived:
            [pendingRequest removeObject:userID];
            break;
            
        case TUBuddyStatusOffline:
            [offlineUsers removeObject:userID];
            break;
            
        case TUBuddyStatusOnline:
            [onlineUsers removeObject:userID];
            break;
            
        case TUBuddyStatusAway:
            [awayUsers removeObject:userID];
            break;
            
        case TUBuddyStatusCurrentSession:
            [currentSessionUsers removeObject:userID];
            break;
            
        case TUBuddyStatusInvisible:
            [invisibleUsers removeObject:userID];
            break;
            
        default:
            break;
    }
    
    [buddy setStatus:status];
    
    switch ([buddy status]) {
        case TUBuddyStatusOffline:
            [offlineUsers addObject:userID];
            break;
            
        case TUBuddyStatusOnline:
            [onlineUsers addObject:userID];
            break;
            
        case TUBuddyStatusAway:
            [awayUsers addObject:userID];
            break;
            
        case TUBuddyStatusCurrentSession:
            [currentSessionUsers addObject:userID];
            break;
            
        case TUBuddyStatusInvisible:
            [invisibleUsers addObject:userID];
            break;
            
        default:
            break;
    }
}

- (void) openChatWithBuddy:(TUBuddy *)buddy {
    [self markAsReadedForBuddy:buddy];
    [self setCurrentBuddy:buddy];
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidOpenChatWithBuddy:)]) {
            [delegate chatManagerDidOpenChatWithBuddy:buddy];
        }
    }
}

- (void) markAsReadedForBuddy:(TUBuddy *)buddy {
    TUChatMessage *message =  [[TUChatMessageManager chatMessageManager] lastMessageWithUser:[buddy userID]];
    if ([buddy unreadMessagesCount] > 0 && message && [message status] != TUChatMessageStatusTimeSeparator && [message status] != TUChatMessageStatusReadedByFriend) {
        needsUpdate = YES;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[TUChatManagerMessageTypeKey] = [NSNumber numberWithInt:TUChatMessageStatusReadedByFriend];
        dict[TUChatManagerDateTypeKey] = [[[NSDate date] convertToTimeZone:@"GMT"] convertToStringWithFormat:TU_CHAT_DATE_FORMAT];
        
        [self sendHiddenMessage:dict toBuddy:buddy];
    }
    
    [buddy setUnreadMessagesCount:0];
    [[TUChatMessageManager chatMessageManager] setAsReadedForUser:[buddy userID]];
}

- (NSMutableArray *) chatHistoryWithBuddy:(TUBuddy *)buddy offset:(NSUInteger)offset limit:(int)limit {
    return [[TUChatMessageManager chatMessageManager] messagesWithUser:[buddy userID] offset:offset limit:limit];
}

- (void) clearHistoryWithBuddy:(TUBuddy *)buddy {
    [[TUChatMessageManager chatMessageManager] clearMessagesWithUser:[buddy userID]];
    [buddy setLastMessage:nil];
}


#pragma mark Chat Request

- (void) requestChatPermission:(NSString*)to nickName:(NSString *)nickName {
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", [to lowercaseString], XMPP_SERVER_NAME]];
    
    TLog(@"Chat Request sent to %@ with nickname %@", jid, nickName);
    
    [[xmppHandler roaster] addBuddy:jid withNickname:[nickName urlEncode]];
    
    TUBuddy *buddy = [[TUBuddy alloc] init];
    [buddy setJID:[[jid full] lowercaseString]];
    [buddy setUserID:[to lowercaseString]];
    [buddy setName:nickName];
    [buddy setLastMessage:[[TUChatMessageManager chatMessageManager] lastTextMessageWithUser:to]];
    [buddy setUnreadMessagesCount:[[TUChatMessageManager chatMessageManager] unreadedMessagesCountFromUser:to]];
    [buddy setStatus:TUBuddyStatusRequestSent];
    [allBuddies setObject:buddy forKey:[to lowercaseString]];
    [sentRequest addObject:[to lowercaseString]];
}

- (void) acceptChatPermission:(NSString*)to {
    TLog(@"Accept the chat request of %@", [to lowercaseString]);
    TUBuddy *buddy = [allBuddies objectForKey:[to lowercaseString]];
    
    needsUpdate = YES;
    [self buddy:[buddy jID] statusChanged:@"unavailable" withNickName:[buddy name]];
    
    [[xmppHandler roaster] acceptBuddyRequest:[XMPPJID jidWithString:[buddy jID]]];
    
    [self saveAuthorizedBuddies];

}

- (void) rejectChatPermission:(NSString*)to {
    TLog(@"Reject the chat request of %@", [to lowercaseString]);
    TUBuddy *buddy = [allBuddies objectForKey:[to lowercaseString]];
    
    if (buddy) {
        [[xmppHandler roaster] rejectBuddyRequest:[XMPPJID jidWithString:[buddy jID]]];
        
        [self removeBuddy:buddy];
        needsUpdate = YES;
        
        for (id<TUChatManagerDelegate>delegate in delegates) {
            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidRejectRequest:)]) {
                [delegate chatManagerDidRejectRequest:buddy];
            }
        }
        
        [self saveAuthorizedBuddies];
    }
}

- (void) unsubscribe:(NSString*)to {
    TLog(@"Removing user from friends list : %@", [to lowercaseString]);
    TUBuddy *buddy = [allBuddies objectForKey:[to lowercaseString]];
    if (buddy) {
//        [self clearHistoryWithBuddy:buddy];
        [[xmppHandler roaster] removeBuddy:[XMPPJID jidWithString:[buddy jID]]];
        
        if ([buddy status] != TUBuddyStatusRequestSent) {
            needsUpdate = YES;
        }
        
        [self removeBuddy:buddy];
        
        for (id<TUChatManagerDelegate>delegate in delegates) {
            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidUnsubscribeBuddy:)]) {
                [delegate chatManagerDidUnsubscribeBuddy:buddy];
            }
        }
        
        [self saveAuthorizedBuddies];
    }
}

- (void) cancelRequest:(NSString *)to {
    TUBuddy *buddy = [allBuddies objectForKey:[to lowercaseString]];
    if (buddy) {
//        [self clearHistoryWithBuddy:buddy];
        [[xmppHandler roaster] removeBuddy:[XMPPJID jidWithString:[buddy jID]]];
        
        if ([buddy status] != TUBuddyStatusRequestSent) {
            needsUpdate = YES;
        }
        
        [self removeBuddy:buddy];
        
        [xmppHandler sendPresence:@"unsubscribe" toUser:to];
        
        for (id<TUChatManagerDelegate>delegate in delegates) {
            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidUnsubscribeBuddy:)]) {
                [delegate chatManagerDidUnsubscribeBuddy:buddy];
            }
        }
        
        [self saveAuthorizedBuddies];
    }
}


#pragma mark Extras

- (void) resetUnreadCount {
    needsUpdate = YES;
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidResetUnread)]) {
            [delegate chatManagerDidResetUnread];
        }
    }
}

- (NSUInteger) availableUserStatus:(TUAvailableUserStatus *)status {
    if (status) { *status = 0; }
    NSUInteger count = 0;
    
    if ([pendingRequest count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusPending; }
        count++;
    }
    
    if ([currentSessionUsers count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusCurrentSession; }
        count++;
    }
    
    if ([onlineUsers count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusOnline; }
        count++;
    }
    
    if ([awayUsers count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusAway; }
        count++;
    }
    
    if ([offlineUsers count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusOffline; }
        count++;
    }
    
    if ([invisibleUsers count] > 0) {
        if (status) { *status = *status | TUAvailableUserStatusInvisible; }
        count++;
    }
    
    return count;
}

- (NSUInteger) buddiesCountForStatus:(TUAvailableUserStatus)status {
    NSUInteger buddiesCount;
    
    switch (status) {
        case TUAvailableUserStatusPending:
            buddiesCount = [pendingRequest count];
            break;
            
        case TUAvailableUserStatusCurrentSession:
            buddiesCount = [currentSessionUsers count];
            break;
            
        case TUAvailableUserStatusOnline:
            buddiesCount = [onlineUsers count];
            break;
            
        case TUAvailableUserStatusAway:
            buddiesCount = [awayUsers count];
            break;
            
        case TUAvailableUserStatusInvisible:
            buddiesCount = [invisibleUsers count];
            break;
            
        case TUAvailableUserStatusOffline:
            buddiesCount = [offlineUsers count];
            break;
            
        default:
            break;
    }
    
    return buddiesCount;
}

- (NSArray *) buddiesForStatus:(TUAvailableUserStatus)status {
    NSArray *buddies = nil;
    
    switch (status) {
        case TUAvailableUserStatusPending:
            buddies = [allBuddies objectsForKeys:pendingRequest notFoundMarker:[NSNull null]];
            break;
            
        case TUAvailableUserStatusCurrentSession:
            buddies = [allBuddies objectsForKeys:currentSessionUsers notFoundMarker:[NSNull null]];
            break;
            
        case TUAvailableUserStatusOnline:
            buddies = [allBuddies objectsForKeys:onlineUsers notFoundMarker:[NSNull null]];
            break;
            
        case TUAvailableUserStatusAway:
            buddies = [allBuddies objectsForKeys:awayUsers notFoundMarker:[NSNull null]];
            break;
            
        case TUAvailableUserStatusInvisible:
            buddies = [allBuddies objectsForKeys:invisibleUsers notFoundMarker:[NSNull null]];
            break;
        
        case TUAvailableUserStatusOffline:
            buddies = [allBuddies objectsForKeys:offlineUsers notFoundMarker:[NSNull null]];
            break;
            
        default:
            break;
    }
    
    return buddies;
}

- (NSMutableArray *) authorizedBuddies {
    NSMutableArray *authorizedBuddies = [[NSMutableArray alloc] init];
    
    if (_isCompleteBuddyFetching) {
        for (TUBuddy *buddy in [allBuddies allValues]) {
            if ([buddy status] != TUBuddyStatusRequestReceived && [buddy status] != TUBuddyStatusRequestSent) {
                [authorizedBuddies addObject:buddy];
            }
        }
    }
    else {
        NSData *buddiesData = [[NSUserDefaults standardUserDefaults] objectForKey:TUChatManagerAuthorizedBuddiesArchiveKey];
        if (buddiesData) {
            NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithData:buddiesData];
            if (tempArray && [tempArray count] > 0) {
                [authorizedBuddies addObjectsFromArray:tempArray];
            }
        }
    }
    
    return authorizedBuddies;
}

- (NSMutableArray *) recentBuddies {
    NSMutableArray *recentBuddies = [[NSMutableArray alloc] init];
    
    if (_isCompleteBuddyFetching) {
        for (TUBuddy *buddy in [allBuddies allValues]) {
            if ([buddy status] != TUBuddyStatusRequestReceived && [buddy status] != TUBuddyStatusRequestSent && ![self isNilOrNull:[[buddy lastMessage] message]]) {
                [recentBuddies addObject:buddy];
            }
        }
    }
    else {
        NSData *buddiesData = [[NSUserDefaults standardUserDefaults] objectForKey:TUChatManagerRecentBuddiesArchiveKey];
        if (buddiesData) {
            NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithData:buddiesData];
            if (tempArray && [tempArray count] > 0) {
                [recentBuddies addObjectsFromArray:tempArray];
            }
        }
    }
    
    return recentBuddies;
}

- (void) saveRecentBuddies {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:[self recentBuddies]];
    if (archivedData) {
        [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:TUChatManagerRecentBuddiesArchiveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) saveAuthorizedBuddies {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:[self authorizedBuddies]];
    if (archivedData) {
        [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:TUChatManagerAuthorizedBuddiesArchiveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL) isAuthorizedBuddy:(NSString *)userID {
    TUBuddy *buddy = [allBuddies objectForKey:userID];
    if (buddy && [buddy status] != TUBuddyStatusRequestReceived && [buddy status] != TUBuddyStatusRequestSent) {
        return YES;
    }
    
    return NO;
}

- (UIImage *) iconForStatus:(TUBuddyStatus)status {
    UIImage *image = [UIImage imageNameInBundle:@"ico_offline" withExtension:@"png"];
    switch (status) {
        case TUBuddyStatusCurrentSession:
        case TUBuddyStatusOnline:
            image = [UIImage imageNameInBundle:@"ico_online" withExtension:@"png"];
            break;

        case TUBuddyStatusAway:
            image = [UIImage imageNameInBundle:@"ico_online" withExtension:@"png"];
            break;
            
        case TUBuddyStatusInvisible:
        case TUBuddyStatusOffline:
            image = [UIImage imageNameInBundle:@"ico_offline" withExtension:@"png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

- (TUBuddy *) buddyForUserID:(NSString *)userID {
    TUBuddy *buddy = [allBuddies objectForKey:userID];
    if ([buddy status] == TUBuddyStatusRequestReceived || [buddy status] == TUBuddyStatusRequestSent) {
        return nil;
    }
    
    return buddy;
}

- (BOOL) isUserOnline:(NSString *)userID {
    return [onlineUsers containsObject:userID];
}

- (BOOL) needsNotificationUpdate:(NSUInteger *)count fromCount:(NSUInteger *)fromCount {
    *count = 0;
    *fromCount = 0;
    
    if (needsUpdate && count && fromCount) {
        for (TUBuddy *buddy in [allBuddies allValues]) {
            if ([buddy status] != TUBuddyStatusRequestSent) {
                if ([buddy status] == TUBuddyStatusRequestReceived) {
                    *count += 1;
                    *fromCount += 1;
                }
                else {
                    *count += [buddy unreadMessagesCount];
                    
                    if ([buddy unreadMessagesCount] > 0) {
                        *fromCount += 1;
                    }
                }
            }
        }
    }
    
    return needsUpdate;
}

- (void) resetNotificationUpdate {
    needsUpdate = NO;
}

- (void) networkInterrupted {
    state = TUChatManagerStateOffline;
}


#pragma mark - XMPPHandler Connection Delegate

- (void) connectionDidConnectToServer {
    TLog(@"Chat connected. Trying to authenticate...");
    [xmppHandler setDisplayName:[[[TUCurrentUser currentUser] displayName] urlEncode]];
}

- (void) connectionDidAuthenticate {
    TLog(@"Chat Authenticated");
    [xmppHandler fetchBuddies];
    [self awake];
    isConnecting = NO;
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidFinishAuthentication)]) {
            [delegate chatManagerDidFinishAuthentication];
        }
    }
}

- (void) connectionDidNotAuthenticate {
    TLog(@"Chat fail to authenticate");
    isConnecting = NO;
    _isFailed = YES;
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidNotAuthentication)]) {
            [delegate chatManagerDidNotAuthentication];
        }
    }
}

//- (void) connectionDidDisconnectFromServer {
//    statusToChange = TUChatManagerStateOnline;
//    
//    if (isConnecting) {
//        isConnecting = NO;
//    }
//    
//    for (id<TUChatManagerDelegate>delegate in delegates) {
//        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidDisconnect)]) {
//            [delegate chatManagerDidDisconnect];
//        }
//    }
//    
//    [xmppHandler clearData];
//    [self clearData];
//    [self setUserName:nil];
//    [self setPassword:nil];
//}

- (void) connectionDidReceiveError {
    if (isConnecting) {
        isConnecting = NO;
    }
}

- (void) connectionDidTimeOut {
//    statusToChange = state;
    state = TUChatManagerStateOffline;
}


#pragma mark - XMPPHandler Buddy Delegate

- (void) buddyDidReceiveChatRequest:(NSString *)userID {
    TLog(@"Chat Request received from %@", userID);
    NSString *fullUseID = [userID lowercaseString];
    userID = [fullUseID substringUserName];
    TUBuddy *buddy = [allBuddies objectForKey:userID];
    
    if (!buddy) {
        buddy = [[TUBuddy alloc] init];
        [buddy setJID:fullUseID];
        [buddy setUserID:userID];
        [buddy setName:userID];
        [buddy setStatus:TUBuddyStatusRequestReceived];
        [allBuddies setObject:buddy forKey:userID];
        [pendingRequest addObject:userID];
    }
    
    needsUpdate = YES;
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidReceiveChatRequest:)]) {
            [delegate chatManagerDidReceiveChatRequest:buddy];
        }
    }
}

- (void) buddyDidReceiveUnsubscribe:(NSString *)userID {
    TLog(@"%@ removed you from his/her chat list", userID);
    
    [self unsubscribe:[userID substringUserName]];
    
//    TUBuddy *buddy = [allBuddies objectForKey:[userID substringUserName]];
//    if (buddy) {
//        [self removeBuddy:buddy];
//        
//        for (id<TUChatManagerDelegate>delegate in delegates) {
//            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidUnsubscribeBuddy:)]) {
//                [delegate chatManagerDidUnsubscribeBuddy:buddy];
//            }
//        }
//    }
}

- (void) buddyDidRejectedByUser:(NSString *)userID {
    TLog(@"%@ removed you from his chat list", [userID lowercaseString]);
    TUBuddy *buddy = [allBuddies objectForKey:[userID substringUserName]];
    if (buddy) {
        [self removeBuddy:buddy];
        
        for (id<TUChatManagerDelegate>delegate in delegates) {
            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidRequestRejectedBy:)]) {
                [delegate chatManagerDidRequestRejectedBy:buddy];
            }
        }
    }
}

- (void) buddy:(NSString *)userID statusChanged:(NSString *)statusString withNickName:(NSString *)nickName {
    TLog(@"%@ changed his status to %@ with nickname %@", userID, statusString, nickName);
    NSString *fullUserID = [userID lowercaseString];
    userID = [fullUserID substringUserName];
    
    if ([userID isEqualToString:[[TUCurrentUser currentUser] userName]]) {
        return;
    }
    
    TUBuddyStatus newStatus = TUBuddyStatusOffline;
    TUBuddyStatus oldStatus = TUBuddyStatusOffline;
    
    if ([statusString isEqualToString:@"unavailable"]) {
        newStatus = TUBuddyStatusOffline;
    }
    else if ([statusString isEqualToString:@"xa"] || [statusString isEqualToString:@"dnd"] || [statusString isEqualToString:@"away"]) {
        newStatus = TUBuddyStatusAway;
    }
    else if ([statusString isEqualToString:@"invisible"]) {
        newStatus = TUBuddyStatusInvisible;
    }
    else if ([statusString isEqualToString:@"available"]) {
        newStatus = TUBuddyStatusOnline;
    }

    TUBuddy *buddy = [allBuddies objectForKey:userID];
    if (!buddy) {
        buddy = [[TUBuddy alloc] init];
        [buddy setJID:fullUserID];
        [buddy setUserID:userID];
        [buddy setName:userID];
        [buddy setStatus:newStatus];
        [buddy setLastMessage:[[TUChatMessageManager chatMessageManager] lastTextMessageWithUser:userID]];
        [buddy setUnreadMessagesCount:[[TUChatMessageManager chatMessageManager] unreadedMessagesCountFromUser:[buddy userID]]];
        [allBuddies setObject:buddy forKey:userID];
        
        if ([buddy unreadMessagesCount] > 0) {
            needsUpdate = YES;
        }
    }
    
    if (nickName) {
        [buddy setName:[nickName urlDecodedString]];
        [[xmppHandler roaster] setNickname:nickName forBuddy:[XMPPJID jidWithString:fullUserID]];
    }
    
    oldStatus = [buddy status];
    [self changeBuddy:buddy toStatus:newStatus];
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidChangeUserPresence:fromStatus:)]) {
            [delegate chatManagerDidChangeUserPresence:buddy fromStatus:oldStatus];
        }
    }
}

// Interuption Handler like app crash or terminated or unavailable call after unsubscribed
- (void) buddy:(NSString *)userID didReceiveInteruption:(NSString *)interuptionState {
    TLog(@"%@ locked his device or app got terminated", userID);
    if ([interuptionState isEqualToString:@"unavailable"]) {
        TUBuddy *buddy = [allBuddies objectForKey:[userID substringUserName]];
        if (buddy) {
            TUBuddyStatus oldStatus = [buddy status];
            [self changeBuddy:buddy toStatus:TUBuddyStatusOffline];
            
            for (id<TUChatManagerDelegate>delegate in delegates) {
                if (delegate && [delegate respondsToSelector:@selector(chatManagerDidChangeUserPresence:fromStatus:)]) {
                    [delegate chatManagerDidChangeUserPresence:buddy fromStatus:oldStatus];
                }
            }
        }
    }
}


#pragma mark - XMPPHandler Chat Delegate

- (void) chatDidReceiveRosterChange:(XMPPRosterMemoryStorage *)rosterStorage {
    TLog(@"Roaster loading finished %@", [rosterStorage allItems]);
    for (XMPPUserMemoryStorage *rosterUser in [rosterStorage allItems]) {
        NSString *userID =  [[[rosterUser jid] bare] substringUserName];
        
        TUBuddy *buddy = [allBuddies objectForKey:userID];
        if (!buddy) {
            buddy = [[TUBuddy alloc] init];
            [buddy setJID:[[[rosterUser jid] full] lowercaseString]];
            [buddy setUserID:userID];
            [buddy setName:[[rosterUser nickname] urlDecodedString]];
            if ([self isNilOrNull:[buddy name]]) {
                [buddy setName:userID];
            }
            [buddy setLastMessage:[[TUChatMessageManager chatMessageManager] lastTextMessageWithUser:userID]];
            [buddy setUnreadMessagesCount:[[TUChatMessageManager chatMessageManager] unreadedMessagesCountFromUser:userID]];
            [allBuddies setObject:buddy forKey:userID];
            
            if ([rosterUser isPendingApproval]) {
                [buddy setStatus:TUBuddyStatusRequestSent];
                [sentRequest addObject:userID];
            }
            else {
                [buddy setStatus:TUBuddyStatusOffline];
                [offlineUsers addObject:userID];
            }
        }
    }
    
    needsUpdate = YES;
    _isCompleteBuddyFetching = YES;
    
    [self saveRecentBuddies];
    [self saveAuthorizedBuddies];
    
    for (id<TUChatManagerDelegate>delegate in delegates) {
        if (delegate && [delegate respondsToSelector:@selector(chatManagerDidFinishFetchingBuddies)]) {
            [delegate chatManagerDidFinishFetchingBuddies];
        }
    }
}

- (void) chatBuddy:(NSString *)from chatstate:(NSString *)chatstate {
    TUBuddy *buddy = [allBuddies objectForKey:[from substringUserName]];
    if (buddy) {
        if ([chatstate isEqualToString:@"composing"]) {
            for (id<TUChatManagerDelegate>delegate in delegates) {
                if (delegate && [delegate respondsToSelector:@selector(chatManagerDidReceiveUserCompose:)]) {
                    [delegate chatManagerDidReceiveUserCompose:buddy];
                }
            }
        }
    }
}

- (void) chatDidReceiveMessage:(NSString *)_message from:(NSString *)from to:(NSString *)to {
    TLog(@"New message %@, came from %@", _message, from);
    NSDictionary *hiddenMessage = [_message JSONValue];
    from = [from substringUserName];
    to = [to substringUserName];
    
    if (![allBuddies objectForKey:from]) {
        return;
    }
    
    if ([self isNilOrNull:_message]) {
        return;
    }
    
    NSString *currentUserID = [[[TUCurrentUser currentUser] userName] lowercaseString];
    if ([currentUserID isEqualToString:to]) {
        TUBuddy *buddy = [allBuddies objectForKey:from];
        
        TUChatMessage *message = [[TUChatMessage alloc] init];
        [message setFrom:from];
        [message setTo:currentUserID];
        [message setIsSent:NO];
        
        // If hidden message
        if (![self isNilOrNull:hiddenMessage]) {
            // if user seen unreaded message
            if ([hiddenMessage[TUChatManagerMessageTypeKey] intValue] == TUChatMessageStatusReadedByFriend) {
                [message setMessage:@""];
                [message setStatus:TUChatMessageStatusReadedByFriend];
            }
            // if user newly connected to a buddy
            else if ([hiddenMessage[TUChatManagerMessageTypeKey] intValue] == TUChatMessageStatusConnected) {
                NSString *msg = hiddenMessage[TUChatManagerMessageKey];
                [message setMessage:msg];
                [message setStatus:TUChatMessageStatusConnected];
                buddy.unreadMessagesCount++;
            }
        }
        // Normal message
        else {
            [message setMessage:_message];
            if (buddy) {
                [buddy setLastMessage:message];
            }
            
            if (!currentBuddy || ![from isEqualToString:[currentBuddy userID]]) {
                [message setStatus:TUChatMessageStatusUnReaded];
                buddy.unreadMessagesCount++;
            }
        }
        
        needsUpdate = YES;
        
        
        NSMutableArray *messagesWithTimeFormate = [[NSMutableArray alloc] init];
        
        // If hidden message
        if ([message status] == TUChatMessageStatusReadedByFriend) {
            // If user dont have previous message then we need not to store the seen by time (simply return it)
            if (buddy && [buddy lastMessage] != nil && [[buddy lastMessage] status] != TUChatMessageStatusTimeSeparator) {
                [[TUChatMessageManager chatMessageManager] addMessage:message];
                TUChatMessage *tempMessage = [[TUChatMessageManager chatMessageManager] lastMessageWithUser:from];
                [message setTime:[tempMessage time]];
                
                [messagesWithTimeFormate addObject:message];
            }
            else {
                return;
            }
        }
        // If it is hidden message & it new connection
        // then add the message to database
        else if ([message status] == TUChatMessageStatusConnected) {
            // If user dont have previous message or the previous message is not time separator
            // then add a time separator
            if (buddy && ([buddy lastMessage] == nil || [[buddy lastMessage] status] != TUChatMessageStatusTimeSeparator)) {
                [messagesWithTimeFormate addObject:[[TUChatManager chatManager] storeChatTimeWithBuddy:buddy]];
            }
            
            // Finally add the actuall message to Database and get the time from database only
            // so that all the time value will be in same formate
            [[TUChatMessageManager chatMessageManager] addMessage:message];
            TUChatMessage *tempMessage = [[TUChatMessageManager chatMessageManager] lastMessageWithUser:from];
            [message setTime:[tempMessage time]];
            
            [buddy setLastMessage:message];
            
            [messagesWithTimeFormate addObject:message];
        }
        // Normal message
        else {
            // If user dont have previous message then add a time separator as a first message
            NSArray *tempMessagesArray = [[TUChatMessageManager chatMessageManager] messagesWithUser:from];
            if (buddy && [tempMessagesArray count] == 0) {
                [messagesWithTimeFormate addObject:[[TUChatManager chatManager] storeChatTimeWithBuddy:buddy]];
            }
            // If user has previous conversation message and the conversation happened before 'TUCHAT_SEPARATOR_INTERVAL_TIME'
            // the add a time separator
            else {
                TUChatMessage *lastObject = [tempMessagesArray lastObject];
                if (lastObject) {
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit)
                                                                                   fromDate:[lastObject time]
                                                                                     toDate:[NSDate date]
                                                                                    options:0];
                    if ([components minute] >= TUCHAT_SEPARATOR_INTERVAL_TIME) {
                        [messagesWithTimeFormate addObject:[[TUChatManager chatManager] storeChatTimeWithBuddy:buddy]];
                    }
                }
            }
            
            // Finally add the actuall message to Database and get the time from database only
            // so that all the time value will be in same formate
            [[TUChatMessageManager chatMessageManager] addMessage:message];
            TUChatMessage *tempMessage = [[TUChatMessageManager chatMessageManager] lastMessageWithUser:from];
            [message setTime:[tempMessage time]];
            
            [messagesWithTimeFormate addObject:message];
        }
        
        for (id<TUChatManagerDelegate>delegate in delegates) {
            if (delegate && [delegate respondsToSelector:@selector(chatManagerDidReceiveMessage:messages:)]) {
                [delegate chatManagerDidReceiveMessage:message messages:messagesWithTimeFormate];
            }
        }
        
        // Archive the recent conversation
        [self saveRecentBuddies];
        [self saveAuthorizedBuddies];
    }
}


#pragma mark - Notification Handler

- (void) logoutNotification {
    [self disconnect];
    
//    statusToChange = TUChatManagerStateOnline;

    if (isConnecting) {
        isConnecting = NO;
    }
    
    [xmppHandler clearData];
    [self clearData];
    [self setUserName:nil];
    [self setPassword:nil];
    _isCompleteBuddyFetching = NO;
    _isFailed = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TUChatManagerRecentBuddiesArchiveKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TUChatManagerAuthorizedBuddiesArchiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
