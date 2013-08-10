//
//  YMLAsynchronousImageView.m
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import "YMLAsynchronousImageView.h"

@interface YMLAsynchronousImageView () {
    YMLURLConnectionDidFinished callBack;
    YMLURLConnection *connection;
}

@end

@implementation YMLAsynchronousImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder {
    [self imageDataForURL:url placeHolder:placeHolder completion:nil];
}

- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder completion:(void (^)(void))completion {
    [self imageDataForURL:url placeHolder:placeHolder completion:completion forceReload:NO];
}

- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder completion:(void (^)(void))completion forceReload:(BOOL)forceReload {
    if (connection && callBack) {
        [connection cancelCallBack:callBack];
    }
    
    __block YMLAsynchronousImageView *weakReference = self;
    callBack = ^(NSString *imageDataURL, NSData *imageData) {
        if (!IS_OBJ_NILL_OR_NULL(imageData) && [imageData length] != 0) {
            [weakReference setImage:[UIImage imageWithData:imageData]];
        }
        
        if (completion) {
            completion();
        }
        
        weakReference = nil;
    };
    
    [self setImage:placeHolder];
    connection = [[YMLAsynchronousImageData imageData] connectionForURL:url completion:callBack forceReload:forceReload];
}

@end
