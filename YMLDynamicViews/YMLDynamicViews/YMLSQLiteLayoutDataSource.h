//
//  YMLSQLiteLayoutDataSource.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLLayoutDataSource.h"
#import "YMLSQLiteParser.h"

#define LAYOUT_DB_FOLDER                    @"Documents"
#define LAYOUT_DB_FILE_NAME                 @"layout"
#define LAYOUT_DB_FILE_EXTENSION            @"sqlite"

@interface YMLSQLiteLayoutDataSource : YMLLayoutDataSource

@end
