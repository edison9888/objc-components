//
//  CTScrollableLabel.m
//  CT
//
//  Created by Sumit Mehra on 3/4/12.
//  Copyright (c) 2012 Dealclan LLC. All rights reserved.
//

#import "CTScrollableLabel.h"

@implementation CTScrollableLabel

@synthesize label;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andString:@""];
}

- (id)initWithFrame:(CGRect)frame andString:(NSString *)string {
    self = [super initWithFrame:frame];
    if (self) {
        label = [[CTLabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20) andString:string];
        [label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:label];
        
        [self setContentSize:CGSizeMake(frame.size.width, label.frame.size.height)];
    }
    
    return self;
}


#pragma mark - LayoutSubviews

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self setContentSize:CGSizeMake(self.frame.size.width - 20, label.frame.size.height)];
}


#pragma mark - Public Methods

- (void) setText:(NSString *)text {
    [label setText:text];
    
    [self setContentSize:CGSizeMake(self.frame.size.width, label.frame.size.height)];
}

- (void) setFontSize:(float)fontSize {
    [label setFontSize:fontSize];
}

- (void) setFontFamily:(NSString *)fontFamily {
    [label setFontFamily:fontFamily];
}

- (void) setTextColor:(UIColor *)textColor {
    [label setTextColor:textColor];
}

- (void) setLabelType:(CTLabelType)labelType {
    [label setLabelType:labelType];
}

- (void) setLinks:(NSArray *)links {
    [label setLinks:links];
}

- (void) setLinkHighlightedColor:(UIColor *)linkHighlightedColor {
    [label setLinkHighlightedColor:linkHighlightedColor];
}


#pragma mark - Dealloc


@end
