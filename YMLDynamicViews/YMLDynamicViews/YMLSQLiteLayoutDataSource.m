//
//  YMLSQLiteLayoutDataSource.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLSQLiteLayoutDataSource.h"

static YMLSQLiteLayoutDataSource *dataSource = nil;

@interface YMLSQLiteLayoutDataSource () <YMLSQLiteParserDelegate> {
    NSString *path;
}

@property (nonatomic, copy) NSString *path;

@end


@implementation YMLSQLiteLayoutDataSource

@synthesize path;

#pragma mark - Class Methods

+ (YMLSQLiteLayoutDataSource *) dataSource {
    if (dataSource == nil) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            dataSource = [[YMLSQLiteLayoutDataSource alloc] init];
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


#pragma mark - Init

- (id) init {
    self = [super init];
    if (self) {
        NSArray *pathComponents = [NSArray arrayWithObjects:NSHomeDirectory(), LAYOUT_DB_FOLDER, [NSString stringWithFormat:@"%@.%@", LAYOUT_DB_FILE_NAME, LAYOUT_DB_FILE_EXTENSION], nil];
        [self setPath:[NSString pathWithComponents:pathComponents]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:path]) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:LAYOUT_DB_FILE_NAME ofType:LAYOUT_DB_FILE_EXTENSION];
            [fileManager copyItemAtPath:bundlePath toPath:path error:nil];
        }
    }
    
    return self;
}


#pragma mark - Public Methods

- (NSMutableDictionary *) layoutForId:(NSString *)layoutId {
    YMLSQLiteParser *sqlParser = [[YMLSQLiteParser alloc] initWithPath:path];
    NSMutableArray *layoutData = [sqlParser resultSetForQuery:[NSString stringWithFormat:@"select * from layouts where layoutid = '%@'", layoutId]];
    [sqlParser release], sqlParser = nil;
    
    if ([layoutData count] > 0) {
        return [layoutData objectAtIndex:0];
    }
    
    return nil;
}

- (NSMutableArray *) controlsForLayoutId:(NSString *)layoutId {
    YMLSQLiteParser *sqlParser = [[YMLSQLiteParser alloc] initWithPath:path];
    NSMutableArray *layoutControls = [sqlParser resultSetForQuery:[NSString stringWithFormat:@"select * from layout_controls where layoutid = '%@'", layoutId]];
    [sqlParser release], sqlParser = nil;
    
    return layoutControls;
}

- (NSMutableDictionary *) controlsList {
    static NSMutableDictionary *controls = nil;
    
    if (!controls) {
        controls = [[NSMutableDictionary alloc] init];
        
        YMLSQLiteParser *parse = [[YMLSQLiteParser alloc] initWithPath:path];
        [parse resultSetForQuery:@"select * from controls" iterate:^(NSMutableDictionary *row) {
            [controls setObject:[row objectForKey:@"classname"] forKey:[row objectForKey:@"controlid"]];
        }];        
        [parse release], parse = nil;
    }
    
    return controls;
}

@end
