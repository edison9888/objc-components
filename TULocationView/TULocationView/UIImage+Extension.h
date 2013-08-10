//
//  UIImage+Extension.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/22/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIImage *) scaleToSize:(CGSize)size;
- (UIImage *) scaleToSize:(CGSize)size scale:(CGFloat)scale;
- (UIImage *) fixOrientation;
- (UIImage *) crop:(CGRect)cropRect;

+ (UIImage *) imageNameInBundle:(NSString *)name withExtension:(NSString *)extension;
+ (UIImage *) stretchableImageWithName:(NSString *)name extension:(NSString *)extension topCap:(int)topcap leftCap:(int)leftCap bottomCap:(int)bottomCap andRightCap:(int)rightCap;
+ (UIImage *) stretchableImage:(UIImage *)image topCap:(int)topcap leftCap:(int)leftCap bottomCap:(int)bottomCap andRightCap:(int)rightCap;
+ (UIImage *) rotateImage:(UIImage *)image to:(UIImageOrientation)to;

- (UIImage *) imageRotatedByRadians:(CGFloat)radians;
- (UIImage *) imageRotatedByDegrees:(CGFloat)degrees;

@end
