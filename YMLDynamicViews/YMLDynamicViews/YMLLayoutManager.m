//
//  YMLLayoutManager.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLLayoutEngine.h"

static YMLLayoutManager *layoutManager = nil;

@interface YMLLayoutManager () {
    
}

@end


@implementation YMLLayoutManager

+ (YMLLayoutManager *) layoutManager {    
    if (layoutManager == nil) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            layoutManager = [[YMLLayoutManager alloc] init];
        });
    }
    
    return layoutManager;
}

#pragma mark - Singleton Overridden Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (layoutManager == nil) {
        layoutManager = [super allocWithZone:zone];
        
        return layoutManager;
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


#pragma mark - Init




#pragma mark - Public Methods

- (YMLView *) layoutForId:(NSString *)layoutId {
    return [self layoutForId:layoutId superView:nil];
}

- (YMLView *) layoutForId:(NSString *)layoutId superView:(UIView *)superView {
    YMLLayoutDataSource *layoutDataSource = [YMLLayoutDataSource layoutDataSourceWithClassName:LAYOUT_SQLITE_DATASOURCE_CLASSNAME isSingleton:YES];
    NSMutableDictionary *layoutData = [layoutDataSource layoutForId:layoutId];
    
    YMLView *view = nil;
    
    if ([layoutData count] > 0) {
        NSDictionary *properties = [[layoutData objectForKey:@"layout_attributes"] JSONValue];
        
        view = [[[YMLView alloc] initWithLayoutId:layoutId] autorelease];
        [[YMLAttributeManager attributeManager] applyAttribute:properties forView:view inSuperView:superView];
        
        NSMutableArray *layoutControls = [layoutDataSource controlsForLayoutId:layoutId];
        for (NSDictionary *layoutControl in layoutControls) {
            [view addControl:layoutControl];
        }
        
        [view layoutControlsByZIndex];
    }
    
    return view;
}

@end
