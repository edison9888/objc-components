//
//  TUBuddy.m
//  Tourea
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUChatMessage.h"
#import "TUBuddy.h"

@implementation TUBuddy

@synthesize status;
@synthesize unreadMessagesCount;
@synthesize jID, userID, name;
@synthesize lastMessage;

- (id) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        status = [coder decodeIntegerForKey:@"status"];
        unreadMessagesCount = [coder decodeIntegerForKey:@"unreadedMessagesCount"];
        jID = [coder decodeObjectForKey:@"jID"];
        userID = [coder decodeObjectForKey:@"userID"];
        name = [coder decodeObjectForKey:@"name"];
        lastMessage = [coder decodeObjectForKey:@"lastMessage"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:status forKey:@"status"];
    [coder encodeInteger:unreadMessagesCount forKey:@"unreadedMessagesCount"];
    [coder encodeObject:jID forKey:@"jID"];
    [coder encodeObject:userID forKey:@"userID"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:lastMessage forKey:@"lastMessage"];
}

@end
