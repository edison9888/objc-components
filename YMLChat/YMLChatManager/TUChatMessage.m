//
//  TUChatMessage.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/31/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUChatMessage.h"

@implementation TUChatMessage

@synthesize isSent, isOfflineMessage;
@synthesize status;
@synthesize rowID, from, to, message;
@synthesize time;

- (id) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        rowID = [coder decodeObjectForKey:@"rowID"];
        status = [coder decodeIntegerForKey:@"status"];
        isSent = [coder decodeBoolForKey:@"isSent"];
        from = [coder decodeObjectForKey:@"from"];
        to = [coder decodeObjectForKey:@"to"];
        message = [coder decodeObjectForKey:@"message"];
        time = [coder decodeObjectForKey:@"time"];
        isOfflineMessage = [coder decodeBoolForKey:@"isOfflineMessage"];
    }
    
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self parseDictionary:dictionary];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:rowID forKey:@"rowID"];
    [coder encodeInteger:status forKey:@"status"];
    [coder encodeBool:isSent forKey:@"isSent"];
    [coder encodeObject:from forKey:@"from"];
    [coder encodeObject:to forKey:@"to"];
    [coder encodeObject:message forKey:@"message"];
    [coder encodeObject:time forKey:@"time"];
    [coder encodeBool:isOfflineMessage forKey:@"isOfflineMessage"];
}

- (void) parseDictionary:(NSDictionary *)dictionary {
    NSString *messageBetween = [dictionary objectForKey:@"message_between"];
    NSArray *users = [messageBetween componentsSeparatedByString:@"-"];
    
    [self setRowID:[NSString stringFromObject:[dictionary objectForKey:@"rowid"]]];
    [self setFrom:[users objectAtIndex:0]];
    [self setTo:[users objectAtIndex:1]];
    [self setStatus:[[dictionary objectForKey:@"message_status"] intValue]];
    [self setTime:[NSDate convertStringToDate:[dictionary objectForKey:@"message_time"] fromFormat:@"yyyy-MM-dd HH:mm:ss"]];
    [self setMessage:[[dictionary objectForKey:@"message_content"] urlDecodedString]];
    [self setIsSent:[[dictionary objectForKey:@"message_isout"] intValue]];
    [self setIsOfflineMessage:[[dictionary objectForKey:@"message_isoffline"] intValue]];

    [self setTime:[[self time] convertToSystemTimeZone]];
}

- (NSString *) messageBetween {
    return [[NSString stringWithFormat:@"%@-%@", from, to] lowercaseString];
}

@end
