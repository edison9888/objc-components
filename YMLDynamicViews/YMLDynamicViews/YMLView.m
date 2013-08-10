//
//  YMLView.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLLayoutEngine.h"

@interface YMLView () {
    NSMutableDictionary *subViewData, *zIndices;
}

- (BOOL) isObjectExistForTag:(int)tag;

@end

@implementation YMLView

@synthesize layoutId;

- (id) init {
    return [self initWithLayoutId:@""];
}

- (id) initWithLayoutId:(NSString *)_layoutId {
    self = [super init];
    if (self) {
        [self setLayoutId:_layoutId];
        
        subViewData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        subViewData = [[NSMutableDictionary alloc] init];
        zIndices = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark Private Methods

- (BOOL) isObjectExistForTag:(int)tag {
    return [[subViewData allKeys] containsObject:[NSString stringWithFormat:@"%d", tag]];
}


#pragma mark - Public Methods

- (UIView *) viewWithTag:(NSInteger)tag {
    UIView *view = nil;
    
    if ([self isObjectExistForTag:tag]) {
        for (UIView *subView in [self subviews]) {
            if ([subView tag] == tag) {
                view = subView;
                break;
            }
        }
    }
    
    return view;
}

- (void) addControl:(NSDictionary *)controlData {
    NSString *controlID = [controlData objectForKey:@"controlid"];
    
    NSDictionary *controlProperties = [[controlData objectForKey:@"control_attributes"] JSONValue];
    
    UIView *controlView = [[YMLControlManager controlManager] controlForId:controlID];
    [controlView addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionOld context:NULL];
    [self addSubview:controlView];
    
    [[YMLAttributeManager attributeManager] applyAttribute:controlProperties forView:controlView inSuperView:self];
    
    [subViewData setObject:controlProperties forKey:[NSString stringWithFormat:@"%d", [controlView tag]]];
    [zIndices setObject:controlView forKey:[controlProperties objectForKey:@"zIndex"]];
}

- (void) layoutControlsByZIndex {
    NSArray *sortedZIndex = [zIndices allKeys];
    [sortedZIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue] > [obj2 intValue]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    for (NSString *key in sortedZIndex) {
        UIView *view = [zIndices objectForKey:key];
        [self bringSubviewToFront:view];
    }
}


#pragma mark - Key Value Observer

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tag"]) {
        // Add new tag with the view
        NSString *oldKey = [NSString stringWithFormat:@"%d", [[change objectForKey:@"old"] intValue]];
        NSString *newKey = [NSString stringWithFormat:@"%d", [(UIView *)object tag]];
        
        if ([self isObjectExistForTag:[oldKey intValue]]) {
            [subViewData setObject:[subViewData objectForKey:oldKey] forKey:newKey];
        }
        
        // Remove the old values
        if ([self isObjectExistForTag:[[change objectForKey:@"old"] intValue]]) {
            [subViewData removeObjectForKey:oldKey];
        }
    }
}


#pragma mark - Dealloc

- (void)dealloc {
    [layoutId release], layoutId = nil;
    [subViewData release], subViewData = nil;
    
    [super dealloc];
}

@end
