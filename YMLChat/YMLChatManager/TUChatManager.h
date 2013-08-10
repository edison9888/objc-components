//
//  TUChatStateManager.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/2/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUChatMessage.h"
#import "TUBuddy.h"

#define TUCHAT_SEPARATOR_INTERVAL_TIME      15

extern NSString *TUChatManagerMessageTypeKey;
extern NSString *TUChatManagerDateTypeKey;
extern NSString *TUChatManagerMessageKey;
extern NSString *TUChatManagerRecentBuddiesArchiveKey;
extern NSString *TUChatManagerAuthorizedBuddiesArchiveKey;

typedef enum TUChatManagerState {
    TUChatManagerStateOffline = 0,
    TUChatManagerStateOnline,
    TUChatManagerStateAway,
    TUChatManagerStateInvisible
}TUChatManagerState;


typedef enum TUAvailableUserStatus {
    TUAvailableUserStatusPending            = 1 << 1,
    TUAvailableUserStatusCurrentSession     = 1 << 2,
    TUAvailableUserStatusOnline             = 1 << 3,
    TUAvailableUserStatusAway               = 1 << 4,
    TUAvailableUserStatusOffline            = 1 << 5,
    TUAvailableUserStatusInvisible          = 1 << 6,
}TUAvailableUserStatus;


@protocol TUChatManagerDelegate;

@interface TUChatManager : NSObject {
    BOOL isConnecting;
    TUChatManagerState state;
    
    NSMutableDictionary *allBuddies;
    
    TUBuddy *currentBuddy;
}

@property (nonatomic, readonly) BOOL isConnecting, isCompleteBuddyFetching, isFailed;
@property (nonatomic, readwrite) TUChatManagerState state;
@property (nonatomic, readonly) NSMutableDictionary *allBuddies;
@property (nonatomic, strong) TUBuddy *currentBuddy;

+ (TUChatManager *) chatManager;

// Connections
- (void) connect;
- (void) disconnect;
- (BOOL) isConnected;
- (BOOL) isCredentialsAvailable;
- (void) setUserName:(NSString *)userName password:(NSString *)password;
- (void) sendPresence:(TUChatManagerState)presence toUserWithID:(NSString *)userID;
- (void) sleep;
- (void) awake;

// Delegate
- (void) addDelegate:(id<TUChatManagerDelegate>)delegate;
- (void) addDelegates:(NSArray *)delegates;
- (void) removeDelegate:(id<TUChatManagerDelegate>)delegate;
- (void) removeDelegates:(NSArray *)delegates;

// Messaging
- (void) composingToBuddy:(TUBuddy *)to;
- (TUChatMessage *) sendOfflineMessage:(NSString *)_message toBuddy:(TUBuddy *)to;
- (TUChatMessage *) sendMessage:(NSString *)message toBuddy:(TUBuddy *)to;
- (void) retryMessage:(TUChatMessage *)message;
- (void) sendHiddenMessage:(NSDictionary *)message toBuddy:(TUBuddy *)buddy;
- (TUChatMessage *) storeChatTimeWithBuddy:(TUBuddy *)to;
- (TUChatMessage *) messageObjectFromMessage:(NSString *)message toBuddy:(TUBuddy *)to isSent:(BOOL)isSent;
- (TUChatMessage *) saveMessage:(TUChatMessage *)message isSent:(BOOL)isSent;

// Buddy
- (void) changeBuddy:(TUBuddy *)buddy toStatus:(TUBuddyStatus)status;
- (void) openChatWithBuddy:(TUBuddy *)buddy;
- (void) markAsReadedForBuddy:(TUBuddy *)buddy;
- (NSMutableArray *) chatHistoryWithBuddy:(TUBuddy *)buddy offset:(NSUInteger)offset limit:(int)limit;
- (void) clearHistoryWithBuddy:(TUBuddy *)buddy;

// Chat Request
- (void) requestChatPermission:(NSString*)to nickName:(NSString *)nickName;
- (void) acceptChatPermission:(NSString*)to;
- (void) rejectChatPermission:(NSString*)to;
- (void) unsubscribe:(NSString*)to;
- (void) cancelRequest:(NSString *)to;

// Extras
- (void) resetUnreadCount;
- (NSUInteger) availableUserStatus:(TUAvailableUserStatus *)status;
- (NSUInteger) buddiesCountForStatus:(TUAvailableUserStatus)status;
- (NSArray *) buddiesForStatus:(TUAvailableUserStatus)status;
- (NSMutableArray *) authorizedBuddies;
- (NSMutableArray *) recentBuddies;
- (BOOL) isAuthorizedBuddy:(NSString *)userID;
- (UIImage *) iconForStatus:(TUBuddyStatus)status;
- (TUBuddy *) buddyForUserID:(NSString *)userID;
- (BOOL) isUserOnline:(NSString *)userID;
- (BOOL) needsNotificationUpdate:(NSUInteger *)count fromCount:(NSUInteger *)fromCount;
- (void) resetNotificationUpdate;
- (void) networkInterrupted;

@end


@protocol TUChatManagerDelegate <NSObject>

@optional
- (void) chatManagerDidFinishAuthentication;
- (void) chatManagerDidFinishFetchingBuddies;
- (void) chatManagerDidNotAuthentication;
- (void) chatManagerDidReceiveMessage:(TUChatMessage *)message messages:(NSArray *)messages;
- (void) chatManagerDidReceiveUserCompose:(TUBuddy *)user;
- (void) chatManagerDidChangeUserPresence:(TUBuddy *)user fromStatus:(TUBuddyStatus)fromStatus;
- (void) chatManagerDidOpenChatWithBuddy:(TUBuddy *)user;
- (void) chatManagerDidUnsubscribeBuddy:(TUBuddy *)user;
- (void) chatManagerDidReceiveChatRequest:(TUBuddy *)user;
- (void) chatManagerDidRejectRequest:(TUBuddy *)user;
- (void) chatManagerDidRequestRejectedBy:(TUBuddy *)user;
- (void) chatManagerDidDisconnect;
- (void) chatManagerDidResetUnread;
- (void) chatManagerDidClearUserData;

@end
