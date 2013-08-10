//
//  FriendsList.m
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/20/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import "FriendsList.h"


static FriendsList *sharedInstance;

@implementation FriendsList

@synthesize friends, onlineFriends, offlineFriends;

+ (FriendsList *) sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[FriendsList alloc] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            
            return sharedInstance;
        }
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain{
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


- (void) createFriendsListWithArray:(NSArray *)friendsList {
    friends = [[NSMutableDictionary alloc] init];
    onlineFriends = [[NSMutableDictionary alloc] init];
    offlineFriends = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *friend in friendsList) {
        NSString *key = [NSString stringWithFormat:@"%@", [friend objectForKey:@"uid"]];
        [friends setObject:friend forKey:key];
        
        //Initially all friends will be offline.
        //For each friends came online, friendCameOnlineWithID: will get call. 
        //There we will delete the online friends from the offline dictionary.
        [offlineFriends setObject:friend forKey:key];
    }
}

- (void) friendCameOnlineWithID:(NSString *)uid {
    NSArray *uidArray = [uid componentsSeparatedByString:@"@"];
    uid = [[uidArray objectAtIndex:0] substringFromIndex:1];
    NSString *key = [NSString stringWithFormat:@"%@", uid];
    
    [onlineFriends setObject:[friends objectForKey:key] forKey:key];
    if ([offlineFriends objectForKey:key]) {
        [offlineFriends removeObjectForKey:key];
    }
}

- (void) friendWentOfflineWithID:(NSString *)uid {
    NSArray *uidArray = [uid componentsSeparatedByString:@"@"];
    uid = [[uidArray objectAtIndex:0] substringFromIndex:1];
    NSString *key = [NSString stringWithFormat:@"%@", uid];
    
    [offlineFriends setObject:[friends objectForKey:key] forKey:key];
    if ([onlineFriends objectForKey:key]) {
        [onlineFriends removeObjectForKey:key];
    }
}

- (NSString *) facebookChatIDForUserID:(NSString *)uid {
    return [NSString stringWithFormat:@"-%@@chat.facebook.com", uid];
}

- (NSString *) userIDFromFacebookChatID:(NSString *)chatID {
    NSArray *uidArray = [chatID componentsSeparatedByString:@"@"];
    return [[uidArray objectAtIndex:0] substringFromIndex:1];
}

- (NSDictionary *) presentUserDetails {
    NSString *key = [[friends allKeys] lastObject];
    return [friends objectForKey:key];
}

- (void)dealloc {
    if (friends) { [friends release]; }
    friends = nil;
    
    if (onlineFriends) { [onlineFriends release]; }
    onlineFriends = nil;
    
    if (offlineFriends) { [offlineFriends release]; }
    offlineFriends = nil;
    
    [super dealloc];
}

@end
