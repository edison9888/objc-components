//
//  YMLColorPickerView.h
//  YMLColorPicker
//
//  Created by Karthik Keyan B on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLColorSwatchView.h"
#import "YMLColorAdjustmentView.h"

@protocol YMLColorPickerViewDelegate;

@interface YMLColorPickerView : UIView {
    YMLColorSwatchView *swatchView;
    YMLColorAdjustmentView *adjustmentView;
    
    id<YMLColorPickerViewDelegate> delegate;
}

@property (nonatomic, readonly) YMLColorSwatchView *swatchView;
@property (nonatomic, readonly) YMLColorAdjustmentView *adjustmentView;
@property (nonatomic, assign) id<YMLColorPickerViewDelegate> delegate;

@end


@protocol YMLColorPickerViewDelegate <NSObject>

@optional
- (void) colorPicker:(YMLColorPickerView *)colorPicker didPickColor:(UIColor *)color;

@end
