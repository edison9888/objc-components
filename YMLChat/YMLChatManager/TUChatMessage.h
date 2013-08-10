//
//  TUChatMessage.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TUChatMessageStatus {
    TUChatMessageStatusReaded = 0,          // Readed
    TUChatMessageStatusUnReaded,            // Unrread
    TUChatMessageStatusTimeSeparator,       // Separator
    TUChatMessageStatusReadedByFriend,      // Seen by
    TUChatMessageStatusLastReceived,        // Time ago
    TUChatMessageStatusConnected,           // Chat Bubble color change
}TUChatMessageStatus;

@interface TUChatMessage : NSObject<NSCoding> {
    BOOL isSent, isOfflineMessage;
    
    TUChatMessageStatus status;
    
    NSString *rowID, *from, *to, *message;
    NSDate *time;
}

@property (nonatomic, readwrite) BOOL isSent, isOfflineMessage;
@property (nonatomic, assign) TUChatMessageStatus status;
@property (nonatomic, copy) NSString *rowID, *from, *to, *message;
@property (nonatomic, copy) NSDate *time;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (void) parseDictionary:(NSDictionary *)dictionary;
- (NSString *) messageBetween;

@end
