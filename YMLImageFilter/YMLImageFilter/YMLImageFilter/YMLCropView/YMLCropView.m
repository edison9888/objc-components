//
//  YMLCropView.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "YMLCropView.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLCropView () <UIScrollViewDelegate> {
    BOOL needsOffsetAlignment;
    
    UILabel *titleLabel;
}

@end

@implementation YMLCropView

@synthesize overLay;
@synthesize cropRect;
@synthesize imageView, backgroundView, footerView;
@synthesize scrollView;
@synthesize delegate;

- (id) initWithFrame:(CGRect)frame image:(UIImage *)image cropRect:(CGRect)_cropRect {
    self = [super initWithFrame:frame];
    if (self) {
        cropRect = _cropRect;
//        [self setBackgroundColor:VIEW_BACKGROUND_COLOR];
        
        [self setClipsToBounds:YES];
        
        backgroundView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [self addSubview:backgroundView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:cropRect];
        [scrollView setDelegate:self];
        [scrollView setMaximumZoomScale:3.0];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setContentMode:UIViewContentModeCenter];
        [scrollView setClipsToBounds:NO];
        [self addSubview:scrollView];
        
        imageView = [[UIImageView alloc] initWithFrame:[scrollView bounds]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self setImage:image];
        [scrollView addSubview:imageView];
        
        [self UICreateCropOverlay];
        [self UICreateFooterView];
        
        _pinchBounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - footerView.frame.size.height);
    }
    return self;
}


#pragma mark - Public Methods

- (void) UICreateCropOverlay {
    overLay = [[YMLCropViewOverlay alloc] initWithFrame:[self bounds] cropRect:cropRect];
    [overLay setUserInteractionEnabled:NO];
    [self addSubview:overLay];
}

- (void) UICreateFooterView {
    footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 56, self.bounds.size.width, 56)];
    [footerView setUserInteractionEnabled:YES];
    [footerView setImage:[UIImage stretchableImageWithName:@"bg_bottombar" extension:@"png" topCap:0 leftCap:0 bottomCap:0 andRightCap:0]];
    [self addSubview:footerView];
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake((footerView.width - 104) * 0.5, 6, 52, 52)];
    [cancelButton setImage:[UIImage imageNameInBundle:@"ico_cancel" withExtension:@"png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:cancelButton];
    
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton setFrame:CGRectMake(cancelButton.right, 6, 52, 52)];
    [selectButton setImage:[UIImage imageNameInBundle:@"ico_tick" withExtension:@"png"] forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(crop) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:selectButton];
    
    
    int x = cancelButton.frame.size.width;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, footerView.bounds.size.width - (x + selectButton.frame.size.width) , footerView.bounds.size.height)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [titleLabel setTextColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]];
    [titleLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [footerView addSubview:titleLabel];
}

- (void) setTitle:(NSString *)title {
    [titleLabel setText:title];
}

- (void) setBackgroundImage:(UIImage *)backgroundImage {
    [backgroundView setImage:backgroundImage];
}

- (void) setImage:(UIImage *)image {
    [self setImage:image offsetAlignment:YES];
}

- (void) setImage:(UIImage *)image offsetAlignment:(BOOL)offsetAlignment {
    [scrollView setFrame:cropRect];
    [scrollView setZoomScale:1.0];
    [imageView setFrame:[scrollView bounds]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    
    if (image) {
        CGPoint offset = CGPointZero;
        
        // Portrait Mode
        if (image.size.width < image.size.height) {
            [imageView setFrame:[self bounds]];
            
            CGSize size = [imageView imageScaleSizeForContentMode:UIViewContentModeScaleAspectFill image:image];
            size = CGSizeMake(image.size.width * size.width, image.size.height * size.height);
            [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
            [scrollView setContentSize:size];
            
            if (offsetAlignment) {
                // image width cannot be greater than the screen size since the image view is aspect fit
                offset.x = (size.width - cropRect.size.width)/2;
                
                if (size.height == self.bounds.size.height) {
                    offset.y = cropRect.origin.y;
                }
                else {
                    offset.y = self.bounds.size.height - size.height;
                }
            }
        }
        // Landscape Mode
        else {
            CGSize size = [imageView imageScaleSizeForContentMode:UIViewContentModeScaleAspectFill image:image];
            size = CGSizeMake(image.size.width * size.width, image.size.height * size.height);
            
            image = [image scaleToSize:size];
            
            [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
            [scrollView setContentSize:size];
        }
        
        [scrollView setContentOffset:offset];
    }
    
    [imageView setImage:image];
}

- (void) setImageWithAspectFit:(UIImage *)image {
    [scrollView setFrame:cropRect];
    [scrollView setZoomScale:1.0];
    [imageView setFrame:[scrollView bounds]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    
    if (image) {
//        CGPoint offset = CGPointZero;
//        [imageView setFrame:[self bounds]];
        
//        CGSize size = [imageView imageScaleSizeForContentMode:UIViewContentModeScaleAspectFit image:image];
//        size = CGSizeMake(image.size.width * size.width, image.size.height * size.height);
//        [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
//        [scrollView setContentSize:size];
//        
//        // image width cannot be greater than the screen size since the image view is aspect fit
//        offset.x = (size.width - cropRect.size.width)/2;
//        
//        if (size.height == self.bounds.size.height) {
//            offset.y = cropRect.origin.y;
//        }
//        else {
//            offset.y = self.bounds.size.height - size.height;
//        }
//        
//        [scrollView setContentOffset:offset];
    }
    
    [imageView setImage:image];
}

- (void) setImageWithAspectFill:(UIImage *)image {
    [self setImageWithAspectFill:image resizeImage:YES];
}

- (void) setImageWithAspectFill:(UIImage *)image resizeImage:(BOOL)resizeImage {
    [scrollView setFrame:cropRect];
    [scrollView setZoomScale:1.0];
    [imageView setFrame:[scrollView bounds]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (image) {
        CGSize size = [imageView imageScaleSizeForContentMode:UIViewContentModeScaleAspectFill image:image];
        size = CGSizeMake(image.size.width * size.width, image.size.height * size.height);
        [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
        [scrollView setContentSize:size];
        
        if (resizeImage) {
            image = [image scaleToSize:size];
        }
    }
    
    [imageView setImage:image];
}

- (void) setImageWithFullScreenAspectFill:(UIImage *)image {
    [scrollView setFrame:[self bounds]];
    [scrollView setZoomScale:1.0];
    [imageView setFrame:[scrollView bounds]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    CGPoint offset;
    if (image) {
        CGSize size = [imageView imageScaleSizeForContentMode:UIViewContentModeScaleAspectFill image:image];
        size = CGSizeMake(image.size.width * size.width, image.size.height * size.height);
        [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
        [scrollView setContentSize:size];
        
        image = [image scaleToSize:size];
        
        offset = CGPointMake((size.width - scrollView.bounds.size.width)/2, (size.height - scrollView.bounds.size.height)/2);
    }
    
    [imageView setImage:image];
    [scrollView setContentOffset:offset];
}

- (void) cancel {
    if ([delegate respondsToSelector:@selector(cropViewCancelled:)]) {
        [delegate cropViewCancelled:self];
    }
}

- (UIImage *) cropForFullScreen {
    UIGraphicsBeginImageContextWithOptions(cropRect.size, self.scrollView.opaque, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -(cropRect.origin.x + self.scrollView.contentOffset.x), -(cropRect.origin.y + self.scrollView.contentOffset.y));
    
    [[scrollView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([delegate respondsToSelector:@selector(cropView:croppedImage:originalImage:)]) {
        [delegate cropView:self croppedImage:returnImage originalImage:[imageView image]];
    }
    
    return returnImage;
}

- (UIImage *) crop {
    UIGraphicsBeginImageContextWithOptions(self.scrollView.frame.size, self.scrollView.opaque, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y);
    
    [[scrollView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([delegate respondsToSelector:@selector(cropView:croppedImage:originalImage:)]) {
        [delegate cropView:self croppedImage:returnImage originalImage:[imageView image]];
    }
    
    return returnImage;
}


#pragma mark - Scrollview Delegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}


#pragma mark - Hit Test

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(_pinchBounds, point)) {
        return scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}


#pragma mark - Dealloc

- (void)dealloc {
    scrollView = nil;
    imageView = nil;
    footerView = nil;
    titleLabel = nil;
    overLay = nil;
    backgroundView = nil;
}

@end
