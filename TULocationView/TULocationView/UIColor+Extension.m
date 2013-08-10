//
//  UIColor+Extension.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/30/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end
