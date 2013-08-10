//
//  YMLCropView.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLCropViewOverlay.h"

@protocol YMLCropViewDelegate;

@interface YMLCropView : UIView {
    CGRect cropRect;
    YMLCropViewOverlay *overLay;
    UIImageView *imageView, *backgroundView, *footerView;
    UIScrollView *scrollView;
    
    __weak id<YMLCropViewDelegate> delegate;
}

@property (nonatomic, readonly) YMLCropViewOverlay *overLay;
@property (nonatomic, readwrite) CGRect cropRect;
@property (nonatomic, readwrite) CGRect pinchBounds;
@property (nonatomic, readonly) UIImageView *imageView, *backgroundView, *footerView;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id<YMLCropViewDelegate> delegate;

- (id) initWithFrame:(CGRect)frame image:(UIImage *)image cropRect:(CGRect)cropRect;
- (void) UICreateCropOverlay;
- (void) UICreateFooterView;
- (void) setTitle:(NSString *)title;
- (void) setBackgroundImage:(UIImage *)backgroundImage;
- (void) setImage:(UIImage *)image;
- (void) setImage:(UIImage *)image offsetAlignment:(BOOL)offsetAlignment;
- (void) setImageWithAspectFit:(UIImage *)image;
- (void) setImageWithAspectFill:(UIImage *)image;
- (void) setImageWithAspectFill:(UIImage *)image resizeImage:(BOOL)resizeImage;
- (void) setImageWithFullScreenAspectFill:(UIImage *)image;
- (void) cancel;
- (UIImage *) cropForFullScreen;
- (UIImage *) crop;

@end

@protocol YMLCropViewDelegate <NSObject>

@optional
- (void) cropViewCancelled:(YMLCropView *)cropView;
- (void) cropView:(YMLCropView *)cropView croppedImage:(UIImage *)croppedImage originalImage:(UIImage *)originalImage;

@end
