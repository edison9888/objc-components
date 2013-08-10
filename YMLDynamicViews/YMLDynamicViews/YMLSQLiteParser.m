//
//  YMLSQLiteParser.m
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLSQLiteParser.h"
#import <sqlite3.h>

@interface YMLSQLiteParser () {
    NSString *path;
    
    sqlite3 *dataBase;
}

@property (nonatomic, copy) NSString * path;

@end

@implementation YMLSQLiteParser

@synthesize path;

- (id)initWithPath:(NSString *)_path {
    self = [super init];
    if (self) {
        [self setPath:_path];
        
        sqlite3_open([path UTF8String], &dataBase);
    }
    return self;
}


#pragma mark - Public Methods

- (NSMutableArray *) resultSetForQuery:(NSString *)qstr {
    NSMutableArray *resultSet = [[[NSMutableArray alloc] init] autorelease];
    sqlite3_stmt *selectStmt = nil;
    
    @synchronized(self) {
        if (sqlite3_prepare_v2(dataBase, [qstr cStringUsingEncoding:NSUTF8StringEncoding], -1, &selectStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectStmt) == SQLITE_ROW) {
                NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
                
                int intCount = sqlite3_column_count(selectStmt);
                for (int i = 0; i < intCount; i++) {
                    [row setObject:[NSString stringWithCString:(const char *)sqlite3_column_text(selectStmt, i) encoding:NSUTF8StringEncoding] 
                            forKey:[NSString stringWithCString:(const char *)sqlite3_column_name(selectStmt, i) encoding:NSUTF8StringEncoding]];
                }
                
                [resultSet addObject:row];
                [row release];
            }
        }
    }
    
    sqlite3_finalize(selectStmt);
    
    return resultSet;
}

- (void) resultSetForQuery:(NSString *)qstr withParseDelegate:(id<YMLSQLiteParserDelegate>)delegate {
    NSMutableArray *resultSet = [self resultSetForQuery:qstr];
    if ([delegate respondsToSelector:@selector(sqlParser:withRow:)]) {
        for (NSMutableDictionary *row in resultSet) {
            [delegate sqlParser:self withRow:row];
        }
    }
}

- (void) resultSetForQuery:(NSString *)qstr iterate:(YMLSQLiteParserIterate)iterate {
    NSMutableArray *resultSet = [self resultSetForQuery:qstr];
    if (iterate) {
        for (NSMutableDictionary *row in resultSet) {
            iterate(row);
        }
    }
}


#pragma mark - Dealloc

- (void) dealloc {
    sqlite3_close(dataBase);
    
    [path release], path = nil;
    
    [super dealloc];
}

@end
