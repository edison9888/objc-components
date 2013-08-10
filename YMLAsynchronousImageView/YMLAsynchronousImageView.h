//
//  YMLAsynchronousImageView.h
//  Shutterfly
//
//  Created by Karthik Keyan B on 8/5/12.
//  Copyright (c) 2012 YMediaLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAsynchronousImageData.h"

@interface YMLAsynchronousImageView : UIImageView

- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder;
- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder completion:(void (^)(void))completion;
- (void) imageDataForURL:(NSString *)url placeHolder:(UIImage *)placeHolder completion:(void (^)(void))completion forceReload:(BOOL)forceReload;

@end
