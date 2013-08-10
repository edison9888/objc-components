//
//  YMLLayoutDataSource.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMLLayoutDataSource : NSObject

+ (YMLLayoutDataSource *) layoutDataSourceWithClassName:(NSString *)className isSingleton:(BOOL)isSingleton;
+ (YMLLayoutDataSource *) dataSource;

- (NSMutableDictionary *) layoutForId:(NSString *)layoutId;
- (NSMutableArray *) controlsForLayoutId:(NSString *)layoutId;
- (NSMutableDictionary *) controlsList;

@end
