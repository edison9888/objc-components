//
//  CTLabel.m
//  CT
//
//  Created by Sumit Mehra on 3/4/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "CTLabel.h"


NSString *CTLabelPressNotification = @"CTLabelPressNotification";

@interface CTLabel () {
    NSString *originalString;
    NSMutableArray *paragraphs;
}

@property (nonatomic, copy) NSString *originalString;
@property (nonatomic) NSMutableArray *paragraphs;

- (void) loadStyles;

@end


@implementation CTLabel

@synthesize height;
@synthesize fontSize;
@synthesize labelType;
@synthesize stringToDraw;
@synthesize originalString;
@synthesize paragraphs;
@synthesize fontFamily;
@synthesize links;
@synthesize linkHighlightedColor, linkUnderLineColor;
@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andString:@""];
}

- (id) initWithFrame:(CGRect)frame andString:(NSString *)string {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        labelType = CTLabelTypeNone;
        
        fontSize = 14.0;
        
        stringToDraw = [[NSMutableAttributedString alloc] initWithString:@""];
        
        [self setOriginalString:string];
        [self setFontFamily:@"Georgia"];
    }
    
    return self;
}


#pragma mark - Draw Rect

- (void) layoutSubviews {
    [super layoutSubviews];
}


#pragma mark - Draw Rect

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (links) {
        [self attributeString:stringToDraw makeLinkForWords:links];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGMutablePathRef path = CGPathCreateMutable(); 
    CGPathAddRect(path, NULL, [self bounds]);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [stringToDraw length]), path, NULL);
    CTFrameDraw(frame, context);
    
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}


#pragma mark - Setter Methods

- (void)setLinks:(NSArray *)_links {
    if (links != _links) {
        links = _links;
        
        [self loadStyles];
        
        [self attributeString:stringToDraw makeLinkForWords:links];
        [self setNeedsDisplay];
    }
}


#pragma mark - Private Methods

- (void) loadStyles {
    if (stringToDraw) {        
        stringToDraw = [[NSMutableAttributedString alloc] initWithString:originalString];
    }
    
    switch (labelType) {
        case CTLabelTypeNone:
            [self noStyle];
            break;
        
        default:
            break;
    }
}


#pragma mark - Public Methods

#pragma mark Load Style Functions

- (void) noStyle {
    // Release the previous values
    if (stringToDraw) { [self setStringToDraw:nil]; }
    stringToDraw = [[NSMutableAttributedString alloc] initWithString:originalString];
    
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)[NSString stringWithFormat:@"%@", fontFamily], fontSize, NULL);
    [stringToDraw addAttribute:(id)kCTFontAttributeName value:(__bridge id)boldFont range:NSMakeRange(0, [originalString length])];
    CFRelease(boldFont);
    
    [stringToDraw addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[self textColor] CGColor] range:NSMakeRange(0, [stringToDraw length])];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(self.bounds.size.width, CGFLOAT_MAX), NULL);    
    CFRelease(framesetter);
    
    height = suggestedSize.height + 30;
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
}


#pragma mark Styling Functions

- (void) attributeStringMakeCenterAlign:(NSMutableAttributedString *)string {
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphStyles = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSpecifier));
    
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphStyles range:NSMakeRange(0, [string length])];
    
    CFRelease(paragraphStyles);
}

- (void) attributeString:(NSMutableAttributedString *)string withIndent:(float)indent {
    CTParagraphStyleSetting setting[] = {
        {kCTParagraphStyleSpecifierHeadIndent, sizeof(float), &indent},
    };
    CTParagraphStyleRef paragraphStyles = CTParagraphStyleCreate(setting, sizeof(setting)/sizeof(CTParagraphStyleSpecifier));
    
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphStyles range:NSMakeRange(0, [string length])];
    
    CFRelease(paragraphStyles);
}

- (void) attributeString:(NSMutableAttributedString *)string makeBoldOfRange:(NSRange)range {
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)[NSString stringWithFormat:@"%@-Bold", fontFamily], fontSize, NULL);
    [string addAttribute:(id)kCTFontAttributeName value:(__bridge id)boldFont range:range];
    CFRelease(boldFont);
}

- (void) attributeString:(NSMutableAttributedString *)string makeItalicOfRange:(NSRange)range {
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)[NSString stringWithFormat:@"%@-Italic", fontFamily], fontSize, NULL);
    [string addAttribute:(id)kCTFontAttributeName value:(__bridge id)boldFont range:range];
    CFRelease(boldFont);
}

- (void) attributeString:(NSMutableAttributedString *)string makeUnderlineOfRange:(NSRange)range {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (linkUnderLineColor) {
        [dict setObject:(id)[linkUnderLineColor CGColor] forKey:(id)kCTUnderlineColorAttributeName];
    }
    else if (linkHighlightedColor) {
        [dict setObject:(id)[linkHighlightedColor CGColor] forKey:(id)kCTUnderlineColorAttributeName];
    }
    else {
        [dict setObject:(id)[[self textColor] CGColor] forKey:(id)kCTUnderlineColorAttributeName];
    }
    [dict setObject:[NSNumber numberWithInt:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
    [string addAttributes:dict range:range];
}

- (void) attributeString:(NSMutableAttributedString *)string makeLinkForWord:(NSString *)word {
    NSRange range = NSMakeRange(0, [string length]);
    
    int length = [string length];
    while (range.location != NSNotFound) {
        range = [[string string] rangeOfString:word options:NSCaseInsensitiveSearch range:range];
        if (range.location != NSNotFound) {
            [self attributeString:string makeBoldOfRange:range];
            [self attributeString:string makeUnderlineOfRange:range];
            if (linkHighlightedColor) {
                [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)[linkHighlightedColor CGColor] range:range];
            }
            
            range = NSMakeRange(range.location + range.length, (length - (range.location + range.length)));
        }
    }
}

- (void) attributeString:(NSMutableAttributedString *)string makeLinkForWords:(NSArray *)words {
    for (NSString *word in words) {
        [self attributeString:string makeLinkForWord:word];
    }
}

- (void) setText:(NSString *)text {
    [self setOriginalString:text];
    
    
    switch (labelType) {
            
        default:
            [self noStyle];
            break;
    }
}


#pragma mark - Touch Label

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:[[touches anyObject] view]];
    
    CGMutablePathRef path = CGPathCreateMutable(); 
    CGPathAddRect(path, NULL, [self bounds]);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [stringToDraw length]), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    int lineCount = CFArrayGetCount(lines);
    
    CGRect textFrame = CGRectZero;
    
    for (int i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGPoint origins;
        CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origins);
        
        CGFloat ascent, descent;
        CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        
        textFrame.origin.y = self.bounds.origin.y + self.bounds.size.height - (origins.y + ascent);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runsTotal = CFArrayGetCount(runs);
        
        for (int j = 0; j < runsTotal; j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            
            NSRange range = NSMakeRange(CTRunGetStringRange(run).location, CTRunGetStringRange(run).length);
            if (range.length > 0 && range.length != NSIntegerMax && range.location < [originalString length]) {
                NSString *string = [originalString substringWithRange:range];
                
                const CGPoint *org = CTRunGetPositionsPtr(run);
                textFrame.origin.x = org->x;
                
                CTFontRef font = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
                NSString *runFontName = (__bridge_transfer NSString *)CTFontCopyPostScriptName(font);
                textFrame.size = [string sizeWithFont:[UIFont fontWithName:runFontName size:fontSize]];
            
                if (CGRectContainsPoint(textFrame, point)) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CTLabelPressNotification object:string];
                    if ([delegate respondsToSelector:@selector(label:tapOnWord:)]) {
                        [delegate label:self tapOnWord:string];
                    }
                    
                    CFRelease(frame);
                    CFRelease(path);
                    CFRelease(framesetter);
                    return;
                }
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}


#pragma mark - Dealloc


@end
