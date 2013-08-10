//
//  TUAlbumPhotosView.m
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 4/30/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUAlbumPhotosView.h"
#import "YMLAssetLibrary.h"
#import "AQGridView.h"
#import "TUGridCell.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface TUAlbumPhotosView () <AQGridViewDataSource, AQGridViewDelegate, YMLAssetLibraryDelegate> {
    NSUInteger selectedIndex;
    YMLAssetLibrary *assetLibrary;
    AQGridView *photosGridView;
}

@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id target;
@property (nonatomic, strong) ALAssetsGroup *group;

@end



@implementation TUAlbumPhotosView

- (id) initWithFrame:(CGRect)frame target:(id)__target selector:(SEL)__selector {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTarget:__target];
        [self setSelector:__selector];
        
        assetLibrary = [YMLAssetLibrary assetLibrary];
        [[YMLAssetLibrary assetLibrary] addDelegate:self];
        
        photosGridView = [[AQGridView alloc] initWithFrame:[self bounds]];
        [photosGridView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
        [photosGridView setDelegate:self];
        [photosGridView setDataSource:self];
        [self addSubview:photosGridView];
    }
    return self;
}


#pragma mark - AQGridView DataSource

- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView {
    if (!_group) {
        return 0;
    }
    
    return [[[assetLibrary assetsByAlbum] objectForKey:[_group valueForProperty:ALAssetsGroupPropertyPersistentID]] count];
}

- (AQGridViewCell *) gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    TUGridCell *cell = (TUGridCell *)[gridView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[TUGridCell alloc] initWithFrame:CGRectMake(0, 0, GRID_SIZE.width - 5, GRID_SIZE.height - 5) reuseIdentifier:@"Cell"];
        [[cell layer] setCornerRadius:2.0];
        [[cell layer] setBorderColor:[BORDER_GREEN_COLOR CGColor]];
        [[cell layer] setBorderWidth:0.0];
        [cell setClipsToBounds:YES];
        [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
        [cell setSelectionGlowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        [cell setEnableHighlighting:NO];
    }
    
    [cell clear];
    
    NSMutableArray *assets = [[assetLibrary assetsByAlbum] objectForKey:[_group valueForProperty:ALAssetsGroupPropertyPersistentID]];
    
    ALAsset *asset = [assets objectAtIndex:index];
    [cell setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    
    if (selectedIndex == index) {
        [[cell layer] setBorderWidth:2.0];
    }
    else {
        [[cell layer] setBorderWidth:0.0];
    }
    
    return cell;
}

- (CGSize) portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return GRID_SIZE;
}


#pragma mark - Grid View Delegate

- (void) gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
//    if (selectedIndex == index) {
//        return;
//    }
    
    TUGridCell *cell = (TUGridCell *)[gridView cellForItemAtIndex:selectedIndex];
    if (cell) {
        [[cell layer] setBorderWidth:0.0];
    }
    
    selectedIndex = index;
    
    cell = (TUGridCell *)[gridView cellForItemAtIndex:selectedIndex];
    [[cell layer] setBorderWidth:2.0];
    
    NSMutableArray *assets = [[assetLibrary assetsByAlbum] objectForKey:[_group valueForProperty:ALAssetsGroupPropertyPersistentID]];
    ALAsset *asset = [assets objectAtIndex:index];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_selector withObject:asset];
#pragma clang diagnostic pop
}


#pragma mark - YMLImagePicker Delegate

- (void) assetLibraryDidFinishLoading {
    [photosGridView reloadData];
}


#pragma mark - Public Methods

- (void) setAlbum:(ALAssetsGroup *)album {
    [self setGroup:album];
    [photosGridView reloadData];
}


#pragma mark - Dealloc

- (void) dealloc {
    [[YMLAssetLibrary assetLibrary] removeDelegate:self];
    
    photosGridView = nil;
    _selector = nil;
    _group = nil;
}

@end
