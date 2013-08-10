//
//  TUFollowersTableViewCell.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/26/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TULabel;
@protocol TUUsersTableViewCellDelegate;

@interface TUUsersTableViewCell : UITableViewCell {
    BOOL isFollowing;
    NSIndexPath *indexPath;
    
    UIImageView *imageView;
    UIButton *followButton, *accessoryButton;
    __weak id<TUUsersTableViewCellDelegate> delegate;
    TULabel *userLabel, *locationLabel;
}

@property (nonatomic, readwrite, setter = setFollowing:) BOOL isFollowing;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) TULabel *userLabel, *locationLabel;
@property (nonatomic, weak) id<TUUsersTableViewCellDelegate> delegate;

- (void) setName:(NSString *)name;
- (void) setLocation:(NSString *)location;
- (void) setProfileImage:(UIImage *)image;
- (void) setFollowButtonTitle:(NSString *)title;
- (void) setEnableFollowButton:(BOOL)enable;
- (void) setHideFollowButton:(BOOL)hide;
- (void) setHighlightFollowButton;
- (void) setNormalFollowButton;
- (void) setEnableAccessoryView:(BOOL)enable;
- (void) setBackgroundLayerColor:(CGColorRef)color;
- (void) setSeperatorLayerColor:(CGColorRef)color;
- (void) setAccessoryImage:(UIImage *)image;

@end

@protocol TUUsersTableViewCellDelegate <NSObject>

@optional
- (void) usersTableViewCell:(TUUsersTableViewCell *)cell didSelectFollowAtIndexPath:(NSIndexPath *)indexPath;
- (void) usersTableViewCell:(TUUsersTableViewCell *)cell didSelectUnfollowAtIndexPath:(NSIndexPath *)indexPath;
- (void) usersTableViewCell:(TUUsersTableViewCell *)cell didSelectAccessoryButtonAtIndexPath:(NSIndexPath *)indexPath;

@end
