//
//  BarButton.h
//  sartorii
//
//  Created by Sumit Mehra on 1/25/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

//BarButtons for the NavigationBar
//The enum BarButtonType can be extendable to create new BarButton style

//In init method we are using switch-case to set the button background image and frame
//Before that we need a button background images

#import <UIKit/UIKit.h>

#define NAVIGATIONBAR_HEIGHT                                44.0
#define BARBUTTON_TITLE_FONT                                [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]
#define BARBUTTON_TITLE_COLOR                               [UIColor whiteColor]
#define BARBUTTON_TITLE_SHADOW_COLOR                        [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]
#define BARBUTTON_TITLE_COLOR_HIGHLIGHTED                   [UIColor whiteColor]
#define BARBUTTON_TITLE_SHADOW_COLOR_HIGHLIGHTED            [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]

typedef enum YMLBarButtonType {
    YMLBarButtonTypeNone = 0,
    YMLBarButtonTypeBack,
    YMLBarButtonTypeStream,
    YMLBarButtonTypeSolidStream,
    YMLBarButtonTypeGradiantBack,
    YMLBarButtonTypeGreenPlus,
    YMLBarButtonTypeCircle,
    YMLBarButtonTypeCircleBack,
    YMLBarButtonTypeClose,
    YMLBarButtonTypeCancel,
    YMLBarButtonTypeMenu,
    YMLBarButtonTypeSettings,
    YMLBarButtonTypeSearch,
    YMLBarButtonTypeChat,
    YMLBarButtonTypeRefresh,
    YMLBarButtonTypeEmptyDone,
    YMLBarButtonTypeEmptyNormal,
    YMLBarButtonTypeCustomView,
    YMLBarButtonTypeEmptyLeftArrowed,
    YMLBarButtonTypeEmptyBorder,
}YMLBarButtonType;

typedef enum YMLBarButtonBadgeAlignment {
    YMLBarButtonBadgeAlignmentRight = 0,
    YMLBarButtonBadgeAlignmentLeft
}YMLBarButtonBadgeAlignment;

@interface YMLBarButton : UIButton {
    YMLBarButtonBadgeAlignment badgeAlignment;
    YMLBarButtonType type;
}

@property (nonatomic, readwrite) YMLBarButtonBadgeAlignment badgeAlignment;
@property (nonatomic, readonly) YMLBarButtonType type;

//Usual init method with BarButtonType
- (id) initWithBarButtonType:(YMLBarButtonType)buttonType;

//User can add there custom view in NavigationBar using this init method
- (id) initWithCustomView:(UIView *)customView;

//Set the horizontal padding to the button
- (void) setHorizontalPadding:(CGFloat)padding;

- (void) setText:(NSString *)text;
- (NSString *) text;

- (void) setBadgeNumber:(NSUInteger)number;
- (void) setBadgeIcon:(UIImage *)icon;
- (NSUInteger) badgeNumber;

@end
