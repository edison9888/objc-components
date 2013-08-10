//
//  YMLTouchableScrollView.h
//  Shutterfly
//
//  Created by Karthik Keyan B on 6/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMLTouchableScrollViewDelegate;

@interface YMLTouchableScrollView : UIScrollView {
    id<YMLTouchableScrollViewDelegate> touchDelegate;
}

@property (nonatomic, assign) id<YMLTouchableScrollViewDelegate> touchDelegate;

@end


@protocol YMLTouchableScrollViewDelegate <NSObject>

@optional
- (void) touchableScrollView:(YMLTouchableScrollView *)touchableScrollView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchableScrollView:(YMLTouchableScrollView *)touchableScrollView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchableScrollView:(YMLTouchableScrollView *)touchableScrollView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchableScrollView:(YMLTouchableScrollView *)touchableScrollView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
