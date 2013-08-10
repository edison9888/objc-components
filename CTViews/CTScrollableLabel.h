//
//  CTScrollableLabel.h
//  CT
//
//  Created by Sumit Mehra on 3/4/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CTLabel.h"

@interface CTScrollableLabel : UIScrollView {
    CTLabel *label;
}

@property (nonatomic) CTLabel *label;

- (id) initWithFrame:(CGRect)frame andString:(NSString *)string;

- (void) setText:(NSString *)text;
- (void) setFontSize:(float)fontSize;
- (void) setFontFamily:(NSString *)fontFamily;
- (void) setTextColor:(UIColor *)textColor;
- (void) setLabelType:(CTLabelType)labelType;
- (void) setLinks:(NSArray *)links;
- (void) setLinkHighlightedColor:(UIColor *)linkHighlightedColor;

@end
