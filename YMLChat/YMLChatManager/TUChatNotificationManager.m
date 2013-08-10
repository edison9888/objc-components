//
//  TUChatNotificationManager.m
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/14/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUChatNotificationManager.h"
#import "TUChatManager.h"
#import "YMLBarButton.h"

NSString *TUChatNotification = @"TUChatNotification";

static TUChatNotificationManager *chatNotificationManager = nil;

@interface TUChatNotificationManager () <TUChatManagerDelegate> {
    NSMutableArray *barButtons, *chatScreenBarButtons;
}

- (void) barButtonSelected:(YMLBarButton *)button;
- (void) updateBarButtons;
- (void) updateActivityButtons;
- (void) signInNotification;
- (void) signOutNotification;
- (void) remoteNotificationReceived:(NSNotification *)notification;
- (void) activityViewedNotification:(NSNotification *)notification;
- (void) activityBadgeNumberNotification:(NSNotification *)notification;

@end


@implementation TUChatNotificationManager

@synthesize delegate;

+ (TUChatNotificationManager *) chatNotificationManager {
    if (chatNotificationManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            chatNotificationManager = [[[self class] alloc] init];
        });
    }
    
    return chatNotificationManager;
}


#pragma mark - Singleton Override Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (chatNotificationManager == nil) {
        chatNotificationManager = [super allocWithZone:zone];
        return chatNotificationManager;
    }
    
    return nil;
}

+ (id) copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Init

- (id) init {
    self = [super init];
    if (self) {
        _allNotificationsCount = 0;
        _fromNotificationsCount = 0;
        barButtons = [[NSMutableArray alloc] init];
        chatScreenBarButtons = [[NSMutableArray alloc] init];
        
        [[TUChatManager chatManager] addDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signOutNotification)
                                                     name:(NSString *)TUCurrentUserSignOutNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signOutNotification)
                                                     name:(NSString *)TUCurrentUserTokenExpireNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signInNotification)
                                                     name:(NSString *)TUCurrentUserSignInNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(signInNotification)
                                                     name:(NSString *)TUCurrentUserSignUpNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(remoteNotificationReceived:)
                                                     name:(NSString *)TUApplicationDidReceiveRemoteNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activityBadgeNumberNotification:)
                                                     name:(NSString *)TUApplicationDidReceivedActivityBadgeNumberNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activityViewedNotification:)
                                                     name:(NSString *)TUApplicationDidActivityViewedNotification
                                                   object:nil];
    }
    
    return self;
}


#pragma mark - Public Notification

- (YMLBarButton *) barButtonWithType:(TUChatNotificationButtonType)type {
    YMLBarButton *barButton = nil;
    BOOL needsNotification = YES;
    
    switch (type) {
        case TUChatNotificationButtonTypeChat: {
            barButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeChat];
            [barButton setBadgeAlignment:YMLBarButtonBadgeAlignmentLeft];
        }
        break;
            
        case TUChatNotificationButtonTypeChatScreen: {
            barButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeChat];
            [barButton setBadgeAlignment:YMLBarButtonBadgeAlignmentLeft];
        }
        break;
            
        case TUChatNotificationButtonTypeMenuRound: {
            barButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeCircle];
            [barButton setImage:[UIImage imageNameInBundle:@"ico_menu_white" withExtension:@"png"] forState:UIControlStateNormal];
        }
        break;

        case TUChatNotificationButtonTypeMenu: {
            barButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeMenu];
        }
        break;
            
        default:
            break;
    }
    
    if (barButton) {
        [barButton addTarget:self action:@selector(barButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        if (needsNotification) {
            if (type == TUChatNotificationButtonTypeChatScreen) {
                [barButton setBadgeNumber:_allNotificationsCount];
                [chatScreenBarButtons addObject:barButton];
            }
            else {
                if ([barButton type] == YMLBarButtonTypeMenu) {
                    [barButton setBadgeNumber:[[self appDelegate] activitiesCount]];
                }
                else {
                    [barButton setBadgeNumber:_fromNotificationsCount];
                }
                [barButtons addObject:barButton];
            }
        }
    }
    
    return barButton;
}

- (void) removeBarButton:(YMLBarButton *)barButton {
    if (barButton) {
        if ([barButtons containsObject:barButton]) {
            [barButtons removeObject:barButton];
        }
        else if ([chatScreenBarButtons containsObject:barButton]) {
            [chatScreenBarButtons removeObject:barButton];
        }
    }
}


#pragma mark - Private Methods

- (void) barButtonSelected:(YMLBarButton *)button {
    if (delegate) {
        TUChatNotificationButtonType type;
        
        if ([button type] == YMLBarButtonTypeMenu || [button type] == YMLBarButtonTypeCircle) {
            type = TUChatNotificationButtonTypeMenu;
        }
        else if ([button type] == YMLBarButtonTypeChat) {
            type = TUChatNotificationButtonTypeChat;
        }
        
        if ([delegate respondsToSelector:@selector(chatNotificationManagerDidSelectBarButton:ofType:)]) {
            [delegate chatNotificationManagerDidSelectBarButton:button ofType:type];
        }
    }
}

- (void) updateBarButtons {
    NSUInteger allNotificationsCount = 0;
    NSUInteger fromNotificationsCount = 0;
    if ([[TUChatManager chatManager] needsNotificationUpdate:&allNotificationsCount fromCount:&fromNotificationsCount]) {
        _fromNotificationsCount = fromNotificationsCount;
        _allNotificationsCount = allNotificationsCount;
        
        for (YMLBarButton *barButton in barButtons) {
            if ([barButton type] == YMLBarButtonTypeMenu) {
                [barButton setBadgeNumber:[[self appDelegate] activitiesCount]];
            }
            else {
                [barButton setBadgeNumber:_fromNotificationsCount];
            }
        }
        
        for (YMLBarButton *barButton in chatScreenBarButtons) {
            [barButton setBadgeNumber:_allNotificationsCount];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TUChatNotification object:[NSNumber numberWithInt:_allNotificationsCount]];
        [[TUChatManager chatManager] resetNotificationUpdate];
    }
}

- (void) updateActivityButtons {
    for (YMLBarButton *barButton in barButtons) {
        if ([barButton type] == YMLBarButtonTypeMenu) {
            [barButton setBadgeNumber:[[self appDelegate] activitiesCount]];
        }
    }
}

- (void) signInNotification {
    [[TUChatManager chatManager] removeDelegate:self];
    [[TUChatManager chatManager] addDelegate:self];
}

- (void) signOutNotification {
    delegate = nil;
    _allNotificationsCount = 0;
    _fromNotificationsCount = 0;
    [barButtons removeAllObjects];
    [chatScreenBarButtons removeAllObjects];
}

- (void) activityBadgeNumberNotification:(NSNotification *)notification {
    [self updateActivityButtons];
}

- (void) remoteNotificationReceived:(NSNotification *)notification {
    [self updateActivityButtons];
}

- (void) activityViewedNotification:(NSNotification *)notification {
    [self updateActivityButtons];
}


#pragma mark - TUChat Delegate

- (void) chatManagerDidFinishFetchingBuddies {
    [self updateBarButtons];
}

- (void) chatManagerDidReceiveMessage:(TUChatMessage *)message messages:(NSArray *)messages {
    [self updateBarButtons];
}

- (void) chatManagerDidChangeUserPresence:(TUBuddy *)user fromStatus:(TUBuddyStatus)fromStatus {
    [self updateBarButtons];
}

- (void) chatManagerDidOpenChatWithBuddy:(TUBuddy *)user {
    [self updateBarButtons];
}

- (void) chatManagerDidReceiveChatRequest:(TUBuddy *)user {
    [self updateBarButtons];
}

- (void) chatManagerDidRejectRequest:(TUBuddy *)user {
    [self updateBarButtons];
}

- (void) chatManagerDidUnsubscribeBuddy:(TUBuddy *)user {
    [self updateBarButtons];
}

- (void) chatManagerDidResetUnread {
    [self updateBarButtons];
}

@end
