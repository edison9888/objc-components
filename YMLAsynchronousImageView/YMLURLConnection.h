//
//  YMLURLConnection.h
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YMLURLConnectionFinishedNotification            @"YMLURLConnectionFinishedNotification"

typedef enum YMLURLConnectionStatus {
    YMLURLConnectionStatusFinished = 0,
    YMLURLConnectionStatusLoading,
    YMLURLConnectionStatusFailed
}YMLURLConnectionStatus;

typedef void (^YMLURLConnectionDidFinished)(NSString *imageDataURL, NSData *imageData);

@interface YMLURLConnection : NSURLConnection {    
    YMLURLConnectionStatus connectionStatus;
}

@property (nonatomic, readonly) YMLURLConnectionStatus connectionStatus;

+ (NSData *) dataForURL:(NSString *)url;

- (id) initWithURL:(NSString *)url;
- (void) startFetching;
- (NSData *) responseData;
- (void) addCallBack:(YMLURLConnectionDidFinished)callBack;
- (void) cancelCallBack:(YMLURLConnectionDidFinished)callBack;
- (void) cancelAllCallBacks;

@end
