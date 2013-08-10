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
#define BARBUTTON_TITLE_FONT                                [UIFont fontWithName:@"Archer-Bold" size:16.0f]
#define BARBUTTON_TITLE_COLOR                               [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:121.0/255.0 alpha:1.0]
#define BARBUTTON_TITLE_SHADOW_COLOR                        [UIColor whiteColor]
#define BARBUTTON_TITLE_COLOR_HIGHLIGHTED                   [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:121.0/255.0 alpha:1.0]
#define BARBUTTON_TITLE_SHADOW_COLOR_HIGHLIGHTED            [UIColor whiteColor]

typedef enum YMLBarButtonType {
    YMLBarButtonTypeNone = 0,
    YMLBarButtonTypeBack,
    YMLBarButtonTypeClose,
    YMLBarButtonTypeCancel,
    YMLBarButtonTypeDone,
    YMLBarButtonTypeNext,
    YMLBarButtonTypePrevious,
    YMLBarButtonTypeSave,
    YMLBarButtonTypeCustomView,
}YMLBarButtonType;

@interface YMLBarButton : UIButton

//Usual init method with BarButtonType
- (id) initWithBarButtonType:(YMLBarButtonType)buttonType;

//User can add there custom view in NavigationBar using this init method
- (id) initWithCustomView:(UIView *)customView;

//Set the horizontal padding to the button
- (void) setHorizontalPadding:(CGFloat)padding;

@end
