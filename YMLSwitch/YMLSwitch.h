//
//  CustomSwitch.h
//  fanlala
//
//  Created by Sumit Mehra on 4/24/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMLSwitch : UIControl {
    BOOL isOn, isVertical;
    
    UIImageView *backgroundView, *switchThumb;
    UILabel *onLabel, *offLabel;
}

@property (nonatomic, readwrite) BOOL isOn, isVertical;
@property (nonatomic, retain) UIImageView *backgroundView, *switchThumb;
@property (nonatomic, retain) UILabel *onLabel, *offLabel;

- (void) setIsOn:(BOOL)isOn animation:(BOOL)animation;
- (void) addTarget:(id)target action:(SEL)action;
- (void) setOnText:(NSString *)onText;
- (void) setOffText:(NSString *)offText;
- (void) setBackground:(UIImage *)background;
- (void) setThumb:(UIImage *)thumb;
- (void) setVertical:(BOOL)vertical;
- (void) layoutControlForVertical:(BOOL)vertical;

@end
