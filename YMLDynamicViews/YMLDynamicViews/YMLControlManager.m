//
//  YMLControlManager.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLLayoutEngine.h"

static YMLControlManager *controlManager;

@interface YMLControlManager () <YMLSQLiteParserDelegate> {
    NSString *path;
    NSMutableDictionary *controls;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) NSMutableDictionary *controls;

- (void) setDefaultAttributesForView:(UIView *)view;

@end

@implementation YMLControlManager

@synthesize path;
@synthesize controls;

+ (YMLControlManager *) controlManager {    
    if (controlManager == nil) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            controlManager = [[YMLControlManager alloc] init];
        });
    }
    
    return controlManager;
}

#pragma mark - Singleton Overridden Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (controlManager == nil) {
        controlManager = [super allocWithZone:zone];
        
        return controlManager;
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

- (id) init {
    self = [super init];
    if (self) {
        YMLLayoutDataSource *dataSource = [YMLLayoutDataSource layoutDataSourceWithClassName:LAYOUT_SQLITE_DATASOURCE_CLASSNAME isSingleton:YES];
        [self setControls:[dataSource controlsList]];
    }
    
    return self;
}


#pragma mark - Private Methods

- (void) setDefaultAttributesForView:(UIView *)view {
    if ([view isKindOfClass:[UITextField class]]) {
        [(UITextField *)view setBorderStyle:UITextBorderStyleRoundedRect];
        [(UITextField *)view setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    }
}


#pragma mark - Public Methods

- (UIView *) controlForId:(NSString *)controlId {
    NSString *className = [controls objectForKey:controlId];
    
    UIView *control = nil;
    
    if (className) {
        control = [[[NSClassFromString(className) alloc] init] autorelease];
        [self setDefaultAttributesForView:control];
    }
    
    return control;
}

@end
