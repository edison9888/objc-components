//
//  TULabel.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/26/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TULabelImageAlignment {
    TULabelImageAlignmentLeft = 0,
    TULabelImageAlignmentCenter,
    TULabelImageAlignmentRight,
}TULabelImageAlignment;

@protocol TULabelDelegate;

@interface TULabel : UILabel {
    BOOL isTapEnabled;
    
    UIEdgeInsets textInset, imageInset;
    TULabelImageAlignment imageAlignment;
    
    __weak id<TULabelDelegate> delegate;
}

@property (nonatomic, readwrite, setter = setTapEnabled:) BOOL isTapEnabled;
@property (nonatomic, assign) UIEdgeInsets textInset, imageInset;
@property (nonatomic, assign) TULabelImageAlignment imageAlignment;
@property (nonatomic, weak) id<TULabelDelegate> delegate;

- (void) setImage:(UIImage *)image;
- (void) setImage:(UIImage *)image withSizeFit:(BOOL)isSizeFit;
- (void) setShowShadow:(BOOL)show;

@end


@protocol TULabelDelegate <NSObject>

@optional
- (void) labelDidTapped:(TULabel *)label;

@end
