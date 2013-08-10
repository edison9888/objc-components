//
//  YMLAlertView.m
//  parentgini
//
//  Created by Karthik Keyan B on 9/27/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "YMLAlertView.h"

#define ReleaseObject(object)               ([object release], object = nil)
#define CONTENTVIEW_INSET                   27.0

@interface YMLAlertView () {
    NSMutableArray *buttons;
    
    UILabel *messageLabel;
    
    YMLAlertViewDismiss dismissBlock;
}

@property (nonatomic, copy) YMLAlertViewDismiss dismissBlock;

- (void) buttonTapped:(id)sender;
- (void) hide;
- (CGFloat) controlSpacesHorizontal;
- (CGFloat) controlSpacesVertical;
- (CGFloat) contentViewInset;
- (void) extraLayout;

@end

@implementation YMLAlertView

@synthesize buttonHeight, cancelButtonIndex;
@synthesize buttonTitles, buttonImages;
@synthesize buttonTextInset, buttonImageInset;
@synthesize buttonFont, messageFont, cancelButtonFont;
@synthesize buttonFontColor, messageFontColor, cancelButtonColor;
@synthesize buttonBackgroundImage;
@synthesize backgroundView, contentBackgroundView;
@synthesize delegate;
@synthesize dismissBlock;

- (id) init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero];
}

- (id) initWithFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] applicationFrame];
    self = [super initWithFrame:frame];
    if (self) {
        cancelButtonIndex = -1;
        buttonHeight = 30;
        buttons = [[NSMutableArray alloc] init];
        buttonTextInset = UIEdgeInsetsZero;
        buttonImageInset = UIEdgeInsetsZero;
        
        [self setAlpha:0.0];
        
        CGFloat controlSpacesHorizontal = [self controlSpacesHorizontal];
        CGFloat controlSpacesVertical = [self controlSpacesVertical];
        CGFloat contentViewInset = [self contentViewInset];
        
        // Faded Background
        backgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [backgroundView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
        [self addSubview:backgroundView];
        [backgroundView release];
        
        // View for message text and buttons
        CGRect rect = CGRectMake(contentViewInset, (self.bounds.size.height - 150)/2, self.bounds.size.width - (contentViewInset * 2), 150);
        contentBackgroundView = [[UIImageView alloc] initWithFrame:rect];
        [contentBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [contentBackgroundView setUserInteractionEnabled:YES];
        [self addSubview:contentBackgroundView];
        [contentBackgroundView release];
        
        // Message Label
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(controlSpacesHorizontal, controlSpacesVertical, contentBackgroundView.bounds.size.width - (controlSpacesHorizontal * 2), 20)];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setShadowColor:[UIColor whiteColor]];
        [messageLabel setShadowOffset:CGSizeMake(0, 1)];
        [messageLabel setTextAlignment:UITextAlignmentCenter];
        [messageLabel setNumberOfLines:999];
        [contentBackgroundView addSubview:messageLabel];
        [messageLabel release];
    }
    return self;
}


#pragma mark - Public Methods

- (void) setBackground:(UIImage *)background {
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [backgroundView setImage:background];
}

- (void) setContentBackground:(UIImage *)contentBackground {
    [contentBackgroundView setBackgroundColor:[UIColor clearColor]];
    [contentBackgroundView setImage:contentBackground];
}

- (void) setMessage:(NSString *)message {
    if (messageFont) {
        [messageLabel setFont:messageFont];
    }
    
    if (messageFontColor) {
        [messageLabel setTextColor:messageFontColor];
    }
    
    CGSize size = [message sizeWithFont:[messageLabel font] constrainedToSize:CGSizeMake(messageLabel.frame.size.width, self.bounds.size.height) lineBreakMode:[messageLabel lineBreakMode]];
    CGRect rect = [messageLabel frame];
    rect.size.height = size.height;
    
    [messageLabel setFrame:rect];    
    [messageLabel setText:message];
}

- (void) show {
    [self show:nil];
}

- (void) show:(YMLAlertViewDismiss)dismiss {
    [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (dismiss) {
        [self setDismissBlock:dismiss];
    }
    
    CGFloat controlSpacesHorizontal = [self controlSpacesHorizontal];
    CGFloat controlSpacesVertical = [self controlSpacesVertical];
    CGFloat buttonSpaces = 10.0;
    
    int y = messageLabel.frame.origin.y + messageLabel.frame.size.height + 12;
    
    for (int i = 0; i < [buttonTitles count]; i++) {
        NSString *title = [buttonTitles objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:(buttonBackgroundImage)?UIButtonTypeCustom:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(controlSpacesHorizontal, y, contentBackgroundView.bounds.size.width - (controlSpacesHorizontal * 2), buttonHeight)];
        [button setTag:(i + 1)];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [contentBackgroundView addSubview:button];
        
        if (buttonBackgroundImage) {
            [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        }
        
        if (buttonFont) {
            [[button titleLabel] setFont:(i == cancelButtonIndex && cancelButtonFont)?cancelButtonFont:buttonFont];
        }
        
        if (buttonFontColor) {
            [button setTitleColor:(i == cancelButtonIndex && cancelButtonColor)?cancelButtonColor:buttonFontColor forState:UIControlStateNormal];
        }
        
        if (buttonImages && [buttonImages count] > i) {
            UIImage *image = [buttonImages objectAtIndex:i];
            [button setImage:image forState:UIControlStateNormal];
            
            CGRect imageFrame = button.imageView.frame;
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -(imageFrame.origin.x + imageFrame.size.width)/2, 0, 0)];
            
            CGRect titleFrame = button.titleLabel.frame;
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleFrame.origin.x + titleFrame.size.width + 5, 0, 0)];
        }
        else {
            [button setTitleEdgeInsets:buttonTextInset];
            [button setImageEdgeInsets:buttonImageInset];
        }
        
        y += (buttonHeight + buttonSpaces);
    }
    
    CGRect rect = [contentBackgroundView frame];
    rect.size.height = y + (controlSpacesVertical - buttonSpaces);
    rect.origin.y = (self.bounds.size.height - rect.size.height)/2;
    [contentBackgroundView setFrame:rect];
    
    [self extraLayout];
    
    if (![self superview]) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }
    
    [UIView animateWithDuration:0.25 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseIn 
                     animations:^{
                         [self setAlpha:1.0];
                     } 
                     completion:nil];
}


#pragma mark - Private Methods

- (void) buttonTapped:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(alertView:dismissWithButtonIndex:andButtonTitle:)]) {
        [delegate alertView:self dismissWithButtonIndex:([sender tag] - 1) andButtonTitle:[sender titleForState:UIControlStateNormal]];
    }
    
    if (dismissBlock) {
        dismissBlock(([sender tag] - 1), [sender titleForState:UIControlStateNormal]);
    }
    
    [self hide];
}

- (void) hide {
    [UIView animateWithDuration:0.25 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseOut 
                     animations:^{
                         [self setAlpha:0.0];
                     } 
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (CGFloat) controlSpacesHorizontal {
    return 10.0;
}

- (CGFloat) controlSpacesVertical {
    return 20.0;
}

- (CGFloat) contentViewInset {
    return 10.0;
}

- (void) extraLayout {
    
}


#pragma mark - Dealloc

- (void)dealloc {
    ReleaseObject(buttons);
    
    if (buttonTitles) {
        ReleaseObject(buttonTitles);
    }
    
    if (buttonImages) {
        ReleaseObject(buttonImages);
    }
    
    if (dismissBlock) {
        ReleaseObject(dismissBlock);
    }
    
    if (buttonBackgroundImage) {
        ReleaseObject(buttonBackgroundImage);
    }
    
    if (buttonFont) {
        ReleaseObject(buttonFont);
    }
    
    if (messageFont) {
        ReleaseObject(messageFont);
    }
    
    if (buttonFontColor) {
        ReleaseObject(buttonFontColor);
    }
    
    if (messageFontColor) {
        ReleaseObject(messageFontColor);
    }
    
    if (cancelButtonFont) {
        ReleaseObject(cancelButtonFont);
    }
    
    if (cancelButtonColor) {
        ReleaseObject(cancelButtonColor);
    }
    
    backgroundView = nil;
    contentBackgroundView = nil;
    messageLabel = nil;
    delegate = nil;
    
    [super dealloc];
}

@end
