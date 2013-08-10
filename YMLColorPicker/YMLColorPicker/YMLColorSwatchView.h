//
//  YMLColorSwatchView.h
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMLColorSwatchViewDelegate;

@interface YMLColorSwatchView : UIView {
    UIColor *currentColor;
    
    id<YMLColorSwatchViewDelegate> delegate;
}

@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, assign) id<YMLColorSwatchViewDelegate> delegate;

- (void) moveToPoint:(CGPoint)point;

@end


@protocol YMLColorSwatchViewDelegate <NSObject>

@optional
- (void) colorSwatch:(YMLColorSwatchView *)swatchView didPickColor:(UIColor *)color;

@end
