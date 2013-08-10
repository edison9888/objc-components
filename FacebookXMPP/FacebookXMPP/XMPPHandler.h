//
//  XMPPHandler.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/22/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"


@protocol XMPPHandlerConnectionDelegate, XMPPHandlerBuddyDelegate, XMPPHandlerChatDelegate;
@class XMPPStreamFacebook;

@interface XMPPHandler : NSObject <XMPPStreamDelegate> {
    BOOL isOpen;
    
    NSString *userName;
    
    XMPPStream *xmppStream;
//    XMPPStreamFacebook *xmppStream;
    
    id<XMPPHandlerConnectionDelegate> connectionDelegate;
    id<XMPPHandlerBuddyDelegate> buddyDelegate;
    id<XMPPHandlerChatDelegate> chatDelegate;
}

@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, retain) XMPPStream *xmppStream;
//@property (nonatomic, retain) XMPPStreamFacebook *xmppStream;
@property (nonatomic, assign) id<XMPPHandlerConnectionDelegate> connectionDelegate;
@property (nonatomic, assign) id<XMPPHandlerBuddyDelegate> buddyDelegate;
@property (nonatomic, assign) id<XMPPHandlerChatDelegate> chatDelegate;

+ (XMPPHandler *) sharedInstance;
- (BOOL)connectWithUserName:(NSString *)uname andPassword:(NSString *)pwd;
- (void)disconnect;
- (void)sendMessage:(NSString *)message to:(NSString *)to;

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

@end


//Buddy Delegate
@protocol XMPPHandlerBuddyDelegate <NSObject>

@optional
- (void) buddyDidComeOnlineWithUserID:(NSString *)userID;
- (void) buddyDidWentOfflineWithUserID:(NSString *)userID;

@end


//Chat Delegate
@protocol XMPPHandlerChatDelegate <NSObject>

@optional
- (void) chatBuddy:(NSString *)buddy composingTo:(NSString *)to;
- (void) chatDidReceiveMessage:(NSString *)message from:(NSString *)from to:(NSString *)to;

@end