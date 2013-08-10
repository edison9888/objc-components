//
//  YMLColorAdjustmentView.h
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMLColorAdjustmentViewDelegate;

@interface YMLColorAdjustmentView : UIView {
    UIColor *currentColor;
    
    id<YMLColorAdjustmentViewDelegate> delegate;
}

@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, assign) id<YMLColorAdjustmentViewDelegate> delegate;

- (void) createAdjustmentPaletteForColor:(UIColor *)color;
- (void) moveToPoint:(CGPoint)point;

@end


@protocol YMLColorAdjustmentViewDelegate <NSObject>

@optional
- (void) colorAdjustmentView:(YMLColorAdjustmentView *)adjustmentView didPickColor:(UIColor *)color;

@end
