//
//  TUChatNotificationManager.h
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/14/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *TUChatNotification;

typedef enum TUChatNotificationButtonType {
    TUChatNotificationButtonTypeMenu = 0,
    TUChatNotificationButtonTypeMenuRound,
    TUChatNotificationButtonTypeChat,
    TUChatNotificationButtonTypeChatScreen
}TUChatNotificationButtonType;

@class YMLBarButton;
@protocol TUChatNotificationManagerDelegate;

@interface TUChatNotificationManager : NSObject {
    id<TUChatNotificationManagerDelegate> __weak delegate;
}

@property (nonatomic, readonly) NSUInteger allNotificationsCount, fromNotificationsCount;
@property (nonatomic, weak) id<TUChatNotificationManagerDelegate> delegate;

+ (TUChatNotificationManager *) chatNotificationManager;

- (YMLBarButton *) barButtonWithType:(TUChatNotificationButtonType)type;
- (void) removeBarButton:(YMLBarButton *)barButton;

@end


@protocol TUChatNotificationManagerDelegate <NSObject>

@optional
- (void) chatNotificationManagerDidSelectBarButton:(YMLBarButton *)barButton ofType:(TUChatNotificationButtonType)type;

@end

