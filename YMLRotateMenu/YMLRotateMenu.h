//
//  CircleView.h
//  Rotate
//
//  Created by Sumit Mehra on 4/21/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLRotateMenuText.h"

#define IS_DEV                  NO

@protocol YMLRotateMenuDelegate;

@interface YMLRotateMenu : UIView {
    BOOL isDisableTransparentArea;
    int selectedIndex;
    float currentAngle;
    double centerAngle;
    
    UIView *containerView;
    UIImageView *backgroundView, *overLayImageView;
    
    YMLRotateMenuText *circleTextView;
    
    id<YMLRotateMenuDelegate> __weak delegate;
}

@property (nonatomic, readwrite) BOOL disableTransparentArea;
@property (nonatomic, readonly) int selectedIndex;
@property (nonatomic, readwrite) double centerAngle;
@property (nonatomic) YMLRotateMenuText *circleTextView;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIImageView *backgroundView, *overLayImageView;
@property (nonatomic, weak) id<YMLRotateMenuDelegate> delegate;

- (void) setBackgroundImage:(UIImage *)background;
- (void) selectItemAtIndex:(int)index;
- (void) setOverLayImage:(UIImage *)overLayImage;

@end


@protocol YMLRotateMenuDelegate <YMLRotateMenuTextDelegate>

@required
- (NSUInteger) numberOfItemsInRotateMenu:(YMLRotateMenu *)rotateMenu;
- (NSString *) rotateMenu:(YMLRotateMenu *)rotateMenu menuItemForIndex:(NSUInteger)index;

@optional
- (void) rotateMenuDidFinishLoading:(YMLRotateMenu *)rotateMenu;
- (void) rotateMenu:(YMLRotateMenu *)rotateMenu menuItemDidSelectAtIndex:(NSUInteger)index;
- (CGFloat) rotateMenu:(YMLRotateMenu *)rotateMenu angleAdjustmentForItemAtIndex:(NSUInteger)index forTargetAngle:(CGFloat)targetAngle minimum:(CGFloat)minimum andMaximum:(CGFloat)maximum;

@end