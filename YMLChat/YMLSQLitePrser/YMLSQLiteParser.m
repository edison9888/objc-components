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
    
}

@end

@implementation YMLSQLiteParser

@synthesize path;

- (id)initWithPath:(NSString *)_path {
    self = [super init];
    if (self) {
        [self setPath:_path];
    }
    return self;
}


#pragma mark - Public Methods

- (NSMutableArray *) resultSetForQuery:(NSString *)qstr {
    NSMutableArray *resultSet = [[NSMutableArray alloc] init];
    
    @synchronized(self) {
        sqlite3 *dataBase;
        sqlite3_open([path UTF8String], &dataBase);
        sqlite3_stmt *selectStmt;
        if (sqlite3_prepare_v2(dataBase, [qstr cStringUsingEncoding:NSUTF8StringEncoding], -1, &selectStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectStmt) == SQLITE_ROW) {
                NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
                
                int intCount = sqlite3_column_count(selectStmt);
                for (int i = 0; i < intCount; i++) {
                    const char *value = (const char *)sqlite3_column_text(selectStmt, i);
                    if (value == NULL) {
                        [row setObject:@"" 
                                forKey:[NSString stringWithCString:(const char *)sqlite3_column_name(selectStmt, i) encoding:NSUTF8StringEncoding]];
                    }
                    else {
                        [row setObject:[NSString stringWithCString:(const char *)sqlite3_column_text(selectStmt, i) encoding:NSUTF8StringEncoding] 
                                forKey:[NSString stringWithCString:(const char *)sqlite3_column_name(selectStmt, i) encoding:NSUTF8StringEncoding]];
                    }
                }
                
                [resultSet addObject:row];
            }
        }
        
        sqlite3_finalize(selectStmt);
        sqlite3_close(dataBase);
    }
    
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

- (BOOL) executeQuery:(NSString *)qstr {
    BOOL isSuccess = NO;
    
    @synchronized(self) {
        sqlite3 *dataBase;
        sqlite3_open([path UTF8String], &dataBase);
        sqlite3_stmt *insertStatement;
        if (sqlite3_prepare_v2(dataBase, [qstr cStringUsingEncoding:NSUTF8StringEncoding], -1, &insertStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(insertStatement) == SQLITE_DONE) {
                isSuccess = YES;
            }
            
            sqlite3_reset(insertStatement);
            sqlite3_finalize(insertStatement);
        }
        
        sqlite3_close(dataBase);
    }
    
    return isSuccess;
}

- (NSMutableDictionary *) lastRowInTable:(NSString *)tableName {
    NSString *qstr = [NSString stringWithFormat:@"select * from %@ order by rowid desc limit 1", tableName];
    NSArray *resultSet = [self resultSetForQuery:qstr];
    if ([resultSet count] == 0) {
        return nil;
    }
    
    return [resultSet objectAtIndex:0];
}

@end
