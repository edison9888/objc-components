//
//  UIImageView+Extension.m
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+Extension.h"

@implementation UIImageView (Extension)

- (UIColor *) colorAtPoint:(CGPoint)point {
    @synchronized(self) {
        size_t width = self.bounds.size.width;
        size_t height = self.bounds.size.height; 
        size_t bitsPerComponent = 8;
        size_t bytesPerPixel = 4;
        size_t bytesPerRow = bytesPerPixel * width;
        size_t pixelCount = width * height * bytesPerPixel;
        
        unsigned char *pixelData = malloc(pixelCount);            
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixelData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [[self image] CGImage]);
        
        pixelData = CGBitmapContextGetData(context);
        
        int offset = 4 * ((width * round(point.y)) + round(point.x));
        
        int red = pixelData[offset];
        int green = pixelData[offset + 1];
        int blue = pixelData[offset + 2];
        int alpha = pixelData[offset + 3];
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        free(pixelData);
        
        return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
    }
}

@end
