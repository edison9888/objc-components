//
//  CTLabel.h
//  CT
//
//  Created by Sumit Mehra on 3/4/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

extern NSString *CTLabelPressNotification;

typedef enum CTLabelType {
    CTLabelTypeNone = 0,
}CTLabelType;

@protocol CTLabelDelegate;

@interface CTLabel : UILabel {
    float height, fontSize;
    
    CTLabelType labelType;
    
    NSArray *links;
    NSMutableAttributedString *stringToDraw;
    NSString *fontFamily;
    
    UIColor *linkHighlightedColor, *linkUnderLineColor;
    
    id<CTLabelDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, readwrite) float height, fontSize;
@property (nonatomic, readwrite) CTLabelType labelType;
@property (nonatomic) NSArray *links;
@property (nonatomic, copy) NSMutableAttributedString *stringToDraw;
@property (nonatomic, copy) NSString *fontFamily;
@property (nonatomic) UIColor *linkHighlightedColor, *linkUnderLineColor;
@property (nonatomic, unsafe_unretained) id<CTLabelDelegate> delegate;

- (id) initWithFrame:(CGRect)frame andString:(NSString *)string;

- (void) attributeStringMakeCenterAlign:(NSMutableAttributedString *)string;
- (void) attributeString:(NSMutableAttributedString *)string withIndent:(float)indent;
- (void) attributeString:(NSMutableAttributedString *)string makeBoldOfRange:(NSRange)range;
- (void) attributeString:(NSMutableAttributedString *)string makeItalicOfRange:(NSRange)range;
- (void) attributeString:(NSMutableAttributedString *)string makeUnderlineOfRange:(NSRange)range;
- (void) attributeString:(NSMutableAttributedString *)string makeLinkForWord:(NSString *)word;
- (void) attributeString:(NSMutableAttributedString *)string makeLinkForWords:(NSArray *)words;
- (void) setText:(NSString *)text;

- (void) noStyle;

@end

@protocol  CTLabelDelegate <NSObject>

@optional
- (void) label:(CTLabel *)label tapOnWord:(NSString *)word;

@end
