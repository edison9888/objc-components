//
//  XMPPHandler.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/22/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "XMPPHandler.h"
#import "XMPPStream.h"
//#import "XMPPStreamFacebook.h"

static XMPPHandler *xmppHandler = nil;
NSString *password;

@interface XMPPHandler () 

- (void) setupStream;
- (void) goOffline;
- (void) goOnline;

@end

@implementation XMPPHandler

@synthesize userName;
@synthesize xmppStream;
@synthesize connectionDelegate;
@synthesize buddyDelegate;
@synthesize chatDelegate;


#pragma mark Singleton Class Method

+ (XMPPHandler *) sharedInstance {
    if (xmppHandler == nil) {
        xmppHandler = [[XMPPHandler alloc] init];
    }
    
    return xmppHandler;
}


#pragma mark - Singleton Prevention Methods

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (xmppHandler == nil) {
            xmppHandler = [super allocWithZone:zone];
            
            return xmppHandler;
        }
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (id)autorelease {
    return self;
}

- (oneway void)release {
    //Nothing
}


#pragma mark - Private Methods

- (void)setupStream {   
    if (!xmppStream) {
//        xmppStream = [[XMPPStream alloc] initWithFacebookAppId:FacebookKey];
//        xmppStream = [[XMPPStreamFacebook alloc] initWithFacebookAppId:FacebookKey];
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}


#pragma mark - Public Methods

- (BOOL)connectWithUserName:(NSString *)uname andPassword:(NSString *)pwd {
    userName = uname;
    password = pwd;
    
    [self setupStream];
    
    [xmppStream setMyJID:[XMPPJID jidWithString:userName]];
        
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSError *error;
    if (![xmppStream connect:&error]) {
        if ([connectionDelegate respondsToSelector:@selector(connectionFailedWithError:)]) {
            [connectionDelegate connectionFailedWithError:error];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    [xmppStream disconnect];
    [self goOffline];
    
    if ([connectionDelegate respondsToSelector:@selector(connectionDidDisconnectFromServer)]) {
        [connectionDelegate connectionDidDisconnectFromServer];
    }
}

- (void)sendMessage:(NSString *)message to:(NSString *)to {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:message];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:to];
    [messageElement addChild:body];
    
    [xmppStream sendElement:messageElement];
}


#pragma mark - XMPP Connection

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    isOpen = YES;
    
    if ([connectionDelegate respondsToSelector:@selector(connectionDidConnectToServer)]) {
        [connectionDelegate connectionDidConnectToServer];
    }
    
//    [xmppStream authenticateWithPassword:password error:nil];
    NSError *error;
    
    if (![xmppStream authenticateWithPassword:password error:&error]) {
        if ([connectionDelegate respondsToSelector:@selector(connectionFailedWithError:)]) {
            [connectionDelegate connectionFailedWithError:error];
        }
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {    
    if ([connectionDelegate respondsToSelector:@selector(connectionDidNotAuthenticate)]) {
        [connectionDelegate connectionDidNotAuthenticate];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
    
    if ([connectionDelegate respondsToSelector:@selector(connectionDidAuthenticate)]) {
        [connectionDelegate connectionDidAuthenticate];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {  
    NSLog(@"%@", error);
    if ([connectionDelegate respondsToSelector:@selector(connectionDidReceiveError)]) {
        [connectionDelegate connectionDidReceiveError];
    }
}

//- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
//    
//}

- (void)xmppStreamDidStartNegotiation:(XMPPStream *)sender {
    
}


#pragma mark - XMPP Buddy

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceFromUser = [[presence attributeForName:@"from"] stringValue];
    
    if ([[presence type] isEqualToString:@"available"]) {        
        if ([buddyDelegate respondsToSelector:@selector(buddyDidComeOnlineWithUserID:)]) {
            [buddyDelegate buddyDidComeOnlineWithUserID:presenceFromUser];
        }
    }
    else if ([[presence type] isEqualToString:@"unavailable"]) {        
        if ([buddyDelegate respondsToSelector:@selector(buddyDidWentOfflineWithUserID:)]) {
            [buddyDelegate buddyDidWentOfflineWithUserID:presenceFromUser];
        }
    }
}


#pragma mark - XMPP Message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *to = [[message attributeForName:@"to"] stringValue];
    
    DDXMLElement *composing = [message elementForName:@"composing"];
    if (composing) {
        if ([chatDelegate respondsToSelector:@selector(chatBuddy:composingTo:)]) {
            [chatDelegate chatBuddy:from composingTo:to];
        }
    }
    else {
        NSString *messageContent = [[message elementForName:@"body"] stringValue];
        
        if ([chatDelegate respondsToSelector:@selector(chatDidReceiveMessage:from:to:)]) {
            [chatDelegate chatDidReceiveMessage:messageContent from:from to:to];
        }
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    userName = nil;
    password = nil;
    
    if (xmppStream) { [xmppStream release]; }
    xmppStream = nil;
    
    connectionDelegate = nil;
    buddyDelegate = nil;
    chatDelegate = nil;
    
    [super dealloc];
}


@end
