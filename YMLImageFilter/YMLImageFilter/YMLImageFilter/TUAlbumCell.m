//
//  TUAlbumCell.m
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 4/29/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUAlbumCell.h"

#import <QuartzCore/QuartzCore.h>

@interface TUAlbumCell () {
    UILabel *countLabel;
}

@end

@implementation TUAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [backgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"bg_albumcell" withExtension:@"png"]]];
        [self setBackgroundView:backgroundView];
        
        UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [selectedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"bg_albumcell_hl" withExtension:@"png"]]];
        [self setSelectedBackgroundView:selectedBackgroundView];
        
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        [accessoryView setContentMode:UIViewContentModeCenter];
        [accessoryView setImage:[UIImage imageNameInBundle:@"camera_accessoryview" withExtension:@"png"]];
        [self setAccessoryView:accessoryView];
        
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        [countLabel setBackgroundColor:[UIColor colorWith255Red:149 green:149 blue:149 alpha:1.0]];
        [countLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10]];
        [[countLabel layer] setCornerRadius:4.0];
        [countLabel setTextAlignment:NSTextAlignmentCenter];
        [countLabel setTextColor:WHITE_COLOR];
        [self addSubview:countLabel];
        
        [[self textLabel] setTextColor:WHITE_COLOR];
        [[self textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
        
        [[self imageView] setClipsToBounds:YES];
        [[self imageView] setContentMode:UIViewContentModeCenter];
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
    
    [countLabel sizeToFit];
    CGRect rect = [countLabel frame];
    rect.origin.x = self.innerWidth - 50;
    rect.origin.y = ([self bounds].size.height - rect.size.height) * 0.5;
    rect.size.width += 4;
    
    if (rect.size.height < 17) {
        rect.size.height = 17;
    }
    
    if (rect.size.width < 17) {
        rect.size.width = 17;
    }
    
    [countLabel setFrame:rect];
    
    rect = [[self imageView] frame];
    rect.origin.x = 10;
    rect.origin.y = (self.innerHeight - 52) * 0.5;
    rect.size.height = 52;
    rect.size.width = 52;
    [[self imageView] setFrame:rect];
    
    rect = [[self textLabel] frame];
    rect.origin.x = 72;
    [[self textLabel] setFrame:rect];
}


#pragma mark - Public Methods

- (void) setCount:(NSUInteger)count {
    [countLabel setText:[NSString stringWithFormat:@"%d", count]];
}


#pragma mark - Dealloc

- (void) dealloc {
    countLabel = nil;
}

@end
