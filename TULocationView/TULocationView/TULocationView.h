//
//  TULocationView.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/19/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocationManager.h"

@protocol TULocationViewDelegate;

@interface TULocationView : UIView {
    __weak id<TULocationViewDelegate> delegate;
}

@property (nonatomic, weak) id<TULocationViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame coordinate:(CLLocationCoordinate2D)coordinate;
- (void) hide;

@end

@protocol TULocationViewDelegate <NSObject>

@optional
- (void) locationViewCancelled:(TULocationView *)locationView;
- (void) locationView:(TULocationView *)locationView didSelectLocation:(NSDictionary *)location;

@end

