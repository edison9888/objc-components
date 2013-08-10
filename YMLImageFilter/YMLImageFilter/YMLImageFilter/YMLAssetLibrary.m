//
//  YMLAssetLibrary.m
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/27/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "YMLAssetLibrary.h"

#import <AssetsLibrary/AssetsLibrary.h>

static YMLAssetLibrary *assetLibrary = nil;

@interface YMLAssetLibrary () {
    NSMutableArray *delegates;
    ALAssetsLibrary *assetLibrary;
}

@end


@implementation YMLAssetLibrary

+ (YMLAssetLibrary *) assetLibrary {
    if (assetLibrary == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            assetLibrary = [[[self class] alloc] init];
        });
    }
    
    return assetLibrary;
}


#pragma mark - Singleton Override Methods

+ (id) allocWithZone:(NSZone *)zone {
    if (assetLibrary == nil) {
        assetLibrary = [super allocWithZone:zone];
        return assetLibrary;
    }
    
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        _allAssets = [[NSMutableArray alloc] init];
        _albums = [[NSMutableArray alloc] init];
        _assetsByAlbum = [[NSMutableDictionary alloc] init];
        
        delegates = [[NSMutableArray alloc] init];
        assetLibrary = [[ALAssetsLibrary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(assetLibraryChangedNotification:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - Public Methods

- (void) loadPhotos {
    static BOOL isLoadingPhotos = NO;
    
    if (isLoadingPhotos) { return; }
    isLoadingPhotos = YES;
    _isLoaded = NO;
    
    [_allAssets removeAllObjects];
    [_albums removeAllObjects];
    [_assetsByAlbum removeAllObjects];
    
    typeof(self) __weak weakSelf = self;
    [assetLibrary enumerateGroupsWithTypes:(ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum)
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if (group) {
                                        YMLAssetLibrary *strongSelf = weakSelf;
                                        if ([group numberOfAssets] > 0) {
                                            [strongSelf->_albums addObject:group];
                                            
                                            NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                                            NSMutableArray *groupAssets = [[NSMutableArray alloc] init];
                                            [_assetsByAlbum setObject:groupAssets forKey:groupID];
                                            
                                            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                if (strongSelf && result && [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                                                    [(NSMutableArray *)[strongSelf->_assetsByAlbum objectForKey:groupID] insertObject:result atIndex:0];
                                                    [strongSelf->_allAssets insertObject:result atIndex:0];
                                                }
                                            }];
                                        }
                                    }
                                    else if (stop) {
                                        YMLAssetLibrary *strongSelf = weakSelf;
                                        if (strongSelf) {
                                            strongSelf->_isLoaded = YES;
                                            
                                            for (id<YMLAssetLibraryDelegate>delegate in delegates) {
                                                if ([delegate respondsToSelector:@selector(assetLibraryDidFinishLoading)]) {
                                                    [delegate assetLibraryDidFinishLoading];
                                                }
                                            }
                                            isLoadingPhotos = NO;
                                        }
                                    }
                                }
                              failureBlock:^(NSError *error) {
                                      YMLAssetLibrary *strongSelf = weakSelf;
                                      if (strongSelf) {
                                          if ([error code] == ALAssetsLibraryAccessUserDeniedError || [error code] == ALAssetsLibraryAccessGloballyDeniedError) {
                                              for (id<YMLAssetLibraryDelegate>delegate in delegates) {
                                                  if ([delegate respondsToSelector:@selector(assetLibraryDidReceiveAccessDenied)]) {
                                                      [delegate assetLibraryDidReceiveAccessDenied];
                                                  }
                                              }
                                          }
                                          else {
                                              for (id<YMLAssetLibraryDelegate>delegate in delegates) {
                                                  if ([delegate respondsToSelector:@selector(assetLibraryDidReceiveError:)]) {
                                                      [delegate assetLibraryDidReceiveError:error];
                                                  }
                                              }
                                          }
                                          
                                          isLoadingPhotos = NO;
                                      }
                              }];
}

- (void) saveImage:(UIImage *)image inAlbum:(NSString *)albumName {
    [assetLibrary saveImage:image toAlbum:albumName withCompletionBlock:^(NSError *error) {}];
}

- (void) addDelegate:(id<YMLAssetLibraryDelegate>)delegate {
    if (delegate && ![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

- (void) removeDelegate:(id<YMLAssetLibraryDelegate>)delegate {
    if (delegate && [delegates containsObject:delegate]) {
        [delegates removeObject:delegate];
    }
}

- (void) removeAllDelegates {
    delegates = nil;
    delegates = [[NSMutableArray alloc] init];
}

- (void) clearData {
    _isLoaded = NO;
    
    _allAssets = nil;
    _allAssets = [[NSMutableArray alloc] init];
    
    _albums = nil;
    _albums = [[NSMutableArray alloc] init];
    
    _assetsByAlbum = nil;
    _assetsByAlbum = [[NSMutableDictionary alloc] init];
}


#pragma mark - Notification

- (void) assetLibraryChangedNotification:(NSNotification *)notification {
    [self loadPhotos];
}

@end
