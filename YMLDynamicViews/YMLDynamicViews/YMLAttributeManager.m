//
//  YMLAttributeManager.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLLayoutEngine.h"

static YMLAttributeManager *attributeManager;

@interface YMLAttributeManager ()

- (CGFloat) horizontalCenterForWidth:(CGFloat)width inSuperView:(UIView *)superView;
- (CGFloat) verticalCenterForHeight:(CGFloat)height inSuperView:(UIView *)superView;

@end

@implementation YMLAttributeManager

+ (YMLAttributeManager *) attributeManager {    
    if (attributeManager == nil) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            attributeManager = [[YMLAttributeManager alloc] init];
        });
    }
    
    return attributeManager;
}


#pragma mark - Singleton Overridden Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (attributeManager == nil) {
        attributeManager = [super allocWithZone:zone];
        
        return attributeManager;
    }
    
    return nil;
}

+ (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax;
}

- (id) retain {
    return self;
}

- (id) autorelease {
    return self;
}

- (oneway void)release {
    // Do Nothing
}


#pragma mark - Private Methods

- (CGFloat) horizontalCenterForWidth:(CGFloat)width inSuperView:(UIView *)superView {
    CGFloat x = 0.0;
    if (superView) {
        x = ((superView.frame.size.width - width) * 0.5);
    }
    
    return x;
}

- (CGFloat) verticalCenterForHeight:(CGFloat)height inSuperView:(UIView *)superView {
    CGFloat y = 0.0;
    if (superView) {
        y = ((superView.frame.size.height - height) * 0.5);
    }
    
    return y;
}


#pragma mark - Public Methods

- (void) applyAttribute:(NSDictionary *)attribute forView:(UIView *)view {
    [self applyAttribute:attribute forView:view inSuperView:nil];
}

- (void) applyAttribute:(NSDictionary *)attribute forView:(UIView *)view inSuperView:(UIView *)superView {
    // Frame
    NSDictionary *frame = [attribute objectForKey:@"frame"];
    if (frame) {
        CGSize size = CGSizeZero;
        CGPoint origin = CGPointZero;
        
        if ([[frame objectForKey:@"width"] isEqualToString:@"fill"]) {
            size.width = (superView)?superView.bounds.size.width:0.0;
        }
        else {
            size.width = [[frame objectForKey:@"width"] floatValue];
        }
        
        if ([[frame objectForKey:@"height"] isEqualToString:@"fill"]) {
            size.height = (superView)?superView.bounds.size.height:0.0;
        }
        else {
            size.height = [[frame objectForKey:@"height"] floatValue];
        }
        
        if ([[frame objectForKey:@"x"] isEqualToString:@"auto"]) {
            origin.x = [self horizontalCenterForWidth:size.width inSuperView:superView];
        }
        else {
            origin.x = [[frame objectForKey:@"x"] floatValue];
        }
        
        if ([[frame objectForKey:@"y"] isEqualToString:@"auto"]) {
            origin.x = [self verticalCenterForHeight:size.height inSuperView:superView];
        }
        else {
            origin.y = [[frame objectForKey:@"y"] floatValue];
        }
        
        CGRect rect = (CGRect){.origin = origin, .size = size};
        [view setFrame:rect];
    }
    
    
    // Tag
    if ([attribute objectForKey:@"tag"]) {
        int tag = [[attribute objectForKey:@"tag"] intValue];
        [view setTag:tag];
    }
    
    
    // UserInteraction
    if ([attribute objectForKey:@"userinteraction"]) {
        BOOL enabled = [[attribute objectForKey:@"userinteraction"] boolValue];
        [view setUserInteractionEnabled:enabled];
    }
}

@end
