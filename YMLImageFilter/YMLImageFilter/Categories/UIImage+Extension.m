//
//  UIImage+Extension.m
//  Tourean
//
//  Created by Karthik Keyan B on 11/22/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "UIImage+Extension.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (Extension)

#pragma mark - Class Methods

+ (UIImage *) imageNameInBundle:(NSString *)name withExtension:(NSString *)extension {
    @autoreleasepool {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        return image;
    }
}

+ (UIImage *) stretchableImageWithName:(NSString *)name extension:(NSString *)extension topCap:(int)topcap leftCap:(int)leftCap bottomCap:(int)bottomCap andRightCap:(int)rightCap {
    @autoreleasepool {
        UIImage *image = [self imageNameInBundle:name withExtension:extension];
        
        if (OS_VERSION >= 5.0) {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(topcap, leftCap, bottomCap, rightCap)];
        }
        else {
            image = [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topcap];
        }
        return image;
    }
}

+ (UIImage *) stretchableImage:(UIImage *)image topCap:(int)topcap leftCap:(int)leftCap bottomCap:(int)bottomCap andRightCap:(int)rightCap {
    @autoreleasepool {
        if (OS_VERSION >= 5.0) {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(topcap, leftCap, bottomCap, rightCap)];
        }
        else {
            image = [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topcap];
        }
        return image;
    }
}

+ (UIImage *) rotateImage:(UIImage *)image to:(UIImageOrientation)to {
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:to];
}


#pragma mark - Instance Methods

- (UIImage *) scaleToSize:(CGSize)size {
    return [self scaleToSize:size scale:0.0];
}

- (UIImage *) scaleToSize:(CGSize)size scale:(CGFloat)scale {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *) fixOrientation {    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *) crop:(CGRect)cropRect {
    if (self.scale > 1.0f) {
        cropRect = CGRectMake(cropRect.origin.x * self.scale,
                              cropRect.origin.y * self.scale,
                              cropRect.size.width * self.scale,
                              cropRect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *retImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return retImage;
}

- (UIImage *) imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *) imageRotatedByDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
