//
//  YMLLeftPanGestureRecognizer.h
//  Tourean
//
//  Created by Karthik Keyan B on 12/1/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_OPTIONS(NSUInteger, YMLPanGestureRecognizerDirection) {
    YMLPanGestureRecognizerLeft = 0,
    YMLPanGestureRecognizerRight,
    YMLPanGestureRecognizerUp,
    YMLPanGestureRecognizerDown,
};

@interface YMLPanGestureRecognizer : UIGestureRecognizer {
    BOOL isLocked;
    
    CGFloat value, startValue;
    
    YMLPanGestureRecognizerDirection direction;
}

@property (nonatomic, readonly) BOOL isLocked;
@property (nonatomic, readonly) CGFloat value, startValue;
@property (nonatomic, assign) YMLPanGestureRecognizerDirection direction;

+ (BOOL) isVerticalDirection:(YMLPanGestureRecognizerDirection)direction;

- (BOOL) isVerticalDirection;
- (void) forceEnd;


@end
