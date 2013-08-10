//
//  TUPhotoLibraryViewController.m
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/8/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUPhotoLibraryViewController.h"
#import "TUAlbumPhotosView.h"
#import "YMLAssetLibrary.h"
#import "TUAlbumCell.h"
#import "YMLCropView.h"
#import "AQGridView.h"
#import "TUGridCell.h"

#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <QuartzCore/QuartzCore.h>

@interface TUPhotoLibraryViewController () <AQGridViewDataSource, AQGridViewDelegate, UIAlertViewDelegate, YMLAssetLibraryDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSUInteger selectedIndex;
    
    UIView *gridContainerView;
    UIImageView *cameraGrids;
    UIButton *galleryButton, *albumButton;
    UITableView *albumsTableView;
    
    TUAlbumPhotosView *albumPhotosView;
    AQGridView *photosGridView;
    YMLCropView *cropView;
    YMLBarButton *nextBarButton;
}

- (void) UICreateCropView;
- (void) UICreateGridLines;
- (void) UICreatePhotoGrid;
- (void) UICreateAlbumsTableView;
- (void) UICreateAlbumPhotosView;

- (void) close;
- (void) next;
- (void) openContainer;
- (void) closeContainer;
- (void) gallery;
- (void) albums;
- (void) openAlbumPhotoView;
- (void) closeAlbumPhotoView;
- (void) selectAsset:(ALAsset *)asset;
- (void) panGesture:(UIPanGestureRecognizer *)gesture;

@end

@implementation TUPhotoLibraryViewController

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_view_bg" withExtension:@"png"]]];
    
    [self UICreateCropView];
    [self UICreateGridLines];
    [self UICreatePhotoGrid];
    [self UICreateAlbumsTableView];
    [self UICreateAlbumPhotosView];
    
    [[YMLAssetLibrary assetLibrary] addDelegate:self];
    
    if (![[YMLAssetLibrary assetLibrary] isLoaded]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[YMLAssetLibrary assetLibrary] loadPhotos];
        });
    }
    else {
        if ([[[YMLAssetLibrary assetLibrary] allAssets] count] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Library"
                                                                message:@"There are no photos in your library."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else {
            if (_defaultImage) {
                [cropView setImageWithAspectFill:_defaultImage];
            }
            else {
                ALAsset *asset = [[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:0];
                ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                                     scale:[defaultRep scale]
                                               orientation:[[asset valueForProperty:ALAssetPropertyOrientation] intValue]];
                
                [cropView setImageWithAspectFill:image];
            }
            
            [cameraGrids setHidden:NO];
            [gridContainerView setHidden:NO];
            [photosGridView reloadData];
        }
    }
}

- (void) UISetupNavigationBar {
    [super UISetupNavigationBar];
    
    [navigationBar setTitle:NSLocalizedString(@"Select a Photo", @"")];
    [[navigationBar titleLabel] setTextColor:WHITE_COLOR];
    [navigationBar setBackgroundColor:CLEAR_COLOR];
    [[navigationBar titleLabel] setShadowOffset:CGSizeMake(0, 0)];
    [[navigationBar titleLabel] setShadowColor:CLEAR_COLOR];
    [navigationBar setBackgroundImage:nil];
    
    
    YMLBarButton *backBarButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeEmptyDone];
    [backBarButton setFrame:CGRectMake(backBarButton.left, backBarButton.top, 35, 30)];
    [backBarButton setImageEdgeInsets:UIEdgeInsetsMake(1, 2, 0, 0)];
    [backBarButton setImage:[UIImage imageNameInBundle:@"ico_camera_back" withExtension:@"png"] forState:UIControlStateNormal];
    [backBarButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_cancel" extension:@"png" topCap:7 leftCap:7 bottomCap:6 andRightCap:6] forState:UIControlStateNormal];
    [backBarButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setLeftBarButton:backBarButton];
    
    
    CGSize size = CGSizeMake(60, 30);
    nextBarButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeEmptyDone];
    [nextBarButton setFrame:CGRectMake(nextBarButton.left, nextBarButton.top, size.width, size.height)];
    [nextBarButton setTitle:NSLocalizedString(@"Next", @"") forState:UIControlStateNormal];
    [nextBarButton setTitleColor:[UIColor colorWith255Red:43 green:52 blue:51 alpha:1.0] forState:UIControlStateNormal];
    [nextBarButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_next" extension:@"png" topCap:7 leftCap:7 bottomCap:6 andRightCap:6] forState:UIControlStateNormal];
    [nextBarButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setRightBarButton:nextBarButton];
}

- (void) UICreateCropView {
    CGRect cropRect;
    if (CGSizeEqualToSize(_cropSize, CGSizeZero)) {
        cropRect = CGRectMake((self.view.innerWidth - TU_IMAGE_SIZE.width) * 0.5, 51, TU_IMAGE_SIZE.width, TU_IMAGE_SIZE.height);
    }
    else {
        cropRect = CGRectMake((self.view.innerWidth - _cropSize.width) * 0.5, 100, _cropSize.width, _cropSize.height);
    }
    
    cropView = [[YMLCropView alloc] initWithFrame:[[self view] bounds] image:nil cropRect:cropRect];
    [cropView setBackgroundColor:CLEAR_COLOR];
    [[cropView overLay] setOverlayColor:[UIColor colorWith255Red:9 green:9 blue:9 alpha:0.45]];
//    [[cropView overLay] setOverlayColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_view_bg" withExtension:@"png"]]];
    [[cropView overLay] setOpaque:NO];
    [[[cropView overLay] layer] setOpaque:NO];
    [[cropView overLay] setUserInteractionEnabled:NO];
    [[cropView footerView] removeFromSuperview];
    [[self view] addSubview:cropView];
}

- (void) UICreateGridLines {
    cameraGrids = [[UIImageView alloc] initWithFrame:CGRectInset([cropView cropRect], 1, 1)];
    [cameraGrids setUserInteractionEnabled:NO];
    [cameraGrids setHidden:YES];
//    [cameraGrids setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"bg_grid" withExtension:@"png"]]];
    [cameraGrids setImage:[UIImage imageNameInBundle:@"bg_grid" withExtension:@"png"]];
    [[self view] addSubview:cameraGrids];
}

- (void) UICreatePhotoGrid {
    gridContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT + TU_IMAGE_SIZE.height + 24, self.view.innerWidth, self.view.innerHeight - NAVIGATIONBAR_HEIGHT)];
    [gridContainerView setClipsToBounds:YES];
    [gridContainerView setHidden:YES];
    [gridContainerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_bottombar" withExtension:@"png"]]];
    [[self view] addSubview:gridContainerView];
    
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.innerWidth, 44)];
    [headerView setUserInteractionEnabled:YES];
    [headerView setContentMode:UIViewContentModeCenter];
    [headerView setImage:[UIImage imageNameInBundle:@"ico_libraryviewpan" withExtension:@"png"]];
    [gridContainerView addSubview:headerView];
    
    
    
    galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [galleryButton setFrame:CGRectMake(20, (46 - 26) * 0.5, 82, 26)];
    [[galleryButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
    [galleryButton setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
    [galleryButton setTitle:NSLocalizedString(@"Gallery", @"") forState:UIControlStateNormal];
    [galleryButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn_hl" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [galleryButton addTarget:self action:@selector(gallery) forControlEvents:UIControlEventTouchUpInside];
    [gridContainerView addSubview:galleryButton];
    
    
    albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumButton setFrame:CGRectMake(gridContainerView.innerWidth - 102, (46 - 26) * 0.5, 82, 26)];
    [[albumButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
    [albumButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [albumButton setTitle:NSLocalizedString(@"Albums", @"") forState:UIControlStateNormal];
    [albumButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [albumButton addTarget:self action:@selector(albums) forControlEvents:UIControlEventTouchUpInside];
    [gridContainerView addSubview:albumButton];
    
    
    UIPanGestureRecognizer *panGestor = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [headerView addGestureRecognizer:panGestor];
    
    
    photosGridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, headerView.bottom - 1, gridContainerView.innerWidth, gridContainerView.innerHeight - headerView.bottom + 1)];
    [photosGridView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    [photosGridView setDelegate:self];
    [photosGridView setDataSource:self];
//    [photosGridView setUserInteractionEnabled:NO];
    [gridContainerView addSubview:photosGridView];
}

- (void) UICreateAlbumsTableView {
    albumsTableView = [[UITableView alloc] initWithFrame:[photosGridView frame] style:UITableViewStylePlain];
    [albumsTableView setDelegate:self];
    [albumsTableView setDataSource:self];
    [albumsTableView setBackgroundColor:CLEAR_COLOR];
    [albumsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [albumsTableView setAlpha:0.0];
    [albumsTableView setUserInteractionEnabled:NO];
    [gridContainerView addSubview:albumsTableView];
}

- (void) UICreateAlbumPhotosView {
    albumPhotosView = [[TUAlbumPhotosView alloc] initWithFrame:CGRectMake(photosGridView.right, photosGridView.top, photosGridView.width, photosGridView.height) target:self selector:@selector(selectAsset:)];
    [albumPhotosView setUserInteractionEnabled:NO];
    [gridContainerView addSubview:albumPhotosView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[YMLAssetLibrary assetLibrary] clearData];
    [[YMLAssetLibrary assetLibrary] removeDelegate:self];
}


#pragma mark - AQGridView DataSource

- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView {
    return [[[YMLAssetLibrary assetLibrary] allAssets] count];
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
    
    if (selectedIndex == index) {
        [[cell layer] setBorderWidth:2.0];
    }
    else {
        [[cell layer] setBorderWidth:0.0];
    }
    
    ALAsset *asset = [[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:index];
    [cell setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    
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
    
    __block ALAsset *asset = [[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:index];
    [self selectAsset:asset];
}


#pragma mark - TUAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[YMLAssetLibrary assetLibrary] removeDelegate:self];
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoLibraryDidClose:)]) {
        [_delegate photoLibraryDidClose:self];
    }
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - YMLAsset Delegate

- (void) assetLibraryDidReceiveAccessDenied {
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TUPhotoLibraryViewController *strongSelf = weakSelf;
        
        if (strongSelf) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Library"
                                                                message:@"Seems like you don't have permission to access photos"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void) assetLibraryDidReceiveError:(NSError *)error {
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TUPhotoLibraryViewController *strongSelf = weakSelf;
        
        if (strongSelf) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Library"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void) assetLibraryDidFinishLoading {
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TUPhotoLibraryViewController *strongSelf = weakSelf;
        
        if (strongSelf) {
            if ([[[YMLAssetLibrary assetLibrary] allAssets] count] == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Library"
                                                                    message:@"There are no photos in your library."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else {
                if ([strongSelf defaultImage]) {
                    [cropView setImageWithAspectFill:[strongSelf defaultImage]];
                }
                else {
                    if (strongSelf->albumPhotosView.left == 0) {
                        [self albums];
                    }
                    else {
                        ALAsset *asset = [[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:0];
                        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                                             scale:[defaultRep scale]
                                                       orientation:[[asset valueForProperty:ALAssetPropertyOrientation] intValue]];
                        
                        [strongSelf->cropView setImageWithAspectFill:image];
                    }
                }
                
                [strongSelf->cameraGrids setHidden:NO];
                [strongSelf->gridContainerView setHidden:NO];
                [strongSelf->albumsTableView reloadData];
                [strongSelf->photosGridView reloadData];
            }
        }
    });
}


#pragma mark - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[YMLAssetLibrary assetLibrary] albums] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[TUAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    ALAssetsGroup *group = [[[YMLAssetLibrary assetLibrary] albums] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[group valueForProperty:ALAssetsGroupPropertyName]];
    [[cell imageView] setImage:[UIImage imageWithCGImage:[group posterImage]]];
    
    [cell setCount:[group numberOfAssets]];
    
    return cell;
}


#pragma mark - TableView Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [albumButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [albumButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [albumPhotosView setAlbum:[[[YMLAssetLibrary assetLibrary] albums] objectAtIndex:[indexPath row]]];
    
    [self openAlbumPhotoView];
}


#pragma mark - Private Methods

- (void) close {
    if (_delegate && [_delegate respondsToSelector:@selector(photoLibraryDidClose:)]) {
        [[YMLAssetLibrary assetLibrary] removeDelegate:self];
        [_delegate photoLibraryDidClose:self];
    }
}

- (void) next {
    if (_delegate && [_delegate respondsToSelector:@selector(photoLibrary:didSelectImage:)]) {
        [[YMLAssetLibrary assetLibrary] removeDelegate:self];
        [_delegate photoLibrary:self didSelectImage:[cropView crop]];
    }
}

- (void) openContainer {
    CGRect rect = [gridContainerView frame];
    rect.origin.y = NAVIGATIONBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [gridContainerView setFrame:rect];
    [UIView commitAnimations];
    
    [photosGridView setUserInteractionEnabled:YES];
    [albumsTableView setUserInteractionEnabled:YES];
    [albumPhotosView setUserInteractionEnabled:YES];
}

- (void) closeContainer {
    CGRect rect = [gridContainerView frame];
    rect.origin.y = NAVIGATIONBAR_HEIGHT + TU_IMAGE_SIZE.height + 24;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [gridContainerView setFrame:rect];
    [UIView commitAnimations];
    
//    [photosGridView setUserInteractionEnabled:NO];
    [albumsTableView setUserInteractionEnabled:NO];
    [albumPhotosView setUserInteractionEnabled:NO];
}

- (void) gallery {    
    if (albumPhotosView.left == 0) {
        [albumPhotosView setAlbum:nil];
        [self closeAlbumPhotoView];
        
        [self selectAsset:[[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:selectedIndex]];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [photosGridView setAlpha:1.0];
    [albumsTableView setAlpha:0.0];
    [galleryButton setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
    [albumButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [galleryButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn_hl" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [albumButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [UIView commitAnimations];
    
    [self openContainer];
}

- (void) albums {
    if (albumPhotosView.left == 0) {
        if (gridContainerView.top == NAVIGATIONBAR_HEIGHT) {
            [albumPhotosView setAlbum:nil];
            [self closeAlbumPhotoView];
            
            [albumButton setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
            [albumButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn_hl" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
            
            [self selectAsset:[[[YMLAssetLibrary assetLibrary] allAssets] objectAtIndex:selectedIndex]];
        }
    }
    else {
        [UIView beginAnimations:nil context:NULL];
        [photosGridView setAlpha:0.0];
        [albumsTableView setAlpha:1.0];
        [galleryButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [albumButton setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
        [galleryButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
        [albumButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn_hl" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
        [UIView commitAnimations];
    }
    
    [self openContainer];
}

- (void) openAlbumPhotoView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect rect = [albumsTableView frame];
    rect.origin.x = -gridContainerView.width;
    [albumsTableView setFrame:rect];
    
    rect = [albumPhotosView frame];
    rect.origin.x = 0;
    [albumPhotosView setFrame:rect];
    
    [UIView commitAnimations];
}

- (void) closeAlbumPhotoView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect rect = [albumsTableView frame];
    rect.origin.x = 0;
    [albumsTableView setFrame:rect];
    
    rect = [albumPhotosView frame];
    rect.origin.x = gridContainerView.width;
    [albumPhotosView setFrame:rect];
    
    [UIView commitAnimations];
}

- (void) selectAsset:(ALAsset *)asset {
    if (asset) {
        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                             scale:[defaultRep scale]
                                       orientation:[[asset valueForProperty:ALAssetPropertyOrientation] intValue]];
        [cropView setImageWithAspectFill:image];
        
        [self closeContainer];
    }
}


#pragma mark - Gesture

- (void) panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:[self view]];
    CGPoint velocity = [gesture velocityInView:[self view]];
    
    if (velocity.y < -1400) {
        [self openContainer];
        return;
    }
    else if (velocity.y > 1400) {
        [self closeContainer];
        return;
    }
    
    
    if ([gesture state] == UIGestureRecognizerStateChanged) {
        if (point.y > NAVIGATIONBAR_HEIGHT && point.y < (NAVIGATIONBAR_HEIGHT + TU_IMAGE_SIZE.height)) {
            CGRect rect = [gridContainerView frame];
            rect.origin.y = point.y;
            
            [UIView beginAnimations:nil context:NULL];
            [gridContainerView setFrame:rect];
            [UIView commitAnimations];
        }
    }
    else if ([gesture state] == UIGestureRecognizerStateCancelled || [gesture state] == UIGestureRecognizerStateEnded) {
        if (point.y <= (self.view.innerHeight/2)) {
            [self openContainer];
        }
        else if (point.y > (self.view.innerHeight/2)) {
            [self closeContainer];
        }
    }
}


#pragma mark - Dealloc

- (void) nullify {
    gridContainerView = nil;
    photosGridView = nil;
    cameraGrids = nil;
    cropView = nil;
    _defaultImage = nil;
    
    [super nullify];
}

@end
