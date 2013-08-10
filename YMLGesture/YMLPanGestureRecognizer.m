//
//  YMLLeftPanGestureRecognizer.m
//  Tourean
//
//  Created by Karthik Keyan B on 12/1/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "YMLPanGestureRecognizer.h"

static BOOL isLocked;

@interface YMLPanGestureRecognizer () {
    CGPoint startPoint;
}

@end


@implementation YMLPanGestureRecognizer

@synthesize isLocked;
@synthesize direction;
@synthesize value, startValue;


#pragma mark - Class Methods

+ (BOOL) isLocked {
    return isLocked;
}

+ (void) setLocked:(BOOL)locked {
    isLocked = locked;
}

+ (BOOL) isVerticalDirection:(YMLPanGestureRecognizerDirection)direction {
    return (direction == YMLPanGestureRecognizerUp || direction == YMLPanGestureRecognizerDown);
}


#pragma mark - Touch Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self state] == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if ([[event touchesForGestureRecognizer:self] count] > 1) {
        [self setState:UIGestureRecognizerStateFailed];
    }
    
    startPoint = [[touches anyObject] locationInView:[self view]];
    startValue = ([YMLPanGestureRecognizer isVerticalDirection:direction])?startPoint.y:startPoint.x;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint newPoint = [[touches anyObject] locationInView:[self view]];
    
    if (!CGRectContainsPoint([[self view] frame], newPoint)) {
        [self setState:UIGestureRecognizerStateCancelled];
        return;
    }
    
    YMLPanGestureRecognizerDirection movingDirection;
    
    if (![YMLPanGestureRecognizer isLocked]) {
        CGFloat xDelta = newPoint.x - startPoint.x;
        CGFloat yDelta = newPoint.y - startPoint.y;
        
        // Moving Horizontally
        if (ABS(xDelta) > ABS(yDelta)) {            
            // Moving towards Left Side
            if (xDelta < 0) {
                movingDirection = YMLPanGestureRecognizerLeft;
            }
            // Moving towards Right Side
            else {
                movingDirection = YMLPanGestureRecognizerRight;
            }
        }
        // Moving Vertically
        else {            
            // Moving towards Up Side
            if (yDelta < 0) {
                movingDirection = YMLPanGestureRecognizerUp;
            }
            // Moving towards Down Side
            else {
                movingDirection = YMLPanGestureRecognizerDown;
            }
        }
        
        value = ([YMLPanGestureRecognizer isVerticalDirection:movingDirection])?newPoint.y:newPoint.x;
        
        if (movingDirection == direction) {
            if ([self state] == UIGestureRecognizerStatePossible) {
                isLocked = YES;
                [YMLPanGestureRecognizer setLocked:YES];
                
                [self setState:UIGestureRecognizerStateBegan];
            }
            else {
                [self setState:UIGestureRecognizerStateFailed];
            }
        }
        else {
            [self setState:UIGestureRecognizerStateFailed];
        }
    }
    else {
        if ([self state] == UIGestureRecognizerStateBegan || [self state] == UIGestureRecognizerStateChanged) {
            value = ([YMLPanGestureRecognizer isVerticalDirection:direction])?newPoint.y:newPoint.x;
            
            [self setState:UIGestureRecognizerStateChanged];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateCancelled];
}


#pragma mark - Overridden Methods

- (BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    if ([preventingGestureRecognizer isKindOfClass:[YMLPanGestureRecognizer class]] && [(YMLPanGestureRecognizer *)preventingGestureRecognizer isLocked]) {
        return YES;
    }
    
    return NO;
}

- (BOOL) canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    if ([preventedGestureRecognizer isKindOfClass:[YMLPanGestureRecognizer class]] && [(YMLPanGestureRecognizer *)preventedGestureRecognizer isLocked]) {
        return NO;
    }
    
    return YES;
}

- (void) reset {
    startPoint = CGPointZero;
    
    if ([self isLocked]) {
        isLocked = NO;
        
        [YMLPanGestureRecognizer setLocked:NO];
    }
}


#pragma mark - Public Methods

- (BOOL) isVerticalDirection {
    return [YMLPanGestureRecognizer isVerticalDirection:direction];
}

- (void) forceEnd {
    [self setState:UIGestureRecognizerStateEnded];
}

@end
