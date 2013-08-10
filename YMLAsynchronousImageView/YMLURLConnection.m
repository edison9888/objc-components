//
//  YMLURLConnection.m
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import "TPSharedNetworkAccessEngine.h"
#import "YMLURLConnection.h"

@interface YMLURLConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSString *URL;
    NSMutableURLRequest *request;
    NSMutableData *imageData;
    NSMutableArray *callBacks;
}

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, copy) NSString *URL;

@end


@implementation YMLURLConnection

@synthesize URL;
@synthesize request;
@synthesize imageData;
@synthesize connectionStatus;

- (id) initWithURL:(NSString *)url {
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request addValue:[NSString stringWithFormat:@"%@;",[TPSharedNetworkAccessEngine Cookie]] forHTTPHeaderField:@"Cookie"];
    
    self = [super initWithRequest:request delegate:self];
    if (self) {
        [self setURL:url];
        imageData = [[NSMutableData alloc] initWithData:[NSData data]];
        callBacks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Class Methods

+ (NSData *) dataForURL:(NSString *)url {
    @autoreleasepool {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request addValue:[NSString stringWithFormat:@"%@;",[TPSharedNetworkAccessEngine Cookie]] forHTTPHeaderField:@"Cookie"];
        
        NSCachedURLResponse *imageCachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        return [imageCachedResponse data];
    }
}


#pragma mark - Connection Delegate

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    connectionStatus = YMLURLConnectionStatusFinished;
    [self invokeCallBacks];
    [self setRequest:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YMLURLConnectionFinishedNotification object:URL];
    });
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    connectionStatus = YMLURLConnectionStatusFailed;
    [self setImageData:nil];
}


#pragma mark - Private Methods

- (void) invokeCallBacks {
    if ([callBacks count] > 0) {
        for (YMLURLConnectionDidFinished callBack in callBacks) {
            callBack(URL, imageData);
        }
        
        [callBacks removeAllObjects];
    }
}


#pragma mark - Public Methods

- (void) startFetching {
    NSCachedURLResponse *imageCachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (IS_OBJ_NILL_OR_NULL(imageCachedResponse)) {
        connectionStatus = YMLURLConnectionStatusLoading;
        [self start];
    }
    else {
        [self setImageData:[NSMutableData dataWithData:[imageCachedResponse data]]];
        
        connectionStatus = YMLURLConnectionStatusFinished;
        [self invokeCallBacks];
        [self setRequest:nil];
    }
}

- (NSData *) responseData {
    if (connectionStatus == YMLURLConnectionStatusFinished) {
        return imageData;
    }
    
    return nil;
}

- (void) addCallBack:(YMLURLConnectionDidFinished)callBack {
    [callBacks addObject:callBack];
}

- (void) cancelCallBack:(YMLURLConnectionDidFinished)callBack {
    if ([callBacks containsObject:callBack]) {
        [callBacks removeObject:callBack];
    }
}

- (void) cancelAllCallBacks {
    [callBacks removeAllObjects];
}

@end
