//
//  Text.m
//  Rotate
//
//  Created by Sumit Mehra on 4/21/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "YMLRotateMenuText.h"
#import "YMLRotateMenu.h"

void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo, double curveAngle) {
	NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
	
	// Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
	CFIndex glyphOffset = 0;
	for (id run in runArray) {
		CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
		
		// Ask for the width of each glyph in turn.
		CFIndex runGlyphIndex = 0;
		for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
			glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((__bridge CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
		}
		
		glyphOffset += runGlyphCount;
	}
	
	double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	
	CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
	glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * (curveAngle * 2);
	
	// Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
	CFIndex lineGlyphIndex = 1;
	for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
		CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
		CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
		
		glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * (curveAngle * 2);
		
		prevHalfWidth = halfWidth;
	}
}

@interface YMLRotateMenuText () {
    BOOL isFirstTime;
    int selectedIndex;
}

- (void) callDidLoad;

@end


@implementation YMLRotateMenuText

@synthesize fontSize;
@synthesize radius, curveAngle;
@synthesize normalFontName, highlightedFontName;
@synthesize menuItems;
@synthesize normalFontColor, highlightedFontColor;
@synthesize anglesForWords;
@synthesize delegate;
@synthesize rotateMenu;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        isFirstTime = YES;
        
        radius = 70;
        fontSize = 14.0;
        curveAngle = M_PI;
        [self setNormalFontName:@"Helvetica"];
        [self setHighlightedFontName:@"Helvetica-Bold"];
        [self setNormalFontColor:[UIColor blackColor]];
        [self setHighlightedFontColor:[UIColor blackColor]];
        
        anglesForWords = [[NSMutableDictionary alloc] init];
        menuItems = [[NSMutableArray alloc] init];
        selectedIndex = -1;
    }
    return self;
}


#pragma mark - Draw Rect

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    __block CGContextRef context = UIGraphicsGetCurrentContext();
    
    __block YMLRotateMenuText *blockSelf = self;
    
    void (^drawSeparator)(int, BOOL) = ^(int index, BOOL isFront){
        if ([delegate respondsToSelector:@selector(rotateMenu:needSeparatorAtIndex:isFrontSeparator:)] && [delegate rotateMenu:rotateMenu needSeparatorAtIndex:index isFrontSeparator:isFront]) {
            if ([delegate respondsToSelector:@selector(rotateMenu:separatorImageAtIndex:isFrontSeparator:)]) {
                UIImage *separatorImage = [delegate rotateMenu:rotateMenu separatorImageAtIndex:index isFrontSeparator:isFront];
                float x = (isFront)?9:0;
                float y = 145;
                if (index == selectedIndex) {
                    x = (isFront)?0:([blockSelf widthForItemAtIndex:index] + 48);
                    y = (isFront)?145:140;
                }
                
                CGContextDrawImage(context, CGRectMake(x, y, separatorImage.size.width, separatorImage.size.height), [separatorImage CGImage]);
            }
        }
        blockSelf = nil;
    };
    
    CGContextTranslateCTM(context, self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Initialize the text matrix to a known value
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
	assert(line != NULL);
	
	CFIndex glyphCount = CTLineGetGlyphCount(line);
	if (glyphCount == 0) {
		CFRelease(line);
		return;
	}
	
	GlyphArcInfo *	glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
	PrepareGlyphArcInfo(line, glyphCount, glyphArcInfo, curveAngle);
    
	
	// Move the origin from the lower left of the view nearer to its center.
	CGContextSaveGState(context);
	
	// Rotate the context 90 degrees counterclockwise.
	CGContextRotateCTM(context, M_PI_2);
	
	// Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure to rotate the context after each glyph so the glyphs are spread along a semicircular path.
	CGPoint textPosition = CGPointMake(0.0, radius);
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
	
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	CFIndex runCount = CFArrayGetCount(runArray);
	
	CFIndex glyphOffset = 0;
	CFIndex runIndex = 0;
    
    int currentWordIndex = 0, currentMenuIndex = 0;
    double radians = 0;
    BOOL isStarting = YES;
    
    NSMutableString *currentWord = [NSMutableString stringWithString:@""];
    
	for (; runIndex < runCount; runIndex++) {
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		CFIndex runGlyphCount = CTRunGetGlyphCount(run);
		Boolean	drawSubstitutedGlyphsManually = false;
		CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
		
		CFIndex runGlyphIndex = 0;
		for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			CGContextRotateCTM(context, -(glyphArcInfo[runGlyphIndex + glyphOffset].angle));
			
			// Center this glyph by moving left by half its width.
			CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
			CGFloat halfGlyphWidth = glyphWidth / 2.0;
			CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
			
			// Glyphs are positioned relative to the text position for the line, so offset text position leftwards by this glyph's width in preparation for the next glyph.
			textPosition.x -= glyphWidth;
			
			CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
			textMatrix.tx = positionForThisGlyph.x;
			textMatrix.ty = positionForThisGlyph.y;
			CGContextSetTextMatrix(context, textMatrix);
            
            radians += glyphArcInfo[runGlyphIndex + glyphOffset].angle;
            
            if (isStarting) {
                if (currentMenuIndex < [menuItems count] && (currentMenuIndex == selectedIndex)) {
                    drawSeparator(currentMenuIndex, YES);
                }
                
                if (currentWordIndex < [menuItems count]) {
                    [anglesForWords setObject:[NSNumber numberWithFloat:RADIANS_TO_DEGREE(radians)] forKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:currentWordIndex]]];
                    isStarting = NO;
                }
            }
            
            [currentWord appendString:[[stringToDraw string] substringWithRange:NSMakeRange(runGlyphIndex, 1)]];
            
            if (currentWordIndex < [menuItems count]) {
                for (int menuItemsIndex = 0; menuItemsIndex < [menuItems count]; menuItemsIndex++) {                
                    if ([currentWord isEqualToString:[menuItems objectAtIndex:menuItemsIndex]]) {
                        [anglesForWords setObject:[NSNumber numberWithFloat:RADIANS_TO_DEGREE(radians)] forKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:currentWordIndex]]];
                        [currentWord setString:@""];
                        
                        if  (currentMenuIndex == selectedIndex) {
                            drawSeparator(currentMenuIndex, NO);
                        }
                        
                        currentWordIndex++;
                        currentMenuIndex++;
                        
                        isStarting = YES;
                        break;
                    }
                }
            }
			
			if (!drawSubstitutedGlyphsManually) {
				CTRunDraw(run, context, glyphRange);
			} 
			else {
				// We need to draw the glyphs manually in this case because we are effectively applying a graphics operation by setting the context fill color. Normally we would use kCTForegroundColorAttributeName, but this does not apply as we don't know the ranges for the colors in advance, and we wanted demonstrate how to manually draw.
				CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
				CGGlyph glyph;
				CGPoint position;
				
				CTRunGetGlyphs(run, glyphRange, &glyph);
				CTRunGetPositions(run, glyphRange, &position);
                
//                if (isSeparatorRequire) {
//                    if ([delegate respondsToSelector:@selector(rotateMenu:separatorImageAtIndex:isFrontSeparator:)]) {
//                        UIImage *separatorImage = [delegate rotateMenu:rotateMenu separatorImageAtIndex:currentMenuIndex isFrontSeparator:YES];
//                        separatorImage = [self imageNameInBundle:@"Default" withExtension:@"png"];
//                            
//                        UIGraphicsBeginImageContext(separatorImage.size);
//                        [separatorImage drawAtPoint:position blendMode:kCGBlendModeOverlay alpha:1.0];
//                        UIGraphicsEndImageContext();
//                    }
//                    
//                    isSeparatorRequire = NO;
//                }
				
				CGContextSetFont(context, cgFont);
				CGContextSetFontSize(context, CTFontGetSize(runFont));
				CGContextSetRGBFillColor(context, 0.25, 0.25, 0.25, 0.5);
				CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
				
				CFRelease(cgFont);
			}
		}
		
		glyphOffset += runGlyphCount;
	}
	
	free(glyphArcInfo);
	CFRelease(line);
    
    
    if (isFirstTime) {
        isFirstTime = NO;
        
        [self performSelector:@selector(callDidLoad) withObject:nil afterDelay:1.0];
    }
}


#pragma mark - Setter

- (void)setMenuItems:(NSMutableArray *)_menuItems {
    if (menuItems != _menuItems) {
        [menuItems removeAllObjects];
        
        for (NSString *menu in _menuItems) {
            [menuItems addObject:[NSString stringWithFormat:@"  %@  ", menu]];
        }
        
        if (stringToDraw) {
            stringToDraw = nil;
        }
        
        stringToDraw = [[NSMutableAttributedString alloc] initWithString:[menuItems componentsJoinedByString:@""]];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)normalFontName, fontSize, NULL);
        [stringToDraw addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, [[stringToDraw string] length])];
        [stringToDraw addAttribute:(id)kCTForegroundColorAttributeName value:(id)[normalFontColor CGColor] range:NSMakeRange(0, [[stringToDraw string] length])];
        CFRelease(font);
    }
}


#pragma mark - Private Methods

- (void) callDidLoad {
    if ([delegate respondsToSelector:@selector(rotateMenuDidFinishLoading:)]) {        
        [delegate rotateMenuDidFinishLoading:rotateMenu];
    }
}


#pragma mark - Public Methods

- (double) wrapd:(double)_val min:(double)_min max:(double)_max {
    if(_val < _min) return _max - (_min - _val);
    if(_val > _max) return _val - _max; /*_min - (_max - _val)*/;
    return _val;
}

- (void) setCurveAngle:(double)_curveAngle {
    if (curveAngle != _curveAngle) {
        curveAngle = _curveAngle;
        
        [self setNeedsDisplay];
    }
}

- (void) setCurrentMenuItemIndex:(int)index {
    if (index >= 0 && index < [menuItems count]) {
        selectedIndex = index;
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)highlightedFontName, fontSize, NULL);
        [stringToDraw addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:[[stringToDraw string] rangeOfString:[menuItems objectAtIndex:index]]];
        CFRelease(font);    
        
        [stringToDraw addAttribute:(id)kCTForegroundColorAttributeName value:(id)[highlightedFontColor CGColor] range:[[stringToDraw string] rangeOfString:[menuItems objectAtIndex:index]]];
        
        [self setNeedsDisplay];
    }
}

- (void) selectNone {
    if (stringToDraw) {
        stringToDraw = nil;
    }
    
    stringToDraw = [[NSMutableAttributedString alloc] initWithString:[menuItems componentsJoinedByString:@""]];
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)normalFontName, fontSize, NULL);
    [stringToDraw addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, [[stringToDraw string] length])];
    [stringToDraw addAttribute:(id)kCTForegroundColorAttributeName value:(id)[normalFontColor CGColor] range:NSMakeRange(0, [[stringToDraw string] length])];
    CFRelease(font);
    
    [self setNeedsDisplay];
}

- (float) angleForItemAtIndex:(int)index {
    if (index < 0 || index > [menuItems count]) {
        return 0.0;
    }
    
    float min = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:index]]] floatValue];
    float max = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:index]]] floatValue];
    
    return (min + max)/2;
}

- (float) itemAngleForViewAngle:(float)degree {
    for (int i = 0; i < [menuItems count]; i++) {        
        float min = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:i]]] floatValue];
        float max = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:i]]] floatValue];
        
        if (degree >= min && degree <= max) {
            return (min + max)/2;
        }
    }
    
    return 0;
}

- (int) itemIndexAtAngle:(float)degree {
    for (int i = 0; i < [menuItems count]; i++) {        
        float min = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:i]]] floatValue];
        float max = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:i]]] floatValue];
        
        if (degree >= min && degree <= max) {
            return i;
        }
    }
    
    return -1;
}

- (float) widthForItemAtIndex:(int)index {    
    float min = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:index]]] floatValue];
    float max = [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:index]]] floatValue];
    
    return (max - min);
}

- (float) minimum {
    return [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MIN", [menuItems objectAtIndex:0]]] floatValue];
}

- (float) maximum {
    return [[anglesForWords objectForKey:[NSString stringWithFormat:@"%@_MAX", [menuItems objectAtIndex:([menuItems count] - 1)]]] floatValue];
}


- (void) reload {
    [self setNeedsDisplay];
}


#pragma mark - Dealloc

- (void) dealloc {
    menuItems = nil;
    
    normalFontName = nil;
    highlightedFontName = nil;
    normalFontColor = nil;
    highlightedFontColor = nil;
    anglesForWords = nil;
    
    delegate = nil;
    
}

@end
