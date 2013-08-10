//
//  AppDelegate.h
//  parentgini
//
//  Created by vivek Rajanna on 06/03/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUDataBase.h"


@interface TUDataBase ()

- (NSString *) dbPath;
- (BOOL) copyDataBaseFile;

@end

@implementation TUDataBase 


#pragma mark - Init Method

- (id) init {
    self = [super init];
    if (self)  {
        if ([self copyDataBaseFile]) {
            [self setPath:[self dbPath]];
        }
    }    
    return self;
}


#pragma mark - Private Methods

- (NSString *)dbPath  {
    NSArray *documentPathArray = [NSArray arrayWithObjects:NSHomeDirectory(), TU_DB_FOLDER, [NSString stringWithFormat:@"%@.%@", TU_DB_FILE_NAME, TU_DB_FILE_EXTENSION], nil];
    NSString *documentPath = [NSString pathWithComponents:documentPathArray];
    
    return documentPath;
}

- (BOOL) copyDataBaseFile {
    BOOL isCopied = NO;
    
    NSString *documentPath = [self dbPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];        
    if(![fileManager fileExistsAtPath:documentPath])  {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TU_DB_FILE_NAME ofType:TU_DB_FILE_EXTENSION];
        
        if([fileManager copyItemAtURL:[NSURL fileURLWithPath:bundlePath] toURL:[NSURL fileURLWithPath:documentPath] error:nil]) {
            isCopied = YES;
        }
        else {
            isCopied = NO;
        }
    }
    else {
        isCopied = YES;
    }
    
    return isCopied;
}

@end
