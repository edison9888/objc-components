//
//  XMPPHandler.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/22/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPRosterCoreDataStorage.h"
#import "XMPPRosterMemoryStorage.h"
#import "XMPPReconnect.h"
#import "XMPPRoster.h"
#import "XMPP.h"

#ifdef IS_PRODUCTION
    #define XMPP_HOST                   @"chat.kewe.co"
    #define XMPP_SERVER_NAME            @"chat.kewe.co"
#else
    #define XMPP_HOST                   @"chat.dev.kewe.co"
    #define XMPP_SERVER_NAME            @"chat.dev.kewe.co"
#endif

#define XMPP_PORT                       5223



@protocol XMPPHandlerConnectionDelegate, XMPPHandlerBuddyDelegate, XMPPHandlerChatDelegate;

@interface XMPPHandler : NSObject <XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate, XMPPRosterDelegate, XMPPReconnectDelegate> {
    BOOL isConnected;
    
    NSString *userName, *displayName;
    
    XMPPStream *xmppStream;
    XMPPRoster *roaster;
    XMPPRosterMemoryStorage *storage;
    XMPPReconnect *reconnect;
    
}

@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, copy) NSString *userName, *displayName;
@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPRoster *roaster;
@property (nonatomic, readonly) XMPPRosterMemoryStorage *storage;
@property (nonatomic, readonly) XMPPReconnect *reconnect;


+ (XMPPHandler *) sharedInstance;

- (BOOL) connectWithUserName:(NSString *)uname andPassword:(NSString *)pwd;
- (void) setAvailable;
- (void) setUnavailable;
- (void) setAway;
- (void) setInvisible;
- (void) disconnect;
- (void) fetchBuddies;
- (void) sendPresence:(NSString *)presenceType toUser:(NSString *)to;
- (void) sendMessage:(NSString *)message to:(NSString *)to;
- (void) sendChatState:(NSString*)state to:(NSString*)to;  //@"composing", @"active"
- (void) setupStream;
- (void) clearStream;
- (void) clearData;

- (void) addConnectionDelegate:(id<XMPPHandlerConnectionDelegate>)delegate;
- (void) addBuddyDelegate:(id<XMPPHandlerBuddyDelegate>)delegate;
- (void) addChatDelegate:(id<XMPPHandlerChatDelegate>)delegate;
- (void) removeConnectionDelegate:(id<XMPPHandlerConnectionDelegate>)delegate;
- (void) removeBuddyDelegate:(id<XMPPHandlerBuddyDelegate>)delegate;
- (void) removeChatDelegate:(id<XMPPHandlerChatDelegate>)delegate;
- (void) removeAllDelegates;

@end



//Connection Delegate
@protocol XMPPHandlerConnectionDelegate <NSObject>

@optional
- (void) connectionDidConnectToServer;
- (void) connectionFailedWithError:(NSError *)error;
- (void) connectionDidReceiveError;
- (void) connectionDidAuthenticate;
- (void) connectionDidNotAuthenticate;
- (void) connectionDidDisconnectFromServer;
- (void) connectionDidTimeOut;

@end


//Buddy Delegate
@protocol XMPPHandlerBuddyDelegate <NSObject>

@optional
- (void) buddy:(NSString *)userID statusChanged:(NSString *)status withNickName:(NSString *)nickName;
- (void) buddy:(NSString *)userID didReceiveInteruption:(NSString *)interuptionState;
- (void) buddyDidReceiveChatRequest:(NSString *)userID;
- (void) buddyDidRejectedByUser:(NSString *)userID;
- (void) buddyDidReceiveUnsubscribe:(NSString *)userID;

@end


//Chat Delegate
@protocol XMPPHandlerChatDelegate <NSObject>

@optional
- (void) chatBuddy:(NSString *)buddy chatstate:(NSString *)chatstate;
- (void) chatDidReceiveMessage:(NSString *)message from:(NSString *)from to:(NSString *)to;
- (void) chatDidSentMessage:(NSString *)message to:(NSString *)to;
- (void) chatDidReceiveRosterChange:(XMPPRosterMemoryStorage *)rosterStorage;

@end