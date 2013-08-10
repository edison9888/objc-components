//
//  TUCameraViewController.m
//  TUCamera
//
//  Created by Karthik Keyan B on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YMLCameraViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLCameraViewController () {
    BOOL isMoved;
    
    CGSize focusViewSize;
    UIImageView *imageView;
    
    AVCaptureDevicePosition currentPosition;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *output;
}

- (void) showFocusViewInPoint:(CGPoint)point;
- (void) hideFocusView;
- (CGPoint) pointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;

- (AVCaptureDevice *) cameraDeviceForPosition:(AVCaptureDevicePosition)position;
- (void) changeCameraToPosition:(AVCaptureDevicePosition)position;

@end

@implementation YMLCameraViewController

@synthesize cameraOverLay, focusView;
@synthesize delegate;

- (void) loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self setView:rootView];
    rootView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Preview
    AVCaptureVideoPreviewLayer *capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[capturePreviewLayer setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height)];
    [capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[[[self view] layer] addSublayer:capturePreviewLayer];
    capturePreviewLayer = nil;
    
    // Device
    currentPosition = AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self cameraDeviceForPosition:AVCaptureDevicePositionBack];
    
    // Input 
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [session addInput:input];
    
    // Output
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    output = [[AVCaptureStillImageOutput alloc] init];
    [output setOutputSettings:outputSettings];
    [session addOutput:output];
    
    [[self view] addSubview:cameraOverLay];
    
    if (focusView && [[input device] isFocusPointOfInterestSupported]) {
        [[self view] addSubview:focusView];
        focusViewSize = focusView.frame.size;
        [focusView setAlpha:0.0];
    }
    else {
        [self setFocusView:nil];
    }

    [session startRunning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Touch Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *view = [[touches anyObject] view];
    CGPoint point = [[touches anyObject] locationInView:view];
    
    if (focusView && ![view isKindOfClass:[UIButton class]]) {
        isMoved = NO;
        
        CGRect rect;
        rect.origin.x = point.x - (focusViewSize.width/2);
        rect.origin.y = point.y - (focusViewSize.height/2);
        rect.size = focusViewSize;
        
        [focusView setFrame:rect];
        [focusView setAlpha:0.0];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    isMoved = YES;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    isMoved = NO;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *view = [[touches anyObject] view];
    CGPoint point = [[touches anyObject] locationInView:[self view]];
    
    if (!isMoved && focusView && ![view isKindOfClass:[UIButton class]]) {
        [self showFocusViewInPoint:point];
    }
    
    isMoved = NO;
}


#pragma mark - Private Methods

- (AVCaptureDevice *) cameraDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}

- (void) changeCameraToPosition:(AVCaptureDevicePosition)position {
    if (currentPosition != position) {
        for (AVCaptureDeviceInput *input in [session inputs]) {
            if ([[input device] hasMediaType:AVMediaTypeVideo]) {
                AVCaptureDevice *device = [self cameraDeviceForPosition:position];
                if (device) {
                    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                    [session beginConfiguration];
                    [session removeInput:input];
                    [session addInput:newInput];
                    [session commitConfiguration];
                    
                    currentPosition = position;
                }
            }
        }
    }
}

- (void) showFocusViewInPoint:(CGPoint)point {
    CGPoint focusPoint = [self pointOfInterestFromViewCoordinates:point];
    
    for (AVCaptureDeviceInput *input in [session inputs]) {
        AVCaptureDevice *device = [input device];
        
        if ([device hasMediaType:AVMediaTypeVideo] && [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device lockForConfiguration:nil];
            [device setFocusPointOfInterest:focusPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:focusPoint];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [device unlockForConfiguration];
            
            [UIView animateWithDuration:0.3 
                                  delay:0.0 
                                options:(UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) 
                             animations:^{ 
                                 CGRect rect; 
                                 rect.origin.x = point.x - (focusViewSize.width/4);
                                 rect.origin.y = point.y - (focusViewSize.width/4);
                                 rect.size.width = focusViewSize.width/2;
                                 rect.size.height = focusViewSize.height/2;
                                 
                                 [focusView setAlpha:1.0];
                                 [focusView setFrame:rect];
                             } 
                             completion:^(BOOL finished) {
                                 [self performSelector:@selector(hideFocusView) withObject:nil afterDelay:0.5];
                             }];
            
            break;
        }
    }
}

- (void) hideFocusView {    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:(UIViewAnimationCurveEaseOut) 
                     animations:^{
                         [focusView setAlpha:0.0];
                     } 
                     completion:nil];
}

- (CGPoint) pointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    return CGPointMake(viewCoordinates.y / self.view.frame.size.height, 1.f - (viewCoordinates.x / self.view.frame.size.width));
}


#pragma mark - Public Methods

- (BOOL) isFrontCamera {
    return (currentPosition == AVCaptureDevicePositionFront);
}

- (void) capture {
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in output.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
        
		if (videoConnection) {            
            break;
        }
	}
    
    if (!videoConnection) {
        return;
    }
    
	[output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {        
        [session stopRunning];

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];

        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if ([delegate respondsToSelector:@selector(cameraViewController:didCaptureImage:)]) {
            [delegate cameraViewController:self didCaptureImage:image];
        }
	 }];
}

- (void) toggleCameraPosition {
    if ([self isFrontCamera]) {
        [self rearCamera];
    }
    else {
        [self frontCamera];
    }
}

- (void) frontCamera {
    [self changeCameraToPosition:AVCaptureDevicePositionFront];
}

- (void) rearCamera {
    [self changeCameraToPosition:AVCaptureDevicePositionBack];
}

- (void) flashLightMode:(YMLCameraViewControllerTourchMode)mode {
    for (AVCaptureDeviceInput *input in [session inputs]) {
        if ([[input device] hasMediaType:AVMediaTypeVideo]) {
            AVCaptureDevice *device = [input device];
            
            if ([device position] == AVCaptureDevicePositionBack) {
                AVCaptureTorchMode torchMode = AVCaptureTorchModeAuto;
                if (mode == YMLCameraViewControllerTourchModeOff) {
                    torchMode = AVCaptureTorchModeOff;
                }
                else if (mode == YMLCameraViewControllerTourchModeOn) {
                    torchMode = AVCaptureTorchModeOn;
                }
                
                if ([device isTorchModeSupported:torchMode]) {
                    [device lockForConfiguration:nil];
                    [device setTorchMode:mode];
                    [device unlockForConfiguration];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera" 
                                                                message:@"Flash light is not supported in front camera." 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles:nil];
                [alert show];
                alert = nil;
            }
            
            break;
        }
    }
}

- (void) flashOff {
    [self flashLightMode:YMLCameraViewControllerTourchModeOff];
}

- (void) flashOn {
    [self flashLightMode:YMLCameraViewControllerTourchModeOn];
}

- (void) flashAuto {
    [self flashLightMode:YMLCameraViewControllerTourchModeAuto];
}

- (void) close {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissModalViewControllerAnimated:YES];
        
        if ([delegate respondsToSelector:@selector(cameraViewControllerDidClose)]) {
            [delegate cameraViewControllerDidClose];
        }
    });
}


#pragma mark - Dealloc

- (void)dealloc {
    // Public Variables
    cameraOverLay = nil;
    focusView = nil;
    delegate = nil;
    
    // Private Variables
    imageView = nil;
    session = nil;
    output = nil;
    
}

@end
