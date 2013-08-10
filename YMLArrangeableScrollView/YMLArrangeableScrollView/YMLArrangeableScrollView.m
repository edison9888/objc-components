//
//  YMLArrangeableScrollView.m
//  test
//
//  Created by Karthik Keyan B on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLArrangeableScrollView.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_DISTANCE_TO_MOVE            20.0

@interface YMLArrangeableScrollView () {
    NSUInteger numberOfColumns;
    
    NSMutableArray *views;
    
    YMLThumbView *viewToMove;
}

- (void) addLongPressGesture;
- (void) addTapGesture;
- (void) layoutViewsTillIndex:(int)index;
- (void) cancelled;

- (void) longPressed:(UILongPressGestureRecognizer *)gesture;
- (void) tapped:(UITapGestureRecognizer *)gesture;

@end

@implementation YMLArrangeableScrollView

@synthesize isHorizontal;
@synthesize dataSource;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor underPageBackgroundColor]];
        [self setUserInteractionEnabled:YES];
        
        views = [[NSMutableArray alloc] init];
        
        [self addLongPressGesture];
        [self addTapGesture];
    }
    return self;
}


#pragma mark - Set Horizontal 

- (void)setHorizontal:(BOOL)horizontal {
    if (horizontal != isHorizontal) {
        isHorizontal = horizontal;
        
        [self layoutViewsTillIndex:-1];
    }
}


#pragma mark - Private Methods

- (void) addLongPressGesture {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
                                                                                                   action:@selector(longPressed:)];
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release], longPressGesture = nil;
}

- (void) addTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                 action:@selector(tapped:)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture release], tapGesture = nil;
}

- (void) layoutViewsTillIndex:(int)index {
    NSUInteger numberOfSubViews = [views count];
    CGSize size = [dataSource scrollView:self subViewsSizeInHorizontalLayout:isHorizontal];
    CGFloat verticalSpace = [dataSource scrollView:self verticalSpaceInHorizontalLayout:isHorizontal];
    CGFloat horizontalSpace = [dataSource scrollView:self horizontalSpaceInHorizontalLayout:isHorizontal];
    
    if (isHorizontal) {
        int numberOfRows = self.bounds.size.height/(size.height + verticalSpace);
        numberOfColumns = numberOfSubViews/numberOfRows;
        
        int spaceForSingleView = self.bounds.size.height/numberOfRows;
        verticalSpace = spaceForSingleView - size.height;
        
        int x = horizontalSpace/2, y = verticalSpace/2;
        for (int i = 0; i < numberOfSubViews; i++) {
            if (index == i) {
                break;
            }
            
            UIView *view = [views objectAtIndex:i];
            
            if ((i % numberOfColumns) == 0) {
                x = horizontalSpace/2;
                if (i > 0) {
                    y += size.height + verticalSpace;
                }
            }
            
            [view setFrame:CGRectMake(x, y, size.width, size.height)];
            
            x += size.width + horizontalSpace;
            
            [self setContentSize:CGSizeMake(x + (horizontalSpace/2), 0)];
        }
    }
    else {        
        numberOfColumns = self.bounds.size.width/(size.width + horizontalSpace);
        
        int spaceForSingleView = self.bounds.size.width/numberOfColumns;
        horizontalSpace = spaceForSingleView - size.width;
        
        int x = horizontalSpace/2, y = verticalSpace/2;
        for (int i = 0; i < numberOfSubViews; i++) {
            if (index == i) {
                break;
            }
            
            UIView *view = [views objectAtIndex:i];
            
            if ((i % numberOfColumns) == 0) {
                x = horizontalSpace/2;
                if (i > 0) {
                    y += size.height + verticalSpace;
                }
            }
            
            [view setFrame:CGRectMake(x, y, size.width, size.height)];
            
            x += size.width + horizontalSpace;
            
            [self setContentSize:CGSizeMake(0, y + size.height + (verticalSpace/2))];
        }
    }
}

- (void) cancelled {
    [viewToMove setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    viewToMove = nil;
    
    [UIView animateWithDuration:0.25 
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self layoutViewsTillIndex:-1];
                     } 
                     completion:nil];
}


#pragma mark - Public Methods

- (void) reload {
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [views removeAllObjects];
    
    NSUInteger numberOfSubViews = [dataSource numberOfSubViewsInScrollView:self];
    @autoreleasepool {
        for (int i = 0; i < numberOfSubViews; i++) {
            UIView *view = [dataSource scrollView:self subViewAtIndex:i];
            
            CGRect rect = CGRectZero;
            rect.origin.x = (self.bounds.size.width - view.frame.size.width)/2;
            rect.origin.y = (self.bounds.size.height - view.frame.size.height)/2;
            rect.size = view.frame.size;
            
            [view setFrame:rect];
            [self addSubview:view];
            [views addObject:view];
        }
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            [self layoutViewsTillIndex:-1];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void) resetLayout {
    [self layoutViewsTillIndex:-1];
}


#pragma mark - Gesture Methods

- (void) longPressed:(UILongPressGestureRecognizer *)gesture {
    UIView *view = [self hitTest:[gesture locationInView:self] withEvent:nil];
    
    if ([view isKindOfClass:[YMLThumbView class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!viewToMove) {
                [views makeObjectsPerformSelector:@selector(startShakeAnimation)];
                
                viewToMove = (YMLThumbView *)view;
                [viewToMove setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
                [self bringSubviewToFront:viewToMove];
                
                [self setScrollEnabled:NO];
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            CGPoint point = [gesture locationInView:self];
            if (point.x <= 0 || point.y <= 0 || point.x >= self.bounds.size.width || point.y >= self.bounds.size.height) {
                [self cancelled];
            }
            else {
                if (viewToMove) {
                    [viewToMove setFrame:CGRectMake(point.x - (viewToMove.frame.size.width/2), point.y - (viewToMove.frame.size.height/2), viewToMove.frame.size.width, viewToMove.frame.size.height)];
                    
                    // Find closest view and do layout animation
                    CGFloat viewToMoveY = point.y - (viewToMove.frame.size.height/2);
                    int numberofRows = [views count]/numberOfColumns;
                    int remainingIfAny = [views count]%numberOfColumns;
                    if (remainingIfAny > 0) {
                        numberofRows++;
                    }
                    
                    int viewToMoveCurrentRowIndex = viewToMoveY/viewToMove.frame.size.height;
                    int viewToMoveCurrentRowStartingIndex = viewToMoveCurrentRowIndex * numberOfColumns;
                    
                    NSMutableDictionary *viewsDistance = [NSMutableDictionary dictionary];
                    for (int i = viewToMoveCurrentRowStartingIndex; i < (viewToMoveCurrentRowStartingIndex + numberOfColumns); i++) {
                        UIView *viewToCompare = [views objectAtIndex:i];
                        int distance = viewToMove.center.x - viewToCompare.center.x;
                        if (distance < 0) {
                            distance *= -1;
                        }
                        
                        [viewsDistance setObject:[NSNumber numberWithInt:distance] forKey:[NSString stringWithFormat:@"%d", i]];
                    }
                    
                    NSMutableArray *keys = [NSMutableArray arrayWithArray:[viewsDistance allKeys]];
                    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        if ([[viewsDistance objectForKey:obj1] intValue] < [[viewsDistance objectForKey:obj2] intValue]) {
                            return NSOrderedAscending;
                        }
                        
                        return NSOrderedDescending;
                    }];
                    
                    
                    CGFloat distance = 0;
                    int hittedIndex = NSIntegerMax;
                    if ([[keys objectAtIndex:0] intValue] == [views indexOfObject:viewToMove]) {
                        hittedIndex = [[keys objectAtIndex:1] intValue];
                        distance = [[viewsDistance objectForKey:[keys objectAtIndex:1]] floatValue];
                    }
                    else {
                        hittedIndex = [[keys objectAtIndex:0] intValue];
                        distance = [[viewsDistance objectForKey:[keys objectAtIndex:0]] floatValue];
                    }
                    
                    if (distance <= MIN_DISTANCE_TO_MOVE) {
                        int viewToMoveIndex = [views indexOfObject:viewToMove];
                        
                        [views removeObjectAtIndex:viewToMoveIndex];
                        [views insertObject:viewToMove atIndex:hittedIndex];
                        
                        [UIView animateWithDuration:0.25 
                                              delay:0.0 
                                            options:(UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) 
                                         animations:^{                                             
                                             [self layoutViewsTillIndex:-1];
                                         } 
                                         completion:^(BOOL finished) {
                                             
                                         }];
                    }
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            [self cancelled];
        }
        else if ([gesture state] == UIGestureRecognizerStateCancelled) {
            [self cancelled];
        }
        else if ([gesture state] == UIGestureRecognizerStateFailed) {
            [self cancelled];
        }
    }
}

- (void) tapped:(UITapGestureRecognizer *)gesture {
    [views makeObjectsPerformSelector:@selector(stopShakeAnimation)];
    [self setScrollEnabled:YES];
    
    [self cancelled];
}


#pragma mark - Dealloc

- (void)dealloc {
    [views release], views = nil;
    
    [super dealloc];
}

@end
