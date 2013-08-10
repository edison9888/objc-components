//
//  TUPhotoLibraryViewController.h
//  Tourean
//
//  Created by கார்த்திக் கேயன் on 2/8/13.
//  Copyright (c) 2013 vivekrajanna@gmail.com. All rights reserved.
//

#import "TUNavigationViewController.h"

@protocol TUPhotoLibraryViewControllerDelegate;

@interface TUPhotoLibraryViewController : TUNavigationViewController

@property (nonatomic, readwrite) CGSize cropSize;
@property (nonatomic, weak) id<TUPhotoLibraryViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *defaultImage;

@end



@protocol TUPhotoLibraryViewControllerDelegate <NSObject>

@optional
- (void) photoLibrary:(TUPhotoLibraryViewController *)library didSelectImage:(UIImage *)image;
- (void) photoLibraryDidClose:(TUPhotoLibraryViewController *)library;

@end
