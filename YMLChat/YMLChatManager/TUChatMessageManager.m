//
//  TUChatManager.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUChatMessageManager.h"
#import "TUDataBase.h"

#define TU_MESSAGE_TABLE                @"message_history"

static TUChatMessageManager *chatMessageManager = nil;

@implementation TUChatMessageManager

+ (TUChatMessageManager *) chatMessageManager {
    if (chatMessageManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            chatMessageManager = [[[self class] alloc] init];
        });
    }
    
    return chatMessageManager;
}


#pragma mark - Singleton Override Methods

+ (id)allocWithZone:(NSZone *)zone {
    if (chatMessageManager == nil) {
        chatMessageManager = [super allocWithZone:zone];
        return chatMessageManager;
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Public Methods

- (NSMutableArray *) messagesWithUser:(NSString *)userID {
    return [self messagesWithUser:userID offset:0 limit:-1];
}

- (NSMutableArray *) messagesWithUser:(NSString *)userID offset:(NSUInteger)offset limit:(int)limit {
    NSString *userName = [[[TUCurrentUser currentUser] userName] lowercaseString];
    
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userName, userID];
    NSString *messageBetween2 = [NSString stringWithFormat:@"%@-%@", userID, userName];
    
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    NSMutableArray *messagesDict = nil;
    if (limit < 0) {
        messagesDict = [dataBase resultSetForQuery:[NSString stringWithFormat:@"select rowid, * from %@ where message_between = '%@' OR message_between = '%@' ORDER BY rowid DESC", TU_MESSAGE_TABLE, messageBetween, messageBetween2]];
    }
    else {
        messagesDict = [dataBase resultSetForQuery:[NSString stringWithFormat:@"select rowid, * from %@ where message_between = '%@' OR message_between = '%@' ORDER BY rowid DESC LIMIT %d, %d", TU_MESSAGE_TABLE, messageBetween, messageBetween2, offset, limit]];
    }
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([messagesDict count] > 0) {
        for (NSDictionary *message in messagesDict) {
            TUChatMessage *chatMessage = [[TUChatMessage alloc] initWithDictionary:message];
            [messages insertObject:chatMessage atIndex:0];
        }
    }
    
    return messages;
}

- (TUChatMessage *) lastTextMessageWithUser:(NSString *)userID {
    NSString *userName = [[[TUCurrentUser currentUser] userName] lowercaseString];
    
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userName, userID];
    NSString *messageBetween2 = [NSString stringWithFormat:@"%@-%@", userID, userName];
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    
    NSMutableArray *messages = [dataBase resultSetForQuery:[NSString stringWithFormat:@"select rowid, * from %@ where (message_between = '%@' OR message_between = '%@') AND (message_status = %d OR message_status = %d OR message_status = %d) ORDER BY rowid DESC limit 1", TU_MESSAGE_TABLE, messageBetween, messageBetween2, TUChatMessageStatusReaded, TUChatMessageStatusUnReaded, TUChatMessageStatusConnected]];
    
    TUChatMessage *chatMessage = [[TUChatMessage alloc] init];
    if ([messages count] > 0) {
        [chatMessage parseDictionary:[messages objectAtIndex:0]];
    }
    else {
        [chatMessage setTo:userID];
    }
    
    return chatMessage;
}

- (TUChatMessage *) lastMessageWithUser:(NSString *)userID {
    NSString *userName = [[[TUCurrentUser currentUser] userName] lowercaseString];
    
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userName, userID];
    NSString *messageBetween2 = [NSString stringWithFormat:@"%@-%@", userID, userName];
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    NSMutableArray *messages = [dataBase resultSetForQuery:[NSString stringWithFormat:@"select rowid, * from %@ where message_between = '%@' OR message_between = '%@' ORDER BY rowid DESC limit 1", TU_MESSAGE_TABLE, messageBetween, messageBetween2]];
    
    TUChatMessage *chatMessage = [[TUChatMessage alloc] init];
    if ([messages count] > 0) {
        [chatMessage parseDictionary:[messages objectAtIndex:0]];
    }
    else {
        [chatMessage setTo:userID];
    }
    
    return chatMessage;
}

// message_between VARCHAR, message_time NOT NULL DEFAULT CURRENT_TIMESTAMP, message_status int, message_content varchar, message_isout int
- (BOOL) addMessage:(TUChatMessage *)message {
    NSMutableString *qstr = [NSMutableString stringWithString:@"insert into message_history (message_between, message_status, message_content, message_isout, message_isoffline) values ("];
    [qstr appendFormat:@"'%@'", [message messageBetween]];
    [qstr appendFormat:@", %d", [message status]];
    [qstr appendFormat:@", '%@'", [[message message] urlEncode]];
    [qstr appendFormat:@", %d", [message isSent]];
    [qstr appendFormat:@", %d", [message isOfflineMessage]];
    [qstr appendString:@")"];
    
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    return [dataBase executeQuery:qstr];
}

- (int) unreadedMessagesCountFromUser:(NSString *)userID {
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userID, [[[TUCurrentUser currentUser] userName] lowercaseString]];
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    NSMutableArray *messages = [dataBase resultSetForQuery:[NSString stringWithFormat:@"select count(*) count from %@ where message_between = '%@' and message_status = %d", TU_MESSAGE_TABLE, messageBetween, TUChatMessageStatusUnReaded]];
    
    int count = 0;
    
    if ([messages count] > 0) {
        count = [[[messages objectAtIndex:0] objectForKey:@"count"] intValue];
    }
    
    return count;
}

- (void) setAsReadedForUser:(NSString *)userID {
    NSString *userName = [[[TUCurrentUser currentUser] userName] lowercaseString];
    
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userID, userName];
    NSString *messageBetween2 = [NSString stringWithFormat:@"%@-%@", userName, userID];
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    [dataBase executeQuery:[NSString stringWithFormat:@"update %@ set message_status = %d where (message_between = '%@' or message_between = '%@') and message_status = %d", TU_MESSAGE_TABLE, TUChatMessageStatusReaded, messageBetween, messageBetween2, TUChatMessageStatusUnReaded]];
}

- (void) clearMessagesWithUser:(NSString *)userID {
    NSString *userName = [[[TUCurrentUser currentUser] userName] lowercaseString];
    
    NSString *messageBetween = [NSString stringWithFormat:@"%@-%@", userID, userName];
    NSString *messageBetween2 = [NSString stringWithFormat:@"%@-%@", userName, userID];
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    [dataBase executeQuery:[NSString stringWithFormat:@"delete from %@ where message_between = '%@' or message_between = '%@'", TU_MESSAGE_TABLE, messageBetween, messageBetween2]];
}

- (void) updateMessage:(TUChatMessage *)message isOffline:(BOOL)isOffline {
    TUDataBase *dataBase = [[TUDataBase alloc] init];
    [dataBase executeQuery:[NSString stringWithFormat:@"update %@ set message_isoffline = %d where rowid = '%@'", TU_MESSAGE_TABLE, isOffline, [message rowID]]];
}

@end
