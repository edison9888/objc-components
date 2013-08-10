//
//  YMLAsynchronousImageData.m
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import "YMLAsynchronousImageData.h"

@interface YMLAsynchronousImageData () {
    NSMutableDictionary *activeConnections;
}

- (void) connectionDidFinishLoadingNotification:(NSNotification *)notification;

@end

@implementation YMLAsynchronousImageData

static YMLAsynchronousImageData *sharedInstance;

#pragma mark - Class Methods

+ (YMLAsynchronousImageData *) imageData {
    if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[[self class] alloc] init];
        });
    }
    
    return sharedInstance;
}


- (id) init {
    self = [super init];
    if (self) {
        activeConnections = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidFinishLoadingNotification:) name:YMLURLConnectionFinishedNotification object:nil];
    }
    
    return self;
}


#pragma mark - Singleton Override Methods

+ (id)allocWithZone:(NSZone *)zone {
    if (sharedInstance == nil) {
        sharedInstance = [super allocWithZone:zone];
        
        return sharedInstance;
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Public Methods

- (YMLURLConnection *) connectionForURL:(NSString *)url completion:(YMLURLConnectionDidFinished)completion {
    return [self connectionForURL:url completion:completion forceReload:NO];
}

- (YMLURLConnection *) connectionForURL:(NSString *)url completion:(YMLURLConnectionDidFinished)completion forceReload:(BOOL)forceReload {
    YMLURLConnection *connection = nil;
    if (forceReload) {
        [self removeConnectionForURL:url];
        connection = [self initiateConnectionForURL:url andCallback:completion];
    }
    else {
        connection = [activeConnections objectForKey:url];
        if (!IS_OBJ_NILL_OR_NULL(connection)) {
            if ([connection connectionStatus] == YMLURLConnectionStatusFinished) {
                completion(url, [connection responseData]);
            }
            else if ([connection connectionStatus] == YMLURLConnectionStatusFailed) {
                [activeConnections removeObjectForKey:url];
                connection = [self initiateConnectionForURL:url andCallback:completion];
            }
            else {
                [connection addCallBack:completion];
            }
        }
        else {
            connection = [self initiateConnectionForURL:url andCallback:completion];
        }
    }
    
    return connection;
}

- (void) removeConnectionForURL:(NSString *)url {
    if ([activeConnections objectForKey:url]) {
        [activeConnections removeObjectForKey:url];
    }
}

- (void) clearData {
    [activeConnections removeAllObjects];
}


#pragma mark - Private Methods

- (YMLURLConnection *) initiateConnectionForURL:(NSString *)url andCallback:(YMLURLConnectionDidFinished)completion {
    NSData *data = [YMLURLConnection dataForURL:url];
    if (!IS_OBJ_NILL_OR_NULL(data) || [data length] == 0) {
        YMLURLConnection *connection = [[YMLURLConnection alloc] initWithURL:url];
        [connection addCallBack:completion];
        [connection startFetching];
        
        [activeConnections setObject:connection forKey:url];
        
        return connection;
    }
    
    completion(url, data);
    
    return nil;
}

- (void) connectionDidFinishLoadingNotification:(NSNotification *)notification {
//    [self removeConnectionForURL:[notification object]];
}

@end
