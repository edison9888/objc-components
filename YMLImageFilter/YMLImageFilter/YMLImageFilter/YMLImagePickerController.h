
//  YMLImageFilter
//
//  Created by vivek Rajanna on 23/01/13.
//  Copyright (c) 2013 ymedialabs. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol YMLImagePickerDelegate;

@interface YMLImagePickerController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL isImagePickerOnly;
}

@property (nonatomic, readwrite) BOOL isImagePickerOnly;
@property (nonatomic, readwrite) CGSize cropSize;
@property (nonatomic, weak) id <YMLImagePickerDelegate> delegate;
@property (nonatomic, strong) UIImage *defaultImage;

- (void) startCamera;
- (void) stopCamera;

@end


@protocol YMLImagePickerDelegate <NSObject>

@optional
- (void)imagePickerController:(YMLImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(YMLImagePickerController *)picker;

@end
