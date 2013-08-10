//
//  TUCameraViewController.h
//  TUCamera
//
//  Created by Karthik Keyan B on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum YMLCameraViewControllerTourchMode {
    YMLCameraViewControllerTourchModeOff = 0,
    YMLCameraViewControllerTourchModeOn,
    YMLCameraViewControllerTourchModeAuto
}YMLCameraViewControllerTourchMode;

@protocol YMLCameraViewControllerDelegate;

@interface YMLCameraViewController : UIViewController {
    UIView *cameraOverLay, *focusView;
    
    id<YMLCameraViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic) UIView *cameraOverLay, *focusView;
@property (nonatomic, unsafe_unretained) id<YMLCameraViewControllerDelegate> delegate;

- (BOOL) isFrontCamera;
- (void) capture;
- (void) toggleCameraPosition;
- (void) frontCamera;
- (void) rearCamera;
- (void) flashLightMode:(YMLCameraViewControllerTourchMode)mode;
- (void) flashOff;
- (void) flashOn;
- (void) flashAuto;
- (void) close;

@end


@protocol YMLCameraViewControllerDelegate <NSObject>

@optional
- (void) cameraViewController:(YMLCameraViewController *)controller didCaptureImage:(UIImage *)image;
- (void) cameraViewControllerDidClose;

@end
