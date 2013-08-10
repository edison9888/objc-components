//
//  YMLLayoutDataSource.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLLayoutDataSource.h"

static YMLLayoutDataSource *dataSource = nil;

@implementation YMLLayoutDataSource

+ (YMLLayoutDataSource *) layoutDataSourceWithClassName:(NSString *)className isSingleton:(BOOL)isSingleton {
    YMLLayoutDataSource *layoutDataSource = nil;
    
    if (isSingleton) {
        layoutDataSource = [NSClassFromString(className) dataSource];
    }
    else {
        layoutDataSource = [[[NSClassFromString(className) alloc] init] autorelease];
    }
    
    return layoutDataSource;
}

#pragma mark - Class Methods

+ (YMLLayoutDataSource *) dataSource {
    if (dataSource == nil) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            dataSource = [[YMLLayoutDataSource alloc] init];
        });
    }
    
    return dataSource;
}

#pragma mark - Singleton Overridden Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (dataSource == nil) {
        dataSource = [super allocWithZone:zone];
        
        return dataSource;
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


#pragma mark - Public Methods

- (NSMutableDictionary *) layoutForId:(NSString *)layoutId {
    return nil;
}

- (NSMutableArray *) controlsForLayoutId:(NSString *)layoutId {
    return nil;
}

- (NSMutableDictionary *) controlsList {
    return nil;
}

@end
