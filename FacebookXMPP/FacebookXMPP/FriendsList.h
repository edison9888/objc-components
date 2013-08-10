//
//  FriendsList.h
//  FacebookXMPP
//
//  Created by Sumit Mehra on 12/20/11.
//  Copyright (c) 2011 Dealclan LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsList : NSObject {
    NSMutableDictionary *friends, *onlineFriends, *offlineFriends;
}

@property (nonatomic, retain) NSMutableDictionary *friends, *onlineFriends, *offlineFriends;

+ (FriendsList *) sharedInstance;

- (void) createFriendsListWithArray:(NSArray *)friendsList;
- (void) friendCameOnlineWithID:(NSString *)uid;
- (void) friendWentOfflineWithID:(NSString *)uid;
- (NSString *) facebookChatIDForUserID:(NSString *)uid;
- (NSString *) userIDFromFacebookChatID:(NSString *)chatID;
- (NSDictionary *) presentUserDetails;

@end
