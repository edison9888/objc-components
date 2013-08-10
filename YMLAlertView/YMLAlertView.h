//
//  YMLAlertView.h
//  parentgini
//
//  Created by Karthik Keyan B on 9/27/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMLAlertViewDelegate;
typedef void (^YMLAlertViewDismiss) (NSUInteger buttonIndex, NSString *buttonTitle);

@interface YMLAlertView : UIView {
    NSUInteger buttonHeight, cancelButtonIndex;
    NSArray *buttonTitles, *buttonImages;
    
    UIEdgeInsets buttonTextInset, buttonImageInset;
    UIFont *buttonFont, *messageFont, *cancelButtonFont;
    UIColor *buttonFontColor, *messageFontColor, *cancelButtonColor;
    UIImage *buttonBackgroundImage;
    UIImageView *backgroundView, *contentBackgroundView;
    
    id<YMLAlertViewDelegate> delegate;
}

@property (nonatomic, assign) NSUInteger buttonHeight, cancelButtonIndex;
@property (nonatomic, retain) NSArray *buttonTitles, *buttonImages;
@property (nonatomic, assign) UIEdgeInsets buttonTextInset, buttonImageInset;
@property (nonatomic, retain) UIFont *buttonFont, *messageFont, *cancelButtonFont;
@property (nonatomic, retain) UIColor *buttonFontColor, *messageFontColor, *cancelButtonColor;
@property (nonatomic, retain) UIImage *buttonBackgroundImage;
@property (nonatomic, readonly) UIImageView *backgroundView, *contentBackgroundView;
@property (nonatomic, assign) id<YMLAlertViewDelegate> delegate;

- (void) setBackground:(UIImage *)background;
- (void) setContentBackground:(UIImage *)contentBackground;
- (void) setMessage:(NSString *)message;
- (void) show;
- (void) show:(YMLAlertViewDismiss)dismiss;

@end


@protocol YMLAlertViewDelegate <NSObject>

@optional
- (void) alertView:(YMLAlertView *)alertView dismissWithButtonIndex:(NSUInteger)buttonIndex andButtonTitle:(NSString *)buttonTitle;

@end
