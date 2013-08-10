//
//  YMLArrangeableScrollView.h
//  test
//
//  Created by Karthik Keyan B on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLThumbView.h"

@class YMLArrangeableScrollView;

@protocol YMLArrangeableScrollViewDataSource;

@protocol YMLArrangeableScrollViewDelegate <UIScrollViewDelegate>

@end

@interface YMLArrangeableScrollView : UIScrollView {
    BOOL isHorizontal;
    
    id<YMLArrangeableScrollViewDataSource> dataSource;
    id<YMLArrangeableScrollViewDelegate> delegate;
}

@property (nonatomic, assign, setter = setHorizontal:) BOOL isHorizontal;
@property (nonatomic, assign) id<YMLArrangeableScrollViewDataSource> dataSource;
@property (nonatomic, assign) id<YMLArrangeableScrollViewDelegate> delegate;

- (void) reload;
- (void) resetLayout;

@end

@protocol YMLArrangeableScrollViewDataSource <NSObject>

@required
- (NSUInteger) numberOfSubViewsInScrollView:(YMLArrangeableScrollView *)scrollView;
- (UIView *) scrollView:(YMLArrangeableScrollView *)scrollView subViewAtIndex:(NSUInteger)index;
- (CGSize) scrollView:(YMLArrangeableScrollView *)scrollView subViewsSizeInHorizontalLayout:(BOOL)isHorizontalLayout;
- (CGFloat) scrollView:(YMLArrangeableScrollView *)scrollView verticalSpaceInHorizontalLayout:(BOOL)isHorizontalLayout;
- (CGFloat) scrollView:(YMLArrangeableScrollView *)scrollView horizontalSpaceInHorizontalLayout:(BOOL)isHorizontalLayout;

@end

