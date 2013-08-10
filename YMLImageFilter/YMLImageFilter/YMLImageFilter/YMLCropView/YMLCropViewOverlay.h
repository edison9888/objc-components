//
//  YMLCropViewOverlay.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMLCropViewOverlay : UIView {
    UIColor *overlayColor;
    CGRect cropRect;
}

@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, assign) CGRect cropRect;

- (id)initWithFrame:(CGRect)frame cropRect:(CGRect)cropRect;

@end
