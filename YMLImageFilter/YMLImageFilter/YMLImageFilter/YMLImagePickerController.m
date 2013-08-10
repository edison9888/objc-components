
//  YMLImageFilter
//
//  Created by vivek Rajanna on 23/01/13.
//  Copyright (c) 2013 ymedialabs. All rights reserved.
//

#import "TUPhotoLibraryViewController.h"
#import "YMLImagePickerController.h"
#import "GrayscaleContrastFilter.h"
#import "YMLNavigationBar.h"
#import "BlurOverlayView.h"
#import "YMLAssetLibrary.h"
#import "YMLCropView.h"
#import "GPUImage.h"

#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>

#define kStaticBlurSize 2.0f
#define FILTER_BUTTON_TAG 1000
#define NUMBER_OF_FILTERS 25

static AVCaptureFlashMode flashMode = AVCaptureFlashModeAuto;
static AVCaptureTorchMode torchMode = AVCaptureTorchModeAuto;

@interface YMLImagePickerController () <YMLCropViewDelegate, TUPhotoLibraryViewControllerDelegate, YMLAssetLibraryDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate> {
    BOOL isCameraProcessing, isCameraConfigured, isStatic, hasBlur;
    int selectedFilter, filterHeight;
    
    CGFloat rotation;
    CGFloat outputJPEGQuality;
    CGSize focusViewSize;
    CGRect cropRect;
    
    UIImageOrientation staticPictureOriginalOrientation;
    
    UIView *bottomBar, *photoBar, *flashView;
    UIScrollView *filterScrollView;
    UIImageView *focusView, *gridView;
    UIButton *cameraToggleButton, *blurToggleButton, *filtersToggleButton, *libraryToggleButton, *flashToggleButton, *photoCaptureButton, *cancelButton, *toggleCameraButton, *gridButton, *galleryButton, *effectButton, *rotationButton, *brightnessToggleButton, *flashOffButton, *flashOnButton, *flashAutoButton;
    
    YMLNavigationBar *navigationBar;
    YMLBarButton *nextBarButton, *backBarButton;
    
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageOutput<GPUImageInput> *blurFilter;
    GPUImagePicture *staticPicture;
    BlurOverlayView *blurOverlayView;
    GPUImageCropFilter *cropFilter;
    GPUImageHighlightShadowFilter *brightnessFilter;
    GPUImageView *imageView, *captureImageView, *cropImageView;
    YMLCropViewOverlay *overLay;
    TUPhotoLibraryViewController *imagePickerController;
}

- (void) UICreateImageView;
- (void) UICreateGridView;
- (void) UICreateOverlay;
- (void) UICreateNavigationBar;
- (void) UICreateScrollView;
- (void) UICreateBottomBar;
- (void) UICreateGestures;
- (void) UICreateFocusView;
- (void) UICreateBlurOvelay;
- (void) UICreateFlashView;

- (void) loadPhotoLibrary;
- (void) loadFilters;
- (void) setUpInitialView;
- (void) setUpCamera;
- (void) filterClicked:(UIButton *)sender;
- (void) setFilter:(int)index;
- (NSString *) filterNameAtIndex:(int)index;
- (void) prepareLiveFilter;
- (void) prepareStaticFilter;
- (void) removeAllTargets;
- (void) captureImage;
- (void) showFilters;
- (void) hideFilters;
- (void) showBlurOverlay:(BOOL)show;
- (void) flashBlurOverlay;
- (void) showFocusViewAtPoint:(NSValue *)focusPoint;
- (void) hideFocusView;
- (UIImage *) increaseQuality:(UIImage *)inputImage;
- (void) next;
- (void) switchToLibrary:(id)sender;
- (void) toggleFlash:(UIButton *)button;
- (void) flashOff:(UIButton *)button;
- (void) flashOn:(UIButton *)button;
- (void) flashAuto:(UIButton *)button;
- (void) toggleBlur:(UIButton*)blurButton;
- (void) switchCamera;
- (void) takePhoto:(id)sender;
- (void) retakePhoto:(UIButton *)button;
- (void) cancel:(id)sender;
- (void) handlePan:(UIGestureRecognizer *)sender;
- (void) handleTapToFocus:(UITapGestureRecognizer *)tgr;
- (void) handlePinch:(UIPinchGestureRecognizer *)sender;
- (void) toggleFilters:(UIButton *)sender;
- (void) rotation:(UIButton *)sender;
- (void) toggleBrightness:(UIButton *)sender;
- (void) grid:(UIButton *)sender;

- (void) applicationDidEnterBackground:(NSNotification *)notification;
- (void) applicationDidBecomeActive:(NSNotification *)notification;

@end



@implementation YMLImagePickerController

@synthesize delegate, isImagePickerOnly;


#pragma mark - Init

- (id) init {
    self = [super init];
    
    if (self) {
        outputJPEGQuality = 1.0;
    }
    
    return self;
}


#pragma mark - View Life Cycle

- (void) loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:VIEW_FRAME];
    [rootView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_view_bg" withExtension:@"png"]]];
    [self setView:rootView];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    cropRect = CGRectMake((self.view.innerWidth - TU_IMAGE_SIZE.width) * 0.5, 51, TU_IMAGE_SIZE.width, TU_IMAGE_SIZE.height);
    
    filterHeight = 46;
    if (IS_IPHONE_5) {
        filterHeight = 117;
    }
    
    [self UICreateImageView];
    [self UICreateGridView];
    [self UICreateBlurOvelay];
    [self UICreateOverlay];
    [self UICreateNavigationBar];
    [self UICreateBottomBar];
    [self UICreateScrollView];
    [self UICreateFocusView];
    [self loadFilters];
    [self UICreateGestures];
    [self setUpInitialView];
    [self UICreateFlashView];
    
//    if (!isImagePickerOnly) {
//        [self loadPhotoLibrary];
//    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[YMLAssetLibrary assetLibrary] clearData];
    [[YMLAssetLibrary assetLibrary] removeDelegate:self];
}


#pragma mark - UIMethods

- (void) UICreateImageView {
    staticPictureOriginalOrientation = UIImageOrientationUp;
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1.0, 1.0)];
    filter = [[GPUImageFilter alloc] init];
    
    captureImageView = [[GPUImageView alloc] initWithFrame:[[self view] bounds]];
    [captureImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [[self view] addSubview:captureImageView];
    
    cropImageView = [[GPUImageView alloc] initWithFrame:cropRect];
    [cropImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [cropImageView setHidden:YES];
    [[self view] addSubview:cropImageView];
    
    imageView = captureImageView;
}

- (void) UICreateGridView {
    gridView = [[UIImageView alloc] initWithFrame:cropRect];
    [gridView setImage:[UIImage imageNameInBundle:@"bg_grid" withExtension:@"png"]];
    [gridView setHidden:YES];
    [[self view] addSubview:gridView];
}

- (void) UICreateOverlay {
    overLay = [[YMLCropViewOverlay alloc] initWithFrame:[[self view] bounds] cropRect:cropRect];
    [overLay setBackgroundColor:CLEAR_COLOR];
    [overLay setOverlayColor:[UIColor colorWith255Red:9 green:9 blue:9 alpha:0.45]];
    [overLay setOpaque:NO];
    [[overLay layer] setOpaque:NO];
    [overLay setUserInteractionEnabled:NO];
    [[self view] addSubview:overLay];
}

- (void) UICreateNavigationBar {
    navigationBar = [[YMLNavigationBar alloc] initWithFrame:CGRectZero];
    [navigationBar setTitle:nil];
    [navigationBar setBackgroundImage:nil];
    [navigationBar setBackgroundColor:CLEAR_COLOR];
    [[navigationBar titleLabel] setShadowOffset:CGSizeMake(0, 0)];
    [[navigationBar titleLabel] setShadowColor:CLEAR_COLOR];
    [navigationBar setActAsBarButton:NO];
    [[self view] addSubview:navigationBar];
    
    backBarButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeEmptyDone];
    [backBarButton setFrame:CGRectMake(backBarButton.left, backBarButton.top, 35, 30)];
    [backBarButton setImageEdgeInsets:UIEdgeInsetsMake(1, 2, 0, 0)];
    [backBarButton setImage:[UIImage imageNameInBundle:@"ico_camera_back" withExtension:@"png"] forState:UIControlStateNormal];
    [backBarButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_cancel" extension:@"png" topCap:7 leftCap:7 bottomCap:6 andRightCap:6] forState:UIControlStateNormal];
    [backBarButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setLeftBarButton:backBarButton];
    
    CGSize size = CGSizeMake(60, 30);
    nextBarButton = [[YMLBarButton alloc] initWithBarButtonType:YMLBarButtonTypeEmptyDone];
    [nextBarButton setFrame:CGRectMake(nextBarButton.left, nextBarButton.top, size.width, size.height)];
    [nextBarButton setTitle:NSLocalizedString(@"Next", @"") forState:UIControlStateNormal];
    [nextBarButton setTitleColor:[UIColor colorWith255Red:43 green:52 blue:51 alpha:1.0] forState:UIControlStateNormal];
    [nextBarButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_next" extension:@"png" topCap:7 leftCap:7 bottomCap:6 andRightCap:6] forState:UIControlStateNormal];
    [nextBarButton setBackgroundImage:[UIImage stretchableImageWithName:@"bg_next" extension:@"png" topCap:7 leftCap:7 bottomCap:6 andRightCap:6] forState:UIControlStateDisabled];
    [nextBarButton setEnabled:NO];
    [nextBarButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar setRightBarButton:nextBarButton];
    
    
    gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gridButton setFrame:CGRectMake((navigationBar.innerWidth - 34) * 0.5, (navigationBar.innerHeight - 34) * 0.5, 34, 34)];
    [gridButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    [gridButton setImage:[UIImage imageNameInBundle:@"ico_grid" withExtension:@"png"] forState:UIControlStateNormal];
    [gridButton addTarget:self action:@selector(grid:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:gridButton];
    
    
    if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
        flashToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [flashToggleButton setFrame:CGRectMake(gridButton.left - 49, gridButton.top, 34, 34)];
        if (flashMode == AVCaptureFlashModeAuto) {
            [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashauto" withExtension:@"png"] forState:UIControlStateNormal];
        }
        else if (flashMode == AVCaptureFlashModeOn) {
            [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashon" withExtension:@"png"] forState:UIControlStateNormal];
        }
        else {
            [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashoff" withExtension:@"png"] forState:UIControlStateNormal];
        }
        [flashToggleButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
        [flashToggleButton setEnabled:!isImagePickerOnly];
        [flashToggleButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
        [navigationBar addSubview:flashToggleButton];
    }
    
    
    // Toggle Camera
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        toggleCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [toggleCameraButton setFrame:CGRectMake(gridButton.right + 15, gridButton.top, 34, 34)];
        [toggleCameraButton setImage:[UIImage imageNameInBundle:@"ico_turncamera" withExtension:@"png"] forState:UIControlStateNormal];
        [toggleCameraButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
        [toggleCameraButton setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
        [toggleCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        [navigationBar addSubview:toggleCameraButton];
    }
}

- (void) UICreateBottomBar {
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.innerHeight - 44, self.view.innerWidth, 46 + filterHeight)];
    [bottomBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_bottombar" withExtension:@"png"]]];
    [[self view] addSubview:bottomBar];
    
    photoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.innerWidth, 46)];
    [photoBar setAlpha:1.0];
    [bottomBar addSubview:photoBar];
    
    
    photoCaptureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoCaptureButton setFrame:CGRectMake((photoBar.innerWidth - 49) * 0.5, ((photoBar.innerHeight - 49) * 0.5) - 1, 49, 49)];
    [photoCaptureButton setImage:[UIImage imageNameInBundle:@"btn_capture2" withExtension:@"png"] forState:UIControlStateNormal];
    [photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoBar addSubview:photoCaptureButton];
    
    
    galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [galleryButton setFrame:CGRectMake(20, (photoBar.innerHeight - 26) * 0.5, 82, 26)];
    [[galleryButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
    [galleryButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [galleryButton setTitle:NSLocalizedString(@"Gallery", @"") forState:UIControlStateNormal];
    [galleryButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [galleryButton addTarget:self action:@selector(switchToLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [photoBar addSubview:galleryButton];
    
    
    effectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [effectButton setFrame:CGRectMake(photoBar.innerWidth - 102, (photoBar.innerHeight - 26) * 0.5, 82, 26)];
    [[effectButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
    [effectButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [effectButton setTitle:NSLocalizedString(@"Effects", @"") forState:UIControlStateNormal];
    [effectButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [effectButton addTarget:self action:@selector(toggleFilters:) forControlEvents:UIControlEventTouchUpInside];
    [photoBar addSubview:effectButton];
    
    
    rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotationButton setFrame:CGRectMake(0, (photoBar.innerHeight - 44) * 0.5, 44, 44)];
    [rotationButton setImage:[UIImage imageNameInBundle:@"ico_rotate" withExtension:@"png"] forState:UIControlStateNormal];
    [rotationButton addTarget:self action:@selector(rotation:) forControlEvents:UIControlEventTouchUpInside];
    [rotationButton setAlpha:0.0];
    [photoBar addSubview:rotationButton];
    
    CALayer *separator1 = [CALayer layer];
    [separator1 setFrame:CGRectMake(rotationButton.innerWidth - 1, (rotationButton.innerHeight - 17) * 0.5, 1, 17)];
    [separator1 setBackgroundColor:[[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"img_separator" withExtension:@"png"]] CGColor]];
    [[rotationButton layer] addSublayer:separator1];
    
    
    blurToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blurToggleButton setFrame:CGRectMake(rotationButton.right, rotationButton.top, 44, 44)];
    [blurToggleButton setImage:[UIImage imageNameInBundle:@"ico_blur" withExtension:@"png"] forState:UIControlStateNormal];
    [blurToggleButton addTarget:self action:@selector(toggleBlur:) forControlEvents:UIControlEventTouchUpInside];
    [blurToggleButton setAlpha:0.0];
    [photoBar addSubview:blurToggleButton];
    
    CALayer *separator2 = [CALayer layer];
    [separator2 setFrame:CGRectMake(blurToggleButton.innerWidth - 1, (blurToggleButton.innerHeight - 17) * 0.5, 1, 17)];
    [separator2 setBackgroundColor:[[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"img_separator" withExtension:@"png"]] CGColor]];
    [[blurToggleButton layer] addSublayer:separator2];
    
    
    brightnessToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [brightnessToggleButton setFrame:CGRectMake(blurToggleButton.right, blurToggleButton.top, 44, 44)];
    [brightnessToggleButton setImage:[UIImage imageNameInBundle:@"ico_brightness" withExtension:@"png"] forState:UIControlStateNormal];
    [brightnessToggleButton addTarget:self action:@selector(toggleBrightness:) forControlEvents:UIControlEventTouchUpInside];
    [brightnessToggleButton setAlpha:0.0];
    [photoBar addSubview:brightnessToggleButton];
}

- (void) UICreateScrollView {
    filterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, photoBar.bottom - 2, bottomBar.innerWidth, filterHeight)];
    [filterScrollView setShowsHorizontalScrollIndicator:NO];
    [filterScrollView setShowsVerticalScrollIndicator:NO];
    [bottomBar addSubview:filterScrollView];
}

- (void) UICreateGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [captureImageView addGestureRecognizer:panGesture];
    
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [cropImageView addGestureRecognizer:panGesture2];
    
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [captureImageView addGestureRecognizer:pinchGesture];
    
    UIPinchGestureRecognizer *pinchGesture2 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [cropImageView addGestureRecognizer:pinchGesture2];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [captureImageView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [tapGesture2 setNumberOfTapsRequired:1];
    [tapGesture2 setNumberOfTouchesRequired:1];
    [cropImageView addGestureRecognizer:tapGesture2];
}

- (void) UICreateFocusView {
    focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_focusview.png"]];
    [focusView setAlpha:0];
    [focusView setCenter:[imageView center]];
	[imageView addSubview:focusView];
    
    focusViewSize = focusView.frame.size;
}

- (void) UICreateBlurOvelay {
    hasBlur = NO;
    
    blurOverlayView = [[BlurOverlayView alloc] initWithFrame:[[self view] bounds]];
    [blurOverlayView setAlpha:0];
    [[self view] addSubview:blurOverlayView];
}

- (void) UICreateFlashView {
    flashView = [[UIView alloc] initWithFrame:CGRectMake(flashToggleButton.left, flashToggleButton.top, flashToggleButton.width, 0)];
    [flashView setAlpha:0.0];
    [[self view] addSubview:flashView];
    
    flashOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashOffButton setFrame:CGRectMake(0, 0, 34, 34)];
    [flashOffButton setAlpha:0.0];
    [flashOffButton setImage:[UIImage imageNameInBundle:@"ico_flashoff" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOffButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOffButton addTarget:self action:@selector(flashOff:) forControlEvents:UIControlEventTouchUpInside];
    [flashView addSubview:flashOffButton];
    
    flashOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashOnButton setFrame:CGRectMake(0, 0, 34, 34)];
    [flashOnButton setAlpha:0.0];
    [flashOnButton setImage:[UIImage imageNameInBundle:@"ico_flashon" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOnButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOnButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
    [flashView addSubview:flashOnButton];
    
    flashAutoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashAutoButton setFrame:CGRectMake(0, 0, 34, 34)];
    [flashAutoButton setAlpha:0.0];
    [flashAutoButton setImage:[UIImage imageNameInBundle:@"ico_flashauto" withExtension:@"png"] forState:UIControlStateNormal];
    [flashAutoButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashAutoButton addTarget:self action:@selector(flashAuto:) forControlEvents:UIControlEventTouchUpInside];
    [flashView addSubview:flashAutoButton];
    
    if (flashMode == AVCaptureFlashModeOff) {
        [flashOffButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    }
    else if (flashMode == AVCaptureFlashModeOn) {
        [flashOnButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    }
    else {
        [flashAutoButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    }
}


#pragma mark - Private Methods

- (void) setUpInitialView {
    if (isImagePickerOnly) {
        imagePickerController = [[TUPhotoLibraryViewController alloc] init];
        imagePickerController.delegate = self;
        [imagePickerController setDefaultImage:_defaultImage];
        [[imagePickerController view] setFrame:[[self view] bounds]];
        [self addChildViewController:imagePickerController];
        [[self view] addSubview:[imagePickerController view]];
        [imagePickerController didMoveToParentViewController:self];
    }
    else {
        [rotationButton setEnabled:NO];
        [brightnessToggleButton setEnabled:NO];
        
        [self setUpCamera];
    }
}

- (void) setUpCamera {
    [self closeImagePickerIfOpen];
    [self setupUIForLiveCamera];
    [self removeAllTargets];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    if (stillCamera) {
        position = [stillCamera cameraPosition];
    }
    
    staticPicture = nil;
    isStatic = NO;
    stillCamera = nil;
    
    staticPictureOriginalOrientation = UIImageOrientationUp;
    
//    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:position];
    [stillCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    [stillCamera startCameraCapture];
    if ([[stillCamera inputCamera] isFocusPointOfInterestSupported] && [[stillCamera inputCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self showFocusViewAtPoint:[NSValue valueWithCGPoint:CGPointMake(imageView.frame.size.width/2, cropRect.origin.y + (cropRect.size.height/2))]];
    }
    [stillCamera addTarget:cropFilter];
    [cropFilter addTarget:filter];
    [filter addTarget:imageView];
    
    isCameraConfigured = YES;
}

- (void) loadPhotoLibrary {
    YMLAssetLibrary *assetLibrary = [YMLAssetLibrary assetLibrary];
    [assetLibrary addDelegate:self];
    if (![assetLibrary isLoaded]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[YMLAssetLibrary assetLibrary] loadPhotos];
        });
    }
    else if ([[assetLibrary allAssets] count] > 0) {
        ALAsset *asset = [[assetLibrary allAssets] objectAtIndex:0];
        UIImage *thumb = [UIImage imageWithCGImage:[asset thumbnail]];
        [libraryToggleButton setImage:thumb forState:UIControlStateNormal];
    }
}

- (void) loadFilters {
    CGFloat size = filterScrollView.innerHeight;
    CGFloat width = size;
    if (IS_IPHONE_5) {
        width = 86;
    }
    
    for (int i = 0; i < NUMBER_OF_FILTERS; i++) {
        UIImage *thumbImage = [UIImage imageNameInBundle:[NSString stringWithFormat:@"filter%d", i] withExtension:@"png"];
        if (IS_IPHONE_5) {
            thumbImage = [thumbImage scaleToSize:CGSizeMake(78, 78)];
        }
        else {
            thumbImage = [thumbImage scaleToSize:CGSizeMake(size - 8, size - 8)];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage stretchableImageWithName:@"bg_filter" extension:@"png" topCap:2 leftCap:1 bottomCap:1 andRightCap:2] forState:UIControlStateNormal];
        [button setImage:thumbImage forState:UIControlStateNormal];
        [button setFrame:CGRectMake((i * width), 0.0f, width, size)];
        [button setClipsToBounds:YES];
        [button addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:(i + FILTER_BUTTON_TAG)];
        
        if (IS_IPHONE_5) {
            [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
            [button setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
            [[button titleLabel] setNumberOfLines:3];
            [[button titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
            [button setTitle:[self filterNameAtIndex:i] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(-28, 0, 0, 0)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(thumbImage.size.height + 6, -(width - 6), 0, 0)];
        }
        
        if (i == 0) {
            [button setBackgroundImage:[UIImage stretchableImageWithName:@"bg_filter_hl" extension:@"png" topCap:2 leftCap:1 bottomCap:1 andRightCap:2] forState:UIControlStateNormal];
            if (IS_IPHONE_5) {
                [button setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
            }
        }
		[filterScrollView addSubview:button];
	}
	[filterScrollView setContentSize:CGSizeMake((NUMBER_OF_FILTERS * width), 0)];
}

- (void) filterClicked:(UIButton *) sender {
    for (UIView *view in filterScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if ([view tag] == [sender tag]) {
                [sender setBackgroundImage:[UIImage stretchableImageWithName:@"bg_filter_hl" extension:@"png" topCap:2 leftCap:1 bottomCap:1 andRightCap:2] forState:UIControlStateNormal];
                [sender setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
            }
            else {
                [(UIButton *)view setBackgroundImage:[UIImage stretchableImageWithName:@"bg_filter" extension:@"png" topCap:2 leftCap:1 bottomCap:1 andRightCap:2] forState:UIControlStateNormal];
                [(UIButton *)view setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            }
        }
    }
    
    [self removeAllTargets];
    
    
    int previousFilter = selectedFilter;
    selectedFilter = [sender tag] - FILTER_BUTTON_TAG;
    
    if (selectedFilter >= 1 && selectedFilter < (NUMBER_OF_FILTERS - 1)) {
        CGRect visibleRect = CGRectMake(filterScrollView.contentOffset.x, 0, filterScrollView.width, filterScrollView.height);
        
        UIView *viewToVisible = nil;
        // Moving Forward
        if (selectedFilter > previousFilter) {
            viewToVisible = [filterScrollView viewWithTag:selectedFilter + FILTER_BUTTON_TAG + 1];
            
            if (!CGRectContainsPoint(visibleRect, CGPointMake(viewToVisible.right - 1, 5))) {
                CGFloat toMove = (viewToVisible.right - filterScrollView.contentOffset.x) - filterScrollView.width;
                CGPoint offset = filterScrollView.contentOffset;
                offset.x = filterScrollView.contentOffset.x + toMove;
                
                [filterScrollView setContentOffset:offset animated:YES];
            }
        }
        // Moving Backward
        else if (selectedFilter < previousFilter) {
            viewToVisible = [filterScrollView viewWithTag:selectedFilter + FILTER_BUTTON_TAG - 1];
            
            if (!CGRectContainsPoint(visibleRect, CGPointMake(viewToVisible.left - 1, 5))) {
                CGFloat toMove = viewToVisible.left - filterScrollView.contentOffset.x;
                CGPoint offset = filterScrollView.contentOffset;
                offset.x = filterScrollView.contentOffset.x + toMove;
                
                [filterScrollView setContentOffset:offset animated:YES];
            }
        }
    }
    
    [self setFilter:selectedFilter];
    
    if (isStatic) {
        [self prepareStaticFilter];
    }
    else {
        [self prepareLiveFilter];
    }
}

- (void) setFilter:(int)index {
    switch (index) {
        case 7:{
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"BreakYourHeart"];
        } break;
            
        case 8:{
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"ComeOnGirl"];
        } break;
            
        case 11:{
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"TroubleMaker"];
        } break;
            
        case 15:{
            filter = [[GPUImageFilterGroup alloc] init];
            
            GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
            [(GPUImageFilterGroup *)filter addFilter:sepiaFilter];
            
            GPUImageVignetteFilter *VignetteFilter = [[GPUImageVignetteFilter alloc] init];
            [(GPUImageFilterGroup *)filter addFilter:VignetteFilter];
            
            [sepiaFilter addTarget:VignetteFilter];
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:sepiaFilter]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:VignetteFilter];
        } break;
            
        case 16: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"pro"];
        } break;
            
        case 4: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"newhollywood"];
        } break;
            
        case 6: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Nashville"];
        } break;
           
        case 9: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"LordKelvin"];
        } break;
            
        case 13: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Hefe"];
        } break;
            
        case 3: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Gotham"];
        } break;
            
        case 5: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Brannan"];
        } break;
             
        case 10: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"alienburn"];
        } break;
             
        case 12: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"1977"];
        } break;
            
        case 14: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"dramaticsee"];
        } break;
            
        case 18: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"02"];
        } break;
            
        case 20: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"06"];
        } break;
            
        case 21: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"exoticmountain"];
        } break;
            
        case 2: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"desert"];
        } break;
            
        case 1: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Summertime"];
        } break;
            
        case 17: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"fogy_blue"];
        } break;
            
        case 19: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess"];
        } break;
            
        case 22: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"thedreamworld"];
        } break;
            
        case 23: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"vintagememories"];
        } break;
            
        case 24: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"californiagoldrush"];
        } break;
            
        default:
            filter = [[GPUImageFilter alloc] init];
            break;
    }
}

- (NSString *) filterNameAtIndex:(int)index {
    NSString *filterName = @"Original";
    
    switch (index) {
        case 1:{
            filterName = @"Rowling";
        } break;
            
        case 2:{
            filterName = @"Orewell";
        } break;
            
        case 3:{
            filterName = @"Hemingway";
        } break;
            
        case 4:{
            filterName = @"Dickens";
        } break;
            
        case 5: {
            filterName = @"Cruz";
        } break;
            
        case 6: {
            filterName = @"Poe";
        } break;
            
        case 7: {
            filterName = @"Twain";
        } break;
            
        case 8: {
            filterName = @"Suntsu";
        } break;
            
        case 9: {
            filterName = @"Fitzgerald";
        } break;
            
        case 10: {
            filterName = @"Wilde";
        } break;
            
        case 11: {
            filterName = @"Murakami";
        } break;
            
        case 12: {
            filterName = @"Austen";
        } break;
            
        case 13: {
            filterName = @"Tolkien";
        } break;
            
        case 14: {
            filterName = @"King";
        } break;
            
        case 15: {
            filterName = @"Kafka";
        } break;
            
        case 16: {
            filterName = @"Joyce";
        } break;
            
        case 17: {
            filterName = @"Christie";
        } break;
            
        case 18: {
            filterName = @"Shakespeare";
        } break;
            
        case 19: {
            filterName = @"Seuss";
        } break;
            
        case 20: {
            filterName = @"Cartland";
        } break;
            
        case 21: {
            filterName = @"Faulkner";
        } break;
            
        case 22: {
            filterName = @"Stein";
        } break;
            
        case 23: {
            filterName = @"Woolf";
        } break;
            
        case 24: {
            filterName = @"Shelley";
        } break;
            
        default:
            filterName = @"Original";
            break;
    }
    
    return filterName;
}

- (void) prepareLiveFilter {
    if ([flashView alpha] == 1.0) {
        [self toggleFlash:flashToggleButton];
    }
    
    [cropFilter addTarget:filter];
    
    if (hasBlur) {
        [filter addTarget:blurFilter];
        [blurFilter addTarget:imageView];
    }
    else {
        [filter addTarget:imageView];
    }
    
    [stillCamera addTarget:cropFilter];
    [filter prepareForImageCapture];
}

- (void) prepareStaticFilter {
    if ([flashView alpha] == 1.0) {
        [self toggleFlash:flashToggleButton];
    }
    
    if (hasBlur) {
        if (brightnessFilter) {
            [filter addTarget:blurFilter];
            [blurFilter addTarget:brightnessFilter];
            [brightnessFilter addTarget:imageView];
        }
        else {
            [filter addTarget:blurFilter];
            [blurFilter addTarget:imageView];
        }
    }
    else {
        if (brightnessFilter) {
            [filter addTarget:brightnessFilter];
            [brightnessFilter addTarget:imageView];
        }
        else {
            [filter addTarget:imageView];
        }
    }
    
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    [imageView setInputRotation:imageViewRotationMode atIndex:0];
    
    [staticPicture addTarget:filter];
    [staticPicture processImage];
}

- (void) removeAllTargets {
    [brightnessFilter removeAllTargets];
    [cropFilter removeAllTargets];
    [stillCamera removeAllTargets];
    [staticPicture removeAllTargets];
    [filter removeAllTargets];
    [blurFilter removeAllTargets];
}

- (void) showBlurOverlay:(BOOL)show {
    typeof(self) __weak weakSelf = self;
    if (show) {
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            YMLImagePickerController *strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf->blurOverlayView.alpha = 0.6;
            }
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            YMLImagePickerController *strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf->blurOverlayView.alpha = 0;
            }
        } completion:nil];
    }
}

- (void) flashBlurOverlay {
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:0
                     animations:^{
                         YMLImagePickerController *strongSelf = weakSelf;
                         if (strongSelf) {
                             strongSelf->blurOverlayView.alpha = 0.6;
                         }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
                             YMLImagePickerController *strongSelf = weakSelf;
                             if (strongSelf) {
                                 strongSelf->blurOverlayView.alpha = 0;
                             }
                         } completion:nil];
                     }];
}

- (void) hideFocusView {
    __weak UIView *weakFocusView = focusView;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         UIView *strongFocusView = weakFocusView;
                         if (strongFocusView) {
                             [strongFocusView setAlpha:0.0];
                         }
                     }
                     completion:nil];
}

- (void) showFilters {
    [effectButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn_hl" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [effectButton setTitleColor:[UIColor colorWith255Red:1 green:198 blue:255 alpha:1.0] forState:UIControlStateNormal];
    
    [filterScrollView setHidden:NO];
    [effectButton setSelected:YES];
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         YMLImagePickerController *strongSelf = weakSelf;
                         
                         if (strongSelf) {
                             [strongSelf->rotationButton setAlpha:1.0];
                             [strongSelf->blurToggleButton setAlpha:1.0];
                             [strongSelf->brightnessToggleButton setAlpha:1.0];
                             [strongSelf->galleryButton setAlpha:0.0];
                             
                             CGRect bottomBarFrame = strongSelf->bottomBar.frame;
                             bottomBarFrame.origin.y = strongSelf.view.innerHeight - bottomBarFrame.size.height;
                             strongSelf->bottomBar.frame = bottomBarFrame;
                             strongSelf->filterScrollView.alpha = 1.0;
                         }
                     }
                     completion:nil];
}

- (void) hideFilters {
    [effectButton setBackgroundImage:[UIImage stretchableImageWithName:@"camera_bg_btn" extension:@"png" topCap:0 leftCap:4 bottomCap:0 andRightCap:3] forState:UIControlStateNormal];
    [effectButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    
    [effectButton setSelected:NO];
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         YMLImagePickerController *strongSelf = weakSelf;
                         
                         if (strongSelf) {
                             [strongSelf->rotationButton setAlpha:0.0];
                             [strongSelf->blurToggleButton setAlpha:0.0];
                             [strongSelf->brightnessToggleButton setAlpha:0.0];
                             [strongSelf->galleryButton setAlpha:1.0];
                             
                             CGRect bottomBarFrame = strongSelf->bottomBar.frame;
                             bottomBarFrame.origin.y = strongSelf.view.innerHeight - 44;
                             strongSelf->bottomBar.frame = bottomBarFrame;
                             strongSelf->filterScrollView.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                         YMLImagePickerController *strongSelf = weakSelf;
                         
                         if (strongSelf) {
                             strongSelf->filterScrollView.hidden = YES;
                         }
                     }];
}

- (void) enableCameraControls {
    [photoBar setUserInteractionEnabled:YES];
    [photoCaptureButton setEnabled:YES];
    [libraryToggleButton setEnabled:YES];
    [blurToggleButton setEnabled:YES];
    [filtersToggleButton setEnabled:YES];
    
    if (!isStatic && toggleCameraButton && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [toggleCameraButton setEnabled:YES];
    }
}

- (void) disableCameraControls {
    [photoBar setUserInteractionEnabled:NO];
    [photoCaptureButton setEnabled:NO];
    [libraryToggleButton setEnabled:NO];
    [blurToggleButton setEnabled:NO];
    [filtersToggleButton setEnabled:NO];
    [rotationButton setEnabled:NO];
    [brightnessToggleButton setEnabled:NO];
    
    if (toggleCameraButton) {
        [toggleCameraButton setEnabled:NO];
    }
}

- (void) showFocusViewAtPoint:(NSValue *)focusPoint {
    CGPoint point = [focusPoint CGPointValue];
    __weak YMLImagePickerController *weakSelf = self;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:(UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         YMLImagePickerController *strongSelf = weakSelf;
                         
                         if (strongSelf) {
                             CGRect rect;
                             rect.origin.x = point.x - (strongSelf->focusViewSize.width/4);
                             rect.origin.y = point.y - (strongSelf->focusViewSize.height/4);
                             rect.size.width = strongSelf->focusViewSize.width/2;
                             rect.size.height = strongSelf->focusViewSize.height/2;
                             
                             [strongSelf->focusView setAlpha:1.0];
                             [strongSelf->focusView setFrame:rect];
                         }
                     }
                     completion:^(BOOL finished) {
                         [weakSelf performSelector:@selector(hideFocusView) withObject:nil afterDelay:0.5];
                     }];
}

- (UIImage *) increaseQuality:(UIImage *)inputImage {
    return inputImage;
    
    if (!inputImage) {
        return nil;
    }
    
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [sharpenFilter setSharpness:0.0];
    
    GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
    [levelsFilter setMin:(15.0/255.0) gamma:0.8 max:1.0 minOut:0 maxOut:1.0];
    
    [levelsFilter addTarget:sharpenFilter];
    return [sharpenFilter imageByFilteringImage:inputImage];
    
    
//    GPUImageLevelsFilter *levelsFilter = [[GPUImageLevelsFilter alloc] init];
//    [levelsFilter setMin:(15.0/255.0) gamma:0.8 max:1.0 minOut:0 maxOut:1.0];
//    
//    return [levelsFilter imageByFilteringImage:inputImage];
}

- (void) processCapturedImage:(UIImage *)image {
    isStatic = YES;
    staticPicture = nil;
    
    YMLCropView *tempCropView = [[YMLCropView alloc] initWithFrame:[[self view] bounds] image:nil cropRect:cropRect];
    [tempCropView setImageWithFullScreenAspectFill:image];
    image = [tempCropView cropForFullScreen];
    
    staticPicture = [[GPUImagePicture alloc] initWithImage:image];
    staticPictureOriginalOrientation = image.imageOrientation;
    [self prepareStaticFilter];
    [self showFilters];
}


#pragma mark - Button Actions
#pragma mark Capture
- (void) takePhoto:(id)sender {
    if (isCameraProcessing) { return; }
    
    if (isStatic) {
        if (isCameraConfigured) {
            [self retakePhoto:nil];
        }
        else {
            [self setUpCamera];
        }
    }
    else {
        isCameraProcessing = YES;
        
        [self disableCameraControls];
        [flashToggleButton setEnabled:NO];
        
        if ([[stillCamera inputCamera] hasFlash]) {
            [[stillCamera inputCamera] lockForConfiguration:nil];
            [[stillCamera inputCamera] setFlashMode:flashMode];
            [[stillCamera inputCamera] setTorchMode:torchMode];
            [[stillCamera inputCamera] unlockForConfiguration];
        }
        [self performSelector:@selector(captureImage) withObject:nil afterDelay:0.2];
    }
}

- (void) captureImage {
    [self disableCameraControls];
    
    UIImage *image = [self increaseQuality:[cropFilter imageFromCurrentlyProcessedOutput]];
    [self removeAllTargets];
    [self setupUIForCaptureImage];
    [self processCapturedImage:image];
    if ([[stillCamera inputCamera] hasFlash]) {
        [[stillCamera inputCamera] lockForConfiguration:nil];
        [[stillCamera inputCamera] setFlashMode:AVCaptureFlashModeOff];
        [[stillCamera inputCamera] setTorchMode:AVCaptureTorchModeOff];
        [[stillCamera inputCamera] unlockForConfiguration];
    }
    [stillCamera stopCameraCapture];
    
    [self performSelector:@selector(enableCameraControls) withObject:nil afterDelay:1.0];
    isCameraProcessing = NO;
}

- (void) retakePhoto:(UIButton *)button {
    [self disableCameraControls];
    
//    [self closeImagePickerIfOpen];
//    [self removeAllTargets];
//    [self setupUIForLiveCamera];
//    
//    isStatic = NO;
//    staticPicture = nil;
//    staticPictureOriginalOrientation = UIImageOrientationUp;
//    [stillCamera startCameraCapture];
//    [self setFilter:selectedFilter];
//    [self prepareLiveFilter];
//    [self hideFilters];
    
    [self setUpCamera];
    [self setFilter:selectedFilter];
    [self hideFilters];
    
    [self enableCameraControls];
}

- (void) closeImagePickerIfOpen {
    if (imagePickerController) {
        if ([[imagePickerController view] superview]) {
            CATransition *transision = [[CATransition alloc] init];
            [transision setDuration:0.3];
            [transision setFillMode:kCAFillModeForwards];
            [transision setType:kCATransitionFade];
            [[[imagePickerController view] layer] addAnimation:transision forKey:nil];
            [imagePickerController willMoveToParentViewController:nil];
            [[imagePickerController view] removeFromSuperview];
            [imagePickerController removeFromParentViewController];
        }
        
        imagePickerController = nil;
    }
}

- (void) setupUIForLiveCamera {
    [overLay setOverlayColor:[UIColor colorWith255Red:9 green:9 blue:9 alpha:0.45]];
    [overLay setNeedsDisplay];
    imageView = captureImageView;
    [captureImageView setHidden:NO];
    [cropImageView setHidden:YES];
    
    [nextBarButton setEnabled:NO];
    [cameraToggleButton setEnabled:YES];
    
    if (!rotation == 0) {
        [cropImageView setTransform:CGAffineTransformMakeRotation(0)];
    }
    rotation = 0;
    
    if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
        [flashToggleButton setEnabled:YES];
    }
    else {
        [flashToggleButton setEnabled:NO];
    }
}

- (void) setupUIForCaptureImage {
    [overLay setOverlayColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_view_bg" withExtension:@"png"]]];
    [overLay setNeedsDisplay];
    imageView = cropImageView;
    [cropImageView setHidden:NO];
    [captureImageView setHidden:YES];
    
    [rotationButton setEnabled:YES];
    [brightnessToggleButton setEnabled:YES];
    [flashToggleButton setEnabled:NO];
    [nextBarButton setEnabled:YES];
    if (toggleCameraButton) {
        [toggleCameraButton setEnabled:NO];
    }
}

- (void) setupUIForStaticImage {
    if (!rotation == 0) {
        [cropImageView setTransform:CGAffineTransformMakeRotation(0)];
    }
    rotation = 0;
    
    [rotationButton setEnabled:YES];
    [brightnessToggleButton setEnabled:YES];
    
    [nextBarButton setEnabled:YES];
    [flashToggleButton setEnabled:NO];
    [cameraToggleButton setEnabled:NO];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [photoCaptureButton setEnabled:YES];
    }
    else {
        [photoCaptureButton setEnabled:NO];
    }
    
    [blurToggleButton setHidden:NO];
    [toggleCameraButton setEnabled:NO];
    
    
    [overLay setOverlayColor:[UIColor colorWithPatternImage:[UIImage imageNameInBundle:@"camera_view_bg" withExtension:@"png"]]];
    [overLay setNeedsDisplay];
    imageView = cropImageView;
    [cropImageView setHidden:NO];
    [captureImageView setHidden:YES];
}

#pragma mark Camera Control
- (void) switchCamera {
    if (isCameraProcessing) { return; }
    
    [cameraToggleButton setEnabled:NO];
    [stillCamera rotateCamera];
    [cameraToggleButton setEnabled:YES];
    
    if ([stillCamera.inputCamera hasFlash]) {
        [flashToggleButton setEnabled:YES];
    }
    else {
        [flashToggleButton setEnabled:NO];
    }
}


#pragma mark Effects
- (void) toggleFilters:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [self hideFilters];
    }
    else {
        [sender setSelected:YES];
        [self showFilters];
    }
}

- (void) grid:(UIButton *)sender {
    [gridView setHidden:![gridView isHidden]];
}

- (void) rotation:(UIButton *)sender {
    if (isStatic) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        rotation += M_PI_2;
        CGFloat t = (4 * M_PI_2);
        if (rotation == t) {
            rotation = 0;
        }
        
        CGAffineTransform transform = [imageView transform];
        transform = CGAffineTransformRotate(transform, M_PI_2);
        [cropImageView setTransform:transform];
        
        [UIView commitAnimations];
    }
}

- (void) toggleBrightness:(UIButton *)sender {
    if (isStatic) {
        if ([brightnessToggleButton isSelected]) {
            [brightnessToggleButton setImage:[UIImage imageNameInBundle:@"ico_brightness" withExtension:@"png"] forState:UIControlStateNormal];
            [brightnessToggleButton setSelected:NO];
            
            brightnessFilter = nil;
        }
        else {
            [brightnessToggleButton setImage:[UIImage imageNameInBundle:@"ico_brightness_hl" withExtension:@"png"] forState:UIControlStateNormal];
            [brightnessToggleButton setSelected:YES];
            
            if (!brightnessFilter) {
                brightnessFilter = [[GPUImageHighlightShadowFilter alloc] init];
                [brightnessFilter setShadows:0.6];
            }
        }
        
        [UIView beginAnimations:nil context:NULL];
        [self removeAllTargets];
        [self prepareStaticFilter];
        [UIView commitAnimations];
    }
}

- (void) toggleBlur:(UIButton*)blurButton {
    if (isCameraProcessing) { return; }
    
    isCameraProcessing = YES;
    
    [self removeAllTargets];
    
    if (hasBlur) {
        hasBlur = NO;
        blurFilter = nil;
        [self showBlurOverlay:NO];
        [blurToggleButton setImage:[UIImage imageNameInBundle:@"ico_blur" withExtension:@"png"] forState:UIControlStateNormal];
    }
    else {
        if (!blurFilter) {
            blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCircleRadius:80.0/320.0];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setBlurSize:kStaticBlurSize];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setAspectRatio:1.0f];
        }
        
        hasBlur = YES;
        [self flashBlurOverlay];
        [blurToggleButton setImage:[UIImage imageNameInBundle:@"ico_blur_hl" withExtension:@"png"] forState:UIControlStateNormal];
    }
    
    if (isStatic) {
        [self prepareStaticFilter];
    }
    else {
        [self prepareLiveFilter];
    }
    
    isCameraProcessing = NO;
}

#pragma mark Flash
- (void) toggleFlash:(UIButton *)button {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    if ([flashView alpha] == 0) {
        [flashView setFrame:CGRectMake(flashToggleButton.left, flashToggleButton.top, flashToggleButton.width, 132)];
        [flashView setAlpha:1.0];
        
        [flashOffButton setFrame:CGRectMake(0, 0, 34, 34)];
        [flashOffButton setAlpha:1.0];
        [flashOnButton setFrame:CGRectMake(0, flashOffButton.bottom + 15, 34, 34)];
        [flashOnButton setAlpha:1.0];
        [flashAutoButton setFrame:CGRectMake(0, flashOnButton.bottom + 15, 34, 34)];
        [flashAutoButton setAlpha:1.0];
    }
    else {
        [flashView setFrame:CGRectMake(flashToggleButton.left, flashToggleButton.top, flashToggleButton.width, 0)];
        [flashView setAlpha:0.0];
        
        [flashOffButton setFrame:CGRectMake(0, 0, 34, 34)];
        [flashOffButton setAlpha:0.0];
        [flashOnButton setFrame:CGRectMake(0, 0, 34, 34)];
        [flashOnButton setAlpha:0.0];
        [flashAutoButton setFrame:CGRectMake(0, 0, 34, 34)];
        [flashAutoButton setAlpha:0.0];
    }
    
    [UIView commitAnimations];
}

- (void) flashOff:(UIButton *)button {
    [flashOffButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOnButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashAutoButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    
    [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashoff" withExtension:@"png"] forState:UIControlStateNormal];
    flashMode = AVCaptureFlashModeOff;
    torchMode = AVCaptureTorchModeOff;
    
    [self toggleFlash:flashToggleButton];
}

- (void) flashOn:(UIButton *)button {
    [flashOffButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOnButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    [flashAutoButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    
    [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashon" withExtension:@"png"] forState:UIControlStateNormal];
    flashMode = AVCaptureFlashModeOn;
    torchMode = AVCaptureTorchModeOn;
    
    [self toggleFlash:flashToggleButton];
}

- (void) flashAuto:(UIButton *)button {
    [flashOffButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashOnButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn" withExtension:@"png"] forState:UIControlStateNormal];
    [flashAutoButton setBackgroundImage:[UIImage imageNameInBundle:@"camera_roundbtn_hl" withExtension:@"png"] forState:UIControlStateNormal];
    
    [flashToggleButton setImage:[UIImage imageNameInBundle:@"ico_flashauto" withExtension:@"png"] forState:UIControlStateNormal];
    flashMode = AVCaptureFlashModeAuto;
    torchMode = AVCaptureTorchModeAuto;
    
    [self toggleFlash:flashToggleButton];
}


#pragma mark Others
- (void) switchToLibrary:(id)sender {
    if (isCameraProcessing) { return; }
    
    if (!isStatic) {
        [stillCamera stopCameraCapture];
        [self removeAllTargets];
    }
    
    if (!imagePickerController) {
        imagePickerController = [[TUPhotoLibraryViewController alloc] init];
        imagePickerController.delegate = self;
    }
    
    CATransition *transision = [[CATransition alloc] init];
    [transision setDuration:0.3];
    [transision setFillMode:kCAFillModeForwards];
    [transision setType:kCATransitionFade];
    [[[imagePickerController view] layer] addAnimation:transision forKey:nil];
    [self presentViewController:imagePickerController animated:NO completion:NULL];
}

- (void) next {
    GPUImageOutput<GPUImageInput> *processUpTo;
    
    if (brightnessFilter) {
        processUpTo = brightnessFilter;
    }
    else if (hasBlur) {
        processUpTo = blurFilter;
    }
    else {
        processUpTo = filter;
    }
    
    [staticPicture processImage];
    
    BOOL isFilterAppled = (selectedFilter > 0);
    
    UIImage *currentFilteredVideoFrame = [[processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation] imageRotatedByRadians:rotation];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys: UIImageJPEGRepresentation(currentFilteredVideoFrame, outputJPEGQuality), @"data", [NSNumber numberWithBool:isFilterAppled], @"isFilterApplied", nil];
    [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
}

- (void) cancel:(id)sender {
    if (isStatic) {
        if (imagePickerController) {
            CATransition *transision = [[CATransition alloc] init];
            [transision setDuration:0.3];
            [transision setFillMode:kCAFillModeForwards];
            [transision setType:kCATransitionFade];
            [[[imagePickerController view] layer] addAnimation:transision forKey:nil];
            [self presentViewController:imagePickerController animated:NO completion:NULL];
            
            isStatic = NO;
            staticPicture = nil;
        }
        else {
            if (isCameraConfigured) {
                [self retakePhoto:nil];
            }
            else {
                [self setUpCamera];
            }
        }
    }
    else {
        [self.delegate imagePickerControllerDidCancel:self];
        [[YMLAssetLibrary assetLibrary] removeAllDelegates];
    }
}


#pragma mark - Public Methods

- (void) startCamera {
    if (!isStatic) {
        [stillCamera resumeCameraCapture];
    }
}

- (void) stopCamera {
    if (!isStatic) {
        [stillCamera pauseCameraCapture];
    }
}


#pragma mark - Gestures

- (void) handlePan:(UIGestureRecognizer *) sender {
    if (hasBlur) {
        CGPoint tapPoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter *gpu = (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
            [blurOverlayView setCircleCenter:CGPointMake(tapPoint.x + 40, tapPoint.y + 40)];
//            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/TU_IMAGE_SIZE.width, tapPoint.y/TU_IMAGE_SIZE.height)];
        }
        
        if([sender state] == UIGestureRecognizerStateEnded){
            [gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
    }
}

- (void) handleTapToFocus:(UITapGestureRecognizer *)tgr {
	if (!isStatic && tgr.state == UIGestureRecognizerStateRecognized) {
		CGPoint location = [tgr locationInView:imageView];
        if (!CGRectContainsPoint(cropRect, location)) {
            return;
        }
        
		AVCaptureDevice *device = stillCamera.inputCamera;
		CGPoint pointOfInterest = CGPointMake(.5f, .5f);
		CGSize frameSize = [imageView frame].size;
		
        if ([stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
		}
        
		pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
		if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setFocusPointOfInterest:pointOfInterest];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                [device unlockForConfiguration];
                
                
                CGRect rect = [focusView frame];
                rect.origin.x = location.x - (focusViewSize.width * 1.5)/2;
                rect.origin.y = location.y - (focusViewSize.height * 1.5)/2;
                rect.size.width = focusViewSize.width * 1.5;
                rect.size.height = focusViewSize.height * 1.5;
                [focusView setAlpha:0.0];
                [focusView setFrame:rect];
                
                [self performSelector:@selector(showFocusViewAtPoint:) withObject:[NSValue valueWithCGPoint:location] afterDelay:0.25];
			}
		}
	}
}

- (void) handlePinch:(UIPinchGestureRecognizer *) sender {
    if (hasBlur) {
        CGPoint midpoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu = (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
//            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/TU_IMAGE_SIZE.width, midpoint.y/TU_IMAGE_SIZE.height)];
            blurOverlayView.circleCenter = CGPointMake(midpoint.x + 40, midpoint.y + 40);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            blurOverlayView.radius = radius * TU_IMAGE_SIZE.width;
            [gpu setExcludeCircleRadius:radius];
            sender.scale = 1.0f;
        }
        
        if ([sender state] == UIGestureRecognizerStateEnded) {
            [gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
    }
}


#pragma mark - Notification

- (void) applicationDidEnterBackground:(NSNotification *)notification {
    [self stopCamera];
}

- (void) applicationDidBecomeActive:(NSNotification *)notification {
    [self startCamera];
}


#pragma mark - TUPhotoLibrary Delegate

- (void) photoLibrary:(TUPhotoLibraryViewController *)library didSelectImage:(UIImage *)image {
    if (isImagePickerOnly && !staticPicture) {        
        CATransition *transision = [[CATransition alloc] init];
        [transision setDuration:0.3];
        [transision setFillMode:kCAFillModeForwards];
        [transision setType:kCATransitionFade];
        [[[library view] layer] addAnimation:transision forKey:nil];
        [library willMoveToParentViewController:nil];
        [[library view] removeFromSuperview];
        [library removeFromParentViewController];
    }
    else {
        CATransition *transision = [[CATransition alloc] init];
        [transision setDuration:0.3];
        [transision setFillMode:kCAFillModeForwards];
        [transision setType:kCATransitionFade];
        [[[library view] layer] addAnimation:transision forKey:nil];
        [library dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self removeAllTargets];
    
    staticPicture = nil;
    isStatic = YES;
    staticPicture = [[GPUImagePicture alloc] initWithImage:[self increaseQuality:image]];
    staticPictureOriginalOrientation = image.imageOrientation;
    isImagePickerOnly = NO;
    
    [self setupUIForStaticImage];
    [self showFilters];
    
    [self prepareStaticFilter];
}

- (void) photoLibraryDidClose:(TUPhotoLibraryViewController *)library {
    if (!staticPicture) {
        [nextBarButton setEnabled:NO];
    }
    
    if (isImagePickerOnly) {
        [[self delegate] imagePickerControllerDidCancel:self];
        [[YMLAssetLibrary assetLibrary] removeAllDelegates];
    }
    else {
        [library dismissViewControllerAnimated:YES completion:nil];
        
        if (!staticPicture) {
            [self retakePhoto:nil];
        }
        else {
            [self closeImagePickerIfOpen];
        }
    }
}


#pragma mark - YMLAssetLibrary Delegate

- (void) assetLibraryDidFinishLoading {
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        YMLImagePickerController *strongSelf = weakSelf;
        if (strongSelf) {
            YMLAssetLibrary *assetLibrary = [YMLAssetLibrary assetLibrary];
            if ([[assetLibrary allAssets] count] > 0) {
                ALAsset *asset = [[assetLibrary allAssets] objectAtIndex:0];
                UIImage *thumb = [UIImage imageWithCGImage:[asset thumbnail]];
                [strongSelf->libraryToggleButton setImage:thumb forState:UIControlStateNormal];
            }
        }
    });
}

- (void) assetLibraryDidReceiveError:(NSError *)error {
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        YMLImagePickerController *strongSelf = weakSelf;
        
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


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#endif


#pragma mark - Dealloc

- (void) nullify {
    [self removeAllTargets];
    
    filter = nil;
    photoBar = nil;
    focusView = nil;
    imageView = nil;
    blurFilter = nil;
    cropFilter = nil;
    gridView = nil;
    backBarButton = nil;
    cancelButton = nil;
    navigationBar = nil;
    nextBarButton = nil;
    staticPicture = nil;
    _defaultImage = nil;
    flashOffButton = nil;
    flashOnButton = nil;
    flashAutoButton = nil;
    blurOverlayView = nil;
    filterScrollView = nil;
    blurToggleButton = nil;
    flashToggleButton = nil;
    cameraToggleButton = nil;
    photoCaptureButton = nil;
    toggleCameraButton = nil;
    filtersToggleButton = nil;
    libraryToggleButton = nil;
    captureImageView = nil;
    cropImageView = nil;
    
    if (imagePickerController) {
        if ([[imagePickerController view] superview]) {
            [imagePickerController willMoveToParentViewController:nil];
            [[imagePickerController view] removeFromSuperview];
            [imagePickerController removeFromParentViewController];
        }
        
        imagePickerController = nil;
    }
    
    [[YMLAssetLibrary assetLibrary] clearData];
    
    if (stillCamera && isCameraConfigured) {
        [stillCamera stopCameraCapture];
    }
    stillCamera = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void) dealloc {
    [self nullify];
}

@end
