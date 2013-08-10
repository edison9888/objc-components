//
//  TUBuddy.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TUBuddyStatus {
    TUBuddyStatusOffline = 0,
    TUBuddyStatusOnline,
    TUBuddyStatusAway,
    TUBuddyStatusInvisible,
    TUBuddyStatusCurrentSession,
    TUBuddyStatusRequestSent,
    TUBuddyStatusRequestReceived,
}TUBuddyStatus;

@class TUChatMessage;

@interface TUBuddy : NSObject <NSCoding> {
    TUBuddyStatus status;
    NSUInteger unreadMessagesCount;
    
    NSString *jID, *userID, *name;
    TUChatMessage *lastMessage;
}

@property (nonatomic, assign) TUBuddyStatus status;
@property (nonatomic, readwrite) NSUInteger unreadMessagesCount;
@property (nonatomic, copy) NSString *jID, *userID, *name;
@property (nonatomic, strong) TUChatMessage *lastMessage;

@end
