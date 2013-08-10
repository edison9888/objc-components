//
//  TUChatManager.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUChatMessage.h"

@interface TUChatMessageManager : NSObject

+ (TUChatMessageManager *) chatMessageManager;

- (NSMutableArray *) messagesWithUser:(NSString *)userID;
- (NSMutableArray *) messagesWithUser:(NSString *)userID offset:(NSUInteger)offset limit:(int)limit;
- (TUChatMessage *) lastTextMessageWithUser:(NSString *)userID;
- (TUChatMessage *) lastMessageWithUser:(NSString *)userID;
- (BOOL) addMessage:(TUChatMessage *)message;
- (int) unreadedMessagesCountFromUser:(NSString *)userID;
- (void) setAsReadedForUser:(NSString *)userID;
- (void) clearMessagesWithUser:(NSString *)userID;
- (void) updateMessage:(TUChatMessage *)message isOffline:(BOOL)isOffline;

@end
