//
//  Text.h
//  Rotate
//
//  Created by Sumit Mehra on 4/21/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#define DEGREE_TO_RADIANS(degree)           (degree * (M_PI/180))
#define RADIANS_TO_DEGREE(radians)           (radians * (180/M_PI))

typedef struct GlyphArcInfo {
	CGFloat			width;
	CGFloat			angle;	// in radians
} GlyphArcInfo;

void PrepareGlyphArcInfo(CTLineRef, CFIndex, GlyphArcInfo *, double);

@class YMLRotateMenu;
@protocol YMLRotateMenuDelegate, YMLRotateMenuTextDelegate;

@interface YMLRotateMenuText : UIView {
    float fontSize;
    double radius, curveAngle;
    
    NSString *normalFontName, *highlightedFontName;
    NSMutableAttributedString *stringToDraw;
    NSMutableArray *menuItems;
    
    NSMutableDictionary *anglesForWords;
    
    UIColor *normalFontColor, *highlightedFontColor;
    
    __weak id<YMLRotateMenuDelegate> delegate;
    __weak YMLRotateMenu *rotateMenu;
}

@property (nonatomic, readwrite) float fontSize;
@property (nonatomic, readwrite) double radius, curveAngle;
@property (nonatomic, copy) NSString *normalFontName, *highlightedFontName;
@property (nonatomic) NSMutableArray *menuItems;
@property (nonatomic) UIColor *normalFontColor, *highlightedFontColor;
@property (nonatomic) NSMutableDictionary *anglesForWords;
@property (nonatomic, weak) id<YMLRotateMenuDelegate> delegate;
@property (nonatomic, weak) YMLRotateMenu *rotateMenu;

- (double) wrapd:(double)_val min:(double)_min max:(double)_max;

- (void) selectNone;
- (void) setCurrentMenuItemIndex:(int)index;
- (void) setCurveAngle:(double)_curveAngle;

- (float) angleForItemAtIndex:(int)index;
- (float) itemAngleForViewAngle:(float)degree;
- (int) itemIndexAtAngle:(float)degree;
- (float) widthForItemAtIndex:(int)index;

- (float) minimum;
- (float) maximum;

- (void) reload;

@end


@protocol YMLRotateMenuTextDelegate <NSObject>

@optional
- (BOOL) rotateMenu:(YMLRotateMenu *)rotateMenu needSeparatorAtIndex:(NSInteger)index isFrontSeparator:(BOOL)isFront;
- (UIImage *) rotateMenu:(YMLRotateMenu *)rotateMenu separatorImageAtIndex:(NSInteger)index isFrontSeparator:(BOOL)isFront;

@end
