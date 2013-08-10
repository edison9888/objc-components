//
//  CircleView.m
//  Rotate
//
//  Created by Sumit Mehra on 4/21/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLRotateMenu.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLRotateMenu () {
    BOOL isMoved;
    float degreeToSubtract, previousAngle;
    
    CGPoint beganLocation;
}

- (float) updateRotation:(CGPoint)location;
- (void) rotateToAngle:(float)toAngle;

@end

@implementation YMLRotateMenu

@synthesize disableTransparentArea = isDisableTransparentArea;
@synthesize selectedIndex;
@synthesize circleTextView;
@synthesize centerAngle;
@synthesize containerView;
@synthesize backgroundView, overLayImageView;
@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isMoved = NO;
        
        selectedIndex = -1;
        
        degreeToSubtract = RADIANS_TO_DEGREE(M_PI_2);
        degreeToSubtract = 0;
        
        backgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [self addSubview:backgroundView];
        
        containerView = [[UIView alloc] initWithFrame:[self bounds]];
        [self addSubview:containerView];
        
        circleTextView = [[YMLRotateMenuText alloc] initWithFrame:[self bounds]];
        [circleTextView setRotateMenu:self];
        [circleTextView setUserInteractionEnabled:NO];
        [circleTextView setBackgroundColor:[UIColor clearColor]];
        [containerView addSubview:circleTextView];
        
        overLayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [containerView addSubview:overLayImageView];
    }
    return self;
}


#pragma mark - Setter

- (void) setDelegate:(id<YMLRotateMenuDelegate>)_delegate {
    delegate = _delegate;
    [circleTextView setDelegate:_delegate];
    
    [circleTextView setMenuItems:nil];
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    int count = [delegate numberOfItemsInRotateMenu:self];
    for (int i = 0; i < count; i++) {
        [menuItems addObject:[delegate rotateMenu:self menuItemForIndex:i]];
    }
    
    [circleTextView setMenuItems:menuItems];
    
    menuItems = nil;
}


#pragma mark - Private Methods

- (float) updateRotation:(CGPoint)location {
    float fromAngle = atan2(beganLocation.y - containerView.center.y, beganLocation.x - containerView.center.x);
    float toAngle = atan2(location.y - circleTextView.center.y, location.x - circleTextView.center.x);
    float newAngle = [circleTextView wrapd:currentAngle + (toAngle - fromAngle) min:0 max:2 * 3.14];
    
    CGAffineTransform cgaRotate = CGAffineTransformMakeRotation(newAngle);
    [circleTextView setTransform:cgaRotate];        
    
    CGFloat radians = atan2f(circleTextView.transform.a, circleTextView.transform.b);
    radians = [circleTextView wrapd:radians min:0 max:(M_PI * 2)];
    
    if (IS_DEV) { DLog(@"Current Angle = %f", RADIANS_TO_DEGREE(radians)); }
    if (IS_DEV) { DLog(@"Current Angle - Center (%f) = %f", centerAngle, RADIANS_TO_DEGREE(radians) - centerAngle); }
    if (IS_DEV) { DLog(@"\n\n"); }
    
    return newAngle;
}

- (void) rotateToAngle:(float)toAngle {
    CGFloat radians = atan2f(circleTextView.transform.a, circleTextView.transform.b);
    radians = [circleTextView wrapd:radians min:0 max:(M_PI * 2)];
    
    if (IS_DEV) { DLog(@"Current Angle = %f", RADIANS_TO_DEGREE(radians)); }
    
    float currentDegree = RADIANS_TO_DEGREE(radians) - centerAngle;
    
    if (IS_DEV) { DLog(@"Current Angle - Center (%f) = %f", centerAngle, RADIANS_TO_DEGREE(radians) - centerAngle); }
    
    float targetDegree = toAngle;
    
    int index = [circleTextView itemIndexAtAngle:targetDegree];
    
//    if ((RADIANS_TO_DEGREE(radians) - centerAngle) < 0.0) {
//        currentDegree = (360 + currentDegree);
//        targetDegree = [circleTextView itemAngleForViewAngle:(currentDegree - degreeToSubtract)];
//    }
//    
//    
//    if (targetDegree == 0.0) {
//        if (currentDegree < [circleTextView minimum]) {
//            targetDegree = [circleTextView itemAngleForViewAngle:(([circleTextView minimum] + 1) - degreeToSubtract)];
//        }    
//        else if (currentDegree > [circleTextView maximum]) {
//            if (selectedIndex == 0) {
//                targetDegree = [circleTextView angleForItemAtIndex:0];
//            }
//            else {
//                targetDegree = [circleTextView itemAngleForViewAngle:(([circleTextView maximum] - 1) - degreeToSubtract)];
//            }
//        }
//    }
    
    [circleTextView selectNone];
    
    if (targetDegree != 0.0) {    
        
        if (IS_DEV) { DLog(@"Target Angle = %f", targetDegree); }
        
        index = [circleTextView itemIndexAtAngle:targetDegree];
        float adjustmentAngle = 0.0;
        if ([delegate respondsToSelector:@selector(rotateMenu:angleAdjustmentForItemAtIndex:forTargetAngle:minimum:andMaximum:)]) {
            adjustmentAngle = [delegate rotateMenu:self angleAdjustmentForItemAtIndex:index forTargetAngle:targetDegree minimum:[circleTextView minimum] andMaximum:[circleTextView maximum]];
        }
        
        float degreeToRotate = targetDegree - currentDegree + degreeToSubtract + adjustmentAngle;
        
        if (IS_DEV) { DLog(@"Angle To Rotate = %f", degreeToRotate); }
        
        currentAngle -= DEGREE_TO_RADIANS(degreeToRotate);
        
        selectedIndex = [circleTextView itemIndexAtAngle:targetDegree];
        
        [circleTextView setCurrentMenuItemIndex:selectedIndex];
        
        if ([delegate respondsToSelector:@selector(rotateMenu:menuItemDidSelectAtIndex:)]) {
            [delegate rotateMenu:self menuItemDidSelectAtIndex:selectedIndex];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [circleTextView setTransform:CGAffineTransformRotate(circleTextView.transform, DEGREE_TO_RADIANS(-degreeToRotate))];
        [UIView commitAnimations];
    }
    else {
        float targetDegree = [circleTextView itemAngleForViewAngle:(previousAngle)];
        
        if (IS_DEV) { DLog(@"Target Angle = %f", targetDegree); }
        
        index = [circleTextView itemIndexAtAngle:targetDegree];
        float adjustmentAngle = 0.0;
        if ([delegate respondsToSelector:@selector(rotateMenu:angleAdjustmentForItemAtIndex:forTargetAngle:minimum:andMaximum:)]) {
            adjustmentAngle = [delegate rotateMenu:self angleAdjustmentForItemAtIndex:index forTargetAngle:targetDegree minimum:[circleTextView minimum] andMaximum:[circleTextView maximum]];
        }
        
        float degreeToRotate = targetDegree - currentDegree + degreeToSubtract + adjustmentAngle;
        
        if (IS_DEV) { DLog(@"Angle To Rotate = %f", degreeToRotate); }
        
        currentAngle -= DEGREE_TO_RADIANS(degreeToRotate);
        
        selectedIndex = [circleTextView itemIndexAtAngle:targetDegree];
        
        [circleTextView setCurrentMenuItemIndex:selectedIndex];
        
        if ([delegate respondsToSelector:@selector(rotateMenu:menuItemDidSelectAtIndex:)]) {
            [delegate rotateMenu:self menuItemDidSelectAtIndex:selectedIndex];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [circleTextView setTransform:CGAffineTransformRotate(circleTextView.transform, DEGREE_TO_RADIANS(-degreeToRotate))];
        [UIView commitAnimations];
    }
    
    if (IS_DEV) { DLog(@"\n\n"); }
}


#pragma mark - Public Methods

- (void) setBackgroundImage:(UIImage *)background {
    [backgroundView setImage:background];
}

- (void) selectItemAtIndex:(int)index {
    float angle = [[NSString stringWithFormat:@"%0.0f", [circleTextView angleForItemAtIndex:index]] floatValue];
    [self rotateToAngle:angle];
}

- (void) setOverLayImage:(UIImage *)overLayImage {
    [overLayImageView setImage:overLayImage];
}


#pragma mark - Touch Delegate

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!isDisableTransparentArea) {
        return YES;
    }
    
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [[self layer] renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    if (pixel[3]/255.0 == 0.0) {
        return NO;
    }
    
    return YES;
}

- (void) touchesBegan:(NSSet *)_touches withEvent:(UIEvent *)_event {    
    UITouch *touch = [_touches anyObject];
    CGPoint location = [touch locationInView:self];
    beganLocation = location;
    
    previousAngle = currentAngle;
}

- (void) touchesMoved:(NSSet *)_touches withEvent:(UIEvent *)_event {
//    isMoved = YES;
    
    UITouch *touch = [_touches anyObject];
    CGPoint location = [touch locationInView:self];    
    [self updateRotation:location];
}

- (void) touchesEnded:(NSSet *)_touches withEvent:(UIEvent *)_event {    
//    if (!isMoved) {
//        return;
//    }
//    
//    isMoved = NO;
    
    UITouch* touch = [_touches anyObject];
    CGPoint location = [touch locationInView:self];    
    currentAngle = [self updateRotation:location];
    
    CGFloat radians = atan2f(circleTextView.transform.a, circleTextView.transform.b);
    radians = [circleTextView wrapd:radians min:0 max:(M_PI * 2)];
    
    if (IS_DEV) { DLog(@"Current Angle = %f", RADIANS_TO_DEGREE(radians)); }
    
    float currentDegree = RADIANS_TO_DEGREE(radians) - centerAngle;
    
    if (IS_DEV) { DLog(@"Current Angle - Center (%f) = %f", centerAngle, RADIANS_TO_DEGREE(radians) - centerAngle); }
    
    float targetDegree = [circleTextView itemAngleForViewAngle:(currentDegree - degreeToSubtract)];
    
    int index = [circleTextView itemIndexAtAngle:targetDegree];
    
    if ((RADIANS_TO_DEGREE(radians) - centerAngle) < 0.0) {
        currentDegree = (360 + currentDegree);
        targetDegree = [circleTextView itemAngleForViewAngle:(currentDegree - degreeToSubtract)];
    }
    
    
    if (targetDegree == 0.0) {
        if (currentDegree < [circleTextView minimum]) {
            targetDegree = [circleTextView itemAngleForViewAngle:(([circleTextView minimum] + 1) - degreeToSubtract)];
        }    
        else if (currentDegree > [circleTextView maximum]) {
            if (selectedIndex == 0) {
                targetDegree = [circleTextView angleForItemAtIndex:0];
            }
            else {
                targetDegree = [circleTextView itemAngleForViewAngle:(([circleTextView maximum] - 1) - degreeToSubtract)];
            }
        }
    }
    
    [circleTextView selectNone];
    
    if (targetDegree != 0.0) {    
        
        if (IS_DEV) { DLog(@"Target Angle = %f", targetDegree); }
        
        index = [circleTextView itemIndexAtAngle:targetDegree];
        float adjustmentAngle = 0.0;
        if ([delegate respondsToSelector:@selector(rotateMenu:angleAdjustmentForItemAtIndex:forTargetAngle:minimum:andMaximum:)]) {
            adjustmentAngle = [delegate rotateMenu:self angleAdjustmentForItemAtIndex:index forTargetAngle:targetDegree minimum:[circleTextView minimum] andMaximum:[circleTextView maximum]];
        }
        
        float degreeToRotate = targetDegree - currentDegree + degreeToSubtract + adjustmentAngle;
        
        if (IS_DEV) { DLog(@"Angle To Rotate = %f", degreeToRotate); }
        
        currentAngle -= DEGREE_TO_RADIANS(degreeToRotate);
        
        selectedIndex = [circleTextView itemIndexAtAngle:targetDegree];
        
        [circleTextView setCurrentMenuItemIndex:selectedIndex];
        
        if ([delegate respondsToSelector:@selector(rotateMenu:menuItemDidSelectAtIndex:)]) {
            [delegate rotateMenu:self menuItemDidSelectAtIndex:selectedIndex];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [circleTextView setTransform:CGAffineTransformRotate(circleTextView.transform, DEGREE_TO_RADIANS(-degreeToRotate))];
        [UIView commitAnimations];
    }
    else {
        float targetDegree = [circleTextView itemAngleForViewAngle:(previousAngle)];
        
        if (IS_DEV) { DLog(@"Target Angle = %f", targetDegree); }
        
        index = [circleTextView itemIndexAtAngle:targetDegree];
        float adjustmentAngle = 0.0;
        if ([delegate respondsToSelector:@selector(rotateMenu:angleAdjustmentForItemAtIndex:forTargetAngle:minimum:andMaximum:)]) {
            adjustmentAngle = [delegate rotateMenu:self angleAdjustmentForItemAtIndex:index forTargetAngle:targetDegree minimum:[circleTextView minimum] andMaximum:[circleTextView maximum]];
        }
        
        float degreeToRotate = targetDegree - currentDegree + degreeToSubtract + adjustmentAngle;
        
        if (IS_DEV) { DLog(@"Angle To Rotate = %f", degreeToRotate); }
        
        currentAngle -= DEGREE_TO_RADIANS(degreeToRotate);
        
        selectedIndex = [circleTextView itemIndexAtAngle:targetDegree];
        
        [circleTextView setCurrentMenuItemIndex:selectedIndex];
        
        if ([delegate respondsToSelector:@selector(rotateMenu:menuItemDidSelectAtIndex:)]) {
            [delegate rotateMenu:self menuItemDidSelectAtIndex:selectedIndex];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [circleTextView setTransform:CGAffineTransformRotate(circleTextView.transform, DEGREE_TO_RADIANS(-degreeToRotate))];
        [UIView commitAnimations];
    }
    
    if (IS_DEV) { DLog(@"\n\n"); }
}


#pragma mark - Dealloc

- (void) dealloc {
    delegate = nil;
    
}

@end
