//
//  YMLSQLiteParser.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YMLSQLiteParserIterate)(NSMutableDictionary *row);

@protocol YMLSQLiteParserDelegate;

@interface YMLSQLiteParser : NSObject {
    NSString * path;
}

@property (nonatomic, copy) NSString * path;

- (id)initWithPath:(NSString *)path;
- (NSMutableArray *) resultSetForQuery:(NSString *)qstr;
- (void) resultSetForQuery:(NSString *)qstr withParseDelegate:(id<YMLSQLiteParserDelegate>)delegate;
- (void) resultSetForQuery:(NSString *)qstr iterate:(YMLSQLiteParserIterate)iterate;
- (BOOL) executeQuery:(NSString *)qstr;
- (NSMutableDictionary *) lastRowInTable:(NSString *)tableName;

@end


@protocol YMLSQLiteParserDelegate <NSObject>

@optional
- (void) sqlParser:(YMLSQLiteParser *)parser withRow:(NSMutableDictionary *)row;

@end
