//
//  TUFollowersTableViewCell.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/26/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUUsersTableViewCell.h"
#import "TULabel.h"

#import <QuartzCore/QuartzCore.h>

@interface TUUsersTableViewCell () {
    CALayer *backgroundLayer, *bottomLineLayer;
}

- (void) followButtonClicked;
- (void) accessoryButtonPressed;

@end

@implementation TUUsersTableViewCell

@synthesize isFollowing;
@synthesize indexPath;
@synthesize delegate;
@synthesize userLabel, locationLabel;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 35, 35)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setImage:[UIImage imageNameInBundle:@"ico_user" withExtension:@"png"]];
        [imageView setClipsToBounds:YES];
        [[imageView layer] setCornerRadius:4.0f];
        [self addSubview:imageView];
        
        
        userLabel = [[TULabel alloc] initWithFrame:CGRectMake(47, 8, 138, 16)];
        [userLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
        [userLabel setTextColor:[UIColor blackColor]];
        [self addSubview:userLabel];
        
        locationLabel = [[TULabel alloc] initWithFrame:CGRectMake(userLabel.left, userLabel.bottom + 2, userLabel.width, 20)];
        [locationLabel setImage:[UIImage imageNameInBundle:@"ico_location3" withExtension:@"png"]];
        [locationLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:8]];
        [locationLabel setTextColor:[UIColor colorWith255Red:64 green:64 blue:64 alpha:1.0]];
        [self addSubview:locationLabel];
        
        followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followButton setFrame:CGRectMake(self.width - (89), (self.innerHeight - 31) * 0.5, 77, 31)];
        [followButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn_green3" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[followButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
        [followButton setTitle:NSLocalizedString(@"Follow", @"") forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(followButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:followButton];
        
        accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [accessoryButton setFrame:CGRectMake(0, 0, 30, 30)];
//        [accessoryButton setImage:[UIImage imageNameInBundle:@"ico_composemoreoptions" withExtension:@"png"] forState:UIControlStateNormal];
//        [accessoryButton setBackgroundImage:[UIImage imageNameInBundle:@"bg_composeoptions" withExtension:@"png"] forState:UIControlStateNormal];
        [accessoryButton setFrame:CGRectMake(0, 0, 18, 19)];
        [accessoryButton setImage:[UIImage imageNameInBundle:@"ico_accessoryarrow" withExtension:@"png"] forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(accessoryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        
        backgroundLayer = [CALayer layer];
        [backgroundLayer setFrame:CGRectMake(0, 0, self.innerWidth, self.innerHeight)];
        [[self layer] insertSublayer:backgroundLayer below:[imageView layer]];
        
        bottomLineLayer = [CALayer layer];
        [bottomLineLayer setBackgroundColor:[[UIColor colorWith255Red:215 green:215 blue:215 alpha:1.0] CGColor]];
        [bottomLineLayer setFrame:CGRectMake(0, self.innerHeight - 2, self.innerWidth, 2)];
        [[self layer] insertSublayer:bottomLineLayer below:[imageView layer]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if ([imageView image]) {
        [imageView setFrame:CGRectMake(12, (self.innerHeight - 35) * 0.5, 35, 35)];
    }
    else {
        [imageView setFrame:CGRectMake(12, (self.innerHeight - 35) * 0.5, 0, 0)];
    }
    
    [userLabel setFrame:CGRectMake(imageView.right + 12, (self.innerHeight - 16) * 0.5, 138, 16)];
    [followButton setFrame:CGRectMake(self.width - (89), (self.innerHeight - 31) * 0.5, 77, 31)];
    
    [locationLabel setFrame:CGRectMake(userLabel.left, userLabel.bottom + 2, userLabel.width, 20)];
    [locationLabel sizeToFit];
    
    if ([locationLabel text]) {
        [locationLabel setHidden:NO];
    }
    else {
        [locationLabel setHidden:YES];
        
    }
    
    [backgroundLayer setFrame:CGRectMake(0, 0, self.innerWidth, self.innerHeight)];
    [bottomLineLayer setFrame:CGRectMake(0, self.innerHeight - 2, self.innerWidth, 2)];
}


#pragma mark - Setter Methods

- (void) setFollowing:(BOOL)following {
    if (isFollowing != following) {
        isFollowing = following;
        
        if (isFollowing) {
            [followButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn_green4" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
            [followButton setTitle:NSLocalizedString(@"Following", @"") forState:UIControlStateNormal];
        }
        else {
            [followButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn_green3" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
            [followButton setTitle:NSLocalizedString(@"Follow", @"") forState:UIControlStateNormal];
        }
    }
}


#pragma mark - Private Methods

- (void) followButtonClicked {
    if (isFollowing) {
        if ([delegate respondsToSelector:@selector(usersTableViewCell:didSelectUnfollowAtIndexPath:)]) {
            [delegate usersTableViewCell:self didSelectUnfollowAtIndexPath:indexPath];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(usersTableViewCell:didSelectFollowAtIndexPath:)]) {
            [delegate usersTableViewCell:self didSelectFollowAtIndexPath:indexPath];
        }
    }
}

- (void) accessoryButtonPressed {
    if ([delegate respondsToSelector:@selector(usersTableViewCell:didSelectAccessoryButtonAtIndexPath:)]) {
        [delegate usersTableViewCell:self didSelectAccessoryButtonAtIndexPath:indexPath];
    }
}


#pragma mark - Public Methods

- (void) setName:(NSString *)name {
    [userLabel setText:name];
}

- (void) setLocation:(NSString *)location {
    [locationLabel setText:location];
}

- (void) setProfileImage:(UIImage *)image {
    [imageView setImage:image];
}

- (void) setFollowButtonTitle:(NSString *)title {
    [followButton setTitle:title forState:UIControlStateNormal];
}

- (void) setEnableFollowButton:(BOOL)enable {
    [followButton setEnabled:enable];
}

- (void) setHideFollowButton:(BOOL)hide {
    [followButton setHidden:hide];
}

- (void) setHighlightFollowButton {
    [followButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn_green4" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
}

- (void) setNormalFollowButton {
    [followButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_btn_green3" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
}

- (void) setEnableAccessoryView:(BOOL)enable {
    if (enable) {
        [self setAccessoryView:accessoryButton];
    }
    else {
        [self setAccessoryView:nil];
    }
}

- (void) setBackgroundLayerColor:(CGColorRef)color {
    [backgroundLayer setBackgroundColor:color];
}

- (void) setSeperatorLayerColor:(CGColorRef)color {
    [bottomLineLayer setBackgroundColor:color];
}

- (void) setAccessoryImage:(UIImage *)image {
    [accessoryButton setImage:image forState:UIControlStateNormal];
}


#pragma mark - Dealloc

- (void) dealloc {
    userLabel = nil;
    locationLabel = nil;
    followButton = nil;
    imageView = nil;
}

@end
