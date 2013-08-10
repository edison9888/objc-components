//
//  XMPPHandler.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/22/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserMemoryStorage.h"
#import "XMPPHandler.h"
#import "XMPPStream.h"
#import "XMPPUser.h"

static XMPPHandler *xmppHandler = nil;

@interface XMPPHandler () {
    BOOL isRosterFetched;
    NSString *password;
    NSMutableArray *chatDelegates, *buddyDelegates, *connectionDelegates;
}

@property (nonatomic, copy) NSString *password;

- (void) setupStream;

@end

@implementation XMPPHandler

@synthesize isConnected;
@synthesize userName, displayName;
@synthesize password;
@synthesize xmppStream;
@synthesize roaster;
@synthesize storage;
@synthesize reconnect;


#pragma mark Singleton Class Method

+ (XMPPHandler *) sharedInstance {
    if (xmppHandler == nil) {
        xmppHandler = [[XMPPHandler alloc] init];
    }
    
    return xmppHandler;
}


#pragma mark - Singleton Prevention Methods

+ (id) allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (xmppHandler == nil) {
            xmppHandler = [super allocWithZone:zone];
            
            return xmppHandler;
        }
    }
    
    return nil;
}

+ (id) copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Init

- (id) init {
    self = [super init];
    if (self) {
        chatDelegates = [[NSMutableArray alloc] init];
        buddyDelegates = [[NSMutableArray alloc] init];
        connectionDelegates = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Public Methods

- (void) setupStream {
    if (!xmppStream) {
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream setHostName:XMPP_HOST];
        [xmppStream setHostPort:XMPP_PORT];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        reconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        [reconnect activate:xmppStream];
        [reconnect setAutoReconnect:YES];
        [reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
}

- (void) clearStream {
    if (xmppStream) {
        if (reconnect) {
            [reconnect deactivate];
            [reconnect removeDelegate:self delegateQueue:dispatch_get_main_queue()];
            reconnect = nil;
        }
        
        [xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        xmppStream = nil;
        
        if (xmppStream) {
            [storage clearAllResourcesForXMPPStream:xmppStream];
            [storage clearAllUsersAndResourcesForXMPPStream:xmppStream];
        }
        
        [roaster deactivate];
        [roaster removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        roaster = nil;
        storage = nil;
        
        isConnected = NO;
        isRosterFetched = NO;
    }
}

- (void) clearData {
    [self clearStream];
    [self setDisplayName:nil];
    [self removeAllDelegates];
}

- (BOOL) connectWithUserName:(NSString *)uname andPassword:(NSString *)pwd {
    [self setUserName:[NSString stringWithFormat:@"%@@%@", uname, XMPP_SERVER_NAME]];
    [self setPassword:pwd];
    [self setupStream];
    
    [xmppStream setMyJID:[XMPPJID jidWithString:userName]];
    if (![xmppStream isDisconnected]) {
        isConnected = YES;
        return YES;
    }
    
    isConnected = NO;
    NSError *error;
    if (![xmppStream oldSchoolSecureConnect:&error]) {
        for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
            if ([connectionDelegate respondsToSelector:@selector(connectionFailedWithError:)]) {
                [connectionDelegate connectionFailedWithError:error];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void) setAvailable {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [presence addAttributeWithName:@"presence" stringValue:@"available"];
    [presence addAttributeWithName:@"name" stringValue:displayName];
    [xmppStream sendElement:presence];
}

- (void) setUnavailable {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [presence addAttributeWithName:@"presence" stringValue:@"unavailable"];
    [xmppStream sendElement:presence];
}

- (void) setAway {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"away"];
    [presence addAttributeWithName:@"presence" stringValue:@"away"];
    [presence addAttributeWithName:@"name" stringValue:displayName];
    [xmppStream sendElement:presence];
}

- (void) setInvisible {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [presence addAttributeWithName:@"presence" stringValue:@"invisible"];
    [presence addAttributeWithName:@"name" stringValue:displayName];
    [xmppStream sendElement:presence];
}

- (void)disconnect {
    [self setUnavailable];
    [xmppStream disconnect];
}

- (void) fetchBuddies {
    if (!storage) {
        storage = [[XMPPRosterMemoryStorage alloc] init];
    }
    
    if (!roaster) {
        roaster  = [[XMPPRoster alloc] initWithRosterStorage:storage];
        [roaster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    [roaster activate:xmppStream];
    [roaster setAutoRoster:YES];
    [roaster fetchRoster];
}

- (void) sendPresence:(NSString *)presenceType toUser:(NSString *)to {
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", to, XMPP_SERVER_NAME]];
    XMPPPresence *presence = [XMPPPresence presenceWithType:presenceType to:jid];
    [xmppStream sendElement:presence];
}

- (void) sendChatState:(NSString *)state to:(NSString *)to
{
    NSXMLElement *body = [NSXMLElement elementWithName:state stringValue:@"writing"];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", to, XMPP_SERVER_NAME]];
    [messageElement addChild:body];
    
    [xmppStream sendElement:messageElement];

}

- (void)sendMessage:(NSString *)message to:(NSString *)to {
    
    NSData *data = [message dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:newMessage];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", to, XMPP_SERVER_NAME]];
    [messageElement addChild:body];
    
    [xmppStream sendElement:messageElement];
}

- (void) addConnectionDelegate:(id<XMPPHandlerConnectionDelegate>)delegate {
    if (delegate && ![connectionDelegates containsObject:delegate]) {
        [connectionDelegates addObject:delegate];
    }
}

- (void) addBuddyDelegate:(id<XMPPHandlerBuddyDelegate>)delegate {
    if (delegate && ![buddyDelegates containsObject:delegate]) {
        [buddyDelegates addObject:delegate];
    }
}

- (void) addChatDelegate:(id<XMPPHandlerChatDelegate>)delegate {
    if (delegate && ![chatDelegates containsObject:delegate]) {
        [chatDelegates addObject:delegate];
    }
}

- (void) removeConnectionDelegate:(id<XMPPHandlerConnectionDelegate>)delegate {
    if (delegate && [connectionDelegates containsObject:delegate]) {
        [connectionDelegates removeObject:delegate];
    }
}

- (void) removeBuddyDelegate:(id<XMPPHandlerBuddyDelegate>)delegate {
    if (delegate && [buddyDelegates containsObject:delegate]) {
        [buddyDelegates removeObject:delegate];
    }
}

- (void) removeChatDelegate:(id<XMPPHandlerChatDelegate>)delegate {
    if (delegate && [chatDelegates containsObject:delegate]) {
        [chatDelegates removeObject:delegate];
    }
}

- (void) removeAllDelegates {
    [connectionDelegates removeAllObjects];
    [buddyDelegates removeAllObjects];
    [chatDelegates removeAllObjects];
}


#pragma mark - XMPP Connection

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    isConnected = YES;
    
    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
        if ([connectionDelegate respondsToSelector:@selector(connectionDidConnectToServer)]) {
            [connectionDelegate connectionDidConnectToServer];
        }
    }
    
    NSError *error;
    if (![xmppStream authenticateWithPassword:password error:&error]) {
        for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
            if ([connectionDelegate respondsToSelector:@selector(connectionFailedWithError:)]) {
                [connectionDelegate connectionFailedWithError:error];
            }
        }
    }
}

//- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
//    isConnected = NO;
//    
//    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
//        if ([connectionDelegate respondsToSelector:@selector(connectionDidDisconnectFromServer)]) {
//            [connectionDelegate connectionDidDisconnectFromServer];
//        }
//    }
//}
//<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized/></failure>
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
        if ([connectionDelegate respondsToSelector:@selector(connectionDidNotAuthenticate)]) {
            [connectionDelegate connectionDidNotAuthenticate];
        }
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
        if ([connectionDelegate respondsToSelector:@selector(connectionDidAuthenticate)]) {
            [connectionDelegate connectionDidAuthenticate];
        }
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {
    TLog(@"XMPP Error : %@", error);
    
    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
        if ([connectionDelegate respondsToSelector:@selector(connectionDidReceiveError)]) {
            [connectionDelegate connectionDidReceiveError];
        }
    }
}


#pragma mark - XMPP Buddy

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    TLog(@"%@", presence);
    NSString *presenceFromUser = [[presence attributeForName:@"from"] stringValue];
    NSString *presenceType = [presence attributeStringValueForName:@"presence"];
    
    if (presenceType) {
        if (presenceFromUser && ![presence isErrorPresence]) {
            for (id<XMPPHandlerBuddyDelegate>buddyDelegate in buddyDelegates) {
                if ([buddyDelegate respondsToSelector:@selector(buddy:statusChanged:withNickName:)]) {
                    [buddyDelegate buddy:presenceFromUser statusChanged:presenceType withNickName:[presence attributeStringValueForName:@"name"]];
                }
            }
        }
    }
    // Unsubscribe - Disconnect
    else if ([[presence type] isEqualToString:@"unsubscribe"]) {
        for (id<XMPPHandlerBuddyDelegate>buddyDelegate in buddyDelegates) {
            if ([buddyDelegate respondsToSelector:@selector(buddyDidReceiveUnsubscribe:)]) {
                [buddyDelegate buddyDidReceiveUnsubscribe:presenceFromUser];
            }
        }
    }
    // Unsubscribed - Reject
    else if ([[presence type] isEqualToString:@"unsubscribed"]) {
        for (id<XMPPHandlerBuddyDelegate>buddyDelegate in buddyDelegates) {
            if ([buddyDelegate respondsToSelector:@selector(buddyDidRejectedByUser:)]) {
                [buddyDelegate buddyDidRejectedByUser:presenceFromUser];
            }
        }
    }
    // Unavailable - only happen when app terminated (like crash or quit) after unsubscribed 
    else if ([[presence type] isEqualToString:@"unavailable"]) {
        for (id<XMPPHandlerBuddyDelegate>buddyDelegate in buddyDelegates) {
            if ([buddyDelegate respondsToSelector:@selector(buddy:didReceiveInteruption:)]) {
                [buddyDelegate buddy:presenceFromUser didReceiveInteruption:@"unavailable"];
            }
        }
    }
}


#pragma mark - XMPP Message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *to = [[message attributeForName:@"to"] stringValue];
    
    DDXMLElement *composing = [message elementForName:@"composing"];
    if (composing) {
        for (id<XMPPHandlerChatDelegate>chatDelegate in chatDelegates) {
            if ([chatDelegate respondsToSelector:@selector(chatBuddy:chatstate:)]) {
                [chatDelegate chatBuddy:from chatstate:@"composing"];
            }
        }
    }
    
    DDXMLElement *activeChatState = [message elementForName:@"active"];
    if (activeChatState) {
        for (id<XMPPHandlerChatDelegate>chatDelegate in chatDelegates) {
            if ([chatDelegate respondsToSelector:@selector(chatBuddy:composingTo:)]) {
                [chatDelegate chatBuddy:from chatstate:@"active"];
            }
        }
    }
    else {
        NSString *messageContent = [[message elementForName:@"body"] stringValue];
        NSData *data = [messageContent dataUsingEncoding:NSUTF8StringEncoding];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        for (id<XMPPHandlerChatDelegate>chatDelegate in chatDelegates) {
            if ([chatDelegate respondsToSelector:@selector(chatDidReceiveMessage:from:to:)]) {
                [chatDelegate chatDidReceiveMessage:msg from:from to:to];
            }
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    if ([message elementsForName:@"body"] && [[message elementsForName:@"body"] count] > 0) {
        NSString *messageString = [[[message elementsForName:@"body"] objectAtIndex:0] stringValue];
        NSString *to = [[message attributeForName:@"to"] stringValue];
        
        NSData *data = [messageString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        for (id<XMPPHandlerChatDelegate>chatDelegate in chatDelegates) {
            if ([chatDelegate respondsToSelector:@selector(chatDidSentMessage:to:)]) {
                [chatDelegate chatDidSentMessage:msg to:to];
            }
        }
    }
}


#pragma mark - Roaster Delegate

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
    NSString *from = [[presence attributeForName:@"from"] stringValue];
    NSString *to = [[XMPPJID jidWithString:[[presence attributeForName:@"to"] stringValue]] bare];
    
    if ([to isEqualToString:userName]) {
        for (id<XMPPHandlerBuddyDelegate>buddyDelegate in buddyDelegates) {
            if ([buddyDelegate respondsToSelector:@selector(buddyDidReceiveChatRequest:)]) {
                [buddyDelegate buddyDidReceiveChatRequest:from];
            }
        }
    }
}

- (void) xmppRosterDidChange:(XMPPRosterMemoryStorage *)rosterStorage {
    if (isConnected && !isRosterFetched) {
        isRosterFetched = YES;
        
        for (id<XMPPHandlerChatDelegate>chatDelegate in chatDelegates) {
            if ([chatDelegate respondsToSelector:@selector(chatDidReceiveRosterChange:)]) {
                [chatDelegate chatDidReceiveRosterChange:rosterStorage];
            }
        }
    }
}


#pragma mark - Reconnect Delegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    isConnected = NO;
    isRosterFetched = NO;
    
    if (xmppStream) {
        [storage clearAllResourcesForXMPPStream:xmppStream];
        [storage clearAllUsersAndResourcesForXMPPStream:xmppStream];
    }
    
    [roaster deactivate];
    [roaster removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    roaster = nil;
    storage = nil;
    
    for (id<XMPPHandlerConnectionDelegate>connectionDelegate in connectionDelegates) {
        if ([connectionDelegate respondsToSelector:@selector(connectionDidTimeOut)]) {
            [connectionDelegate connectionDidTimeOut];
        }
    }
}

- (BOOL) xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    return YES;
}

@end
