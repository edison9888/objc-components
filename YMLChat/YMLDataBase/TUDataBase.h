//
//  AppDelegate.h
//  parentgini
//
//  Created by vivek Rajanna on 06/03/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLSQLiteParser.h"
#import <sqlite3.h>

#define TU_DB_FOLDER                        @"Documents"
#define TU_DB_FILE_NAME                     @"database"
#define TU_DB_FILE_EXTENSION                @"sqlite"

@interface TUDataBase : YMLSQLiteParser {
    
}

@end


/*
 CREATE TABLE message_history (message_between VARCHAR, message_time NOT NULL DEFAULT CURRENT_TIMESTAMP, message_status int, message_content varchar, message_isout int);
*/
