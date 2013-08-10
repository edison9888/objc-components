//
//  YMLAsynchronousImageData.h
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLURLConnection.h"

@interface YMLAsynchronousImageData : NSObject

+ (YMLAsynchronousImageData *) imageData;

- (YMLURLConnection *) connectionForURL:(NSString *)url completion:(YMLURLConnectionDidFinished)completion;
- (YMLURLConnection *) connectionForURL:(NSString *)url completion:(YMLURLConnectionDidFinished)completion forceReload:(BOOL)forceReload;
- (void) removeConnectionForURL:(NSString *)url;
- (void) clearData;

@end
