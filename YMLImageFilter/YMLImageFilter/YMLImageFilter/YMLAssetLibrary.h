//
//  YMLAssetLibrary.h
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/27/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMLAssetLibraryDelegate;

@interface YMLAssetLibrary : NSObject

@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, readonly) NSMutableArray *allAssets, *albums;
@property (nonatomic, readonly) NSMutableDictionary *assetsByAlbum;

+ (YMLAssetLibrary *) assetLibrary;

- (void) loadPhotos;
- (void) saveImage:(UIImage *)image inAlbum:(NSString *)albumName;
- (void) addDelegate:(id<YMLAssetLibraryDelegate>)delegate;
- (void) removeDelegate:(id<YMLAssetLibraryDelegate>)delegate;
- (void) removeAllDelegates;
- (void) clearData;

@end


@protocol YMLAssetLibraryDelegate<NSObject>

@optional
- (void) assetLibraryDidReceiveAccessDenied;
- (void) assetLibraryDidReceiveError:(NSError *)error;
- (void) assetLibraryDidFinishLoading;

@end
