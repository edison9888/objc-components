//
//  TULabel.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/26/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "TULabel.h"

@interface TULabel () {
    int space;
    UIImageView *imageView;
    
    UITapGestureRecognizer *tapGesture;
}

- (void) tapGesture:(UITapGestureRecognizer *)tapGesture;

@end

@implementation TULabel

@synthesize isTapEnabled;
@synthesize textInset, imageInset;
@synthesize imageAlignment;
@synthesize delegate;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        space = 5;
        
        imageAlignment = TULabelImageAlignmentLeft;
        
        [self setUserInteractionEnabled:YES];
        [self setTapEnabled:NO];
        [self setBackgroundColor:CLEAR_COLOR];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
        [self setTextColor:[UIColor blackColor]];
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        [self setNumberOfLines:999];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture setEnabled:NO];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void) setImage:(UIImage *)image {
    [self setImage:image withSizeFit:NO];
}

- (void) setImage:(UIImage *)image withSizeFit:(BOOL)isSizeFit {
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
    }
    
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, image.size.width, image.size.height)];
    [imageView setImage:image];
    
    if (isSizeFit) {
        [self sizeToFit];
    }
}

- (void) setShowShadow:(BOOL)show {
    if (show) {
        [self setShadowOffset:CGSizeMake(0, 1)];
        [self setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    }
    else {
        [self setShadowOffset:CGSizeMake(0, 0)];
        [self setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
    }
}

- (void) drawTextInRect:(CGRect)rect {    
    if (imageView && [imageView image]) {
        CGRect imageFrame = CGRectMake(0, (self.bounds.size.height - imageView.image.size.height) * 0.5, imageView.image.size.width, imageView.image.size.height);
        
        imageFrame.origin.y = ((self.bounds.size.height - imageFrame.size.height) * 0.5) + imageInset.top;
        
        if (imageAlignment == TULabelImageAlignmentLeft) {
            rect.origin.x = imageInset.left + imageView.frame.size.width;
            
            imageFrame.origin.x += imageInset.left;
        }
        else if (imageAlignment == TULabelImageAlignmentCenter) {
            rect.origin.y = imageView.frame.size.height;
            imageFrame.origin.x = (self.bounds.size.width - imageFrame.size.width) * 0.5;
            imageFrame.origin.y = imageInset.top;
            
            rect.size.height = [[self text] sizeWithFont:[self font] constrainedToSize:CGSizeMake(VIEW_FRAME.size.width, 999) lineBreakMode:[self lineBreakMode]].height;
        }
        else if (imageAlignment == TULabelImageAlignmentRight) {
            rect.size.width -= (imageView.frame.size.width + imageInset.left);
            imageFrame.origin.x = self.bounds.size.width - (imageFrame.size.width + imageInset.right);
        }
        
        [imageView setFrame:imageFrame];
    }
    
    rect.origin.x += textInset.left;
    rect.origin.y += textInset.top;
    rect.size.width -= textInset.right;
    
    [super drawTextInRect:rect];
}

- (void) sizeToFit {
    CGSize size = [[self text] sizeWithFont:[self font] constrainedToSize:CGSizeMake(VIEW_FRAME.size.width, 999) lineBreakMode:[self lineBreakMode]];
    CGPoint origin = self.frame.origin;
    
    if ([imageView image]) {
        CGRect selfRect = [self frame];
        
        if (imageAlignment == TULabelImageAlignmentLeft) {
            selfRect.size.width = imageInset.left + imageView.frame.size.width;
            selfRect.size.width += textInset.left + size.width;
            
            if ((textInset.top + size.height) > (imageInset.top + imageView.frame.size.height)) {
                selfRect.size.height = textInset.top + size.height;
            }
            else {
                selfRect.size.height = imageInset.top + imageView.frame.size.height;
            }
        }
        else if (imageAlignment == TULabelImageAlignmentCenter) {
            CGFloat imageWidth = imageInset.left + imageView.frame.size.width;
            CGFloat textWidth = textInset.left + size.width;
            
            CGFloat imageHeight = imageInset.top + imageView.frame.size.height;
            imageHeight += textInset.top + size.height;
            
            selfRect.size.width = (imageWidth > textWidth)?imageWidth:textWidth;
            selfRect.size.height = imageHeight;
        }
        else if (imageAlignment == TULabelImageAlignmentRight) {
            selfRect.size.width = imageInset.left + imageInset.right + imageView.frame.size.width;
            selfRect.size.width += textInset.left + size.width;
            
            if ((textInset.top + size.height) > (imageInset.top + imageView.frame.size.height)) {
                selfRect.size.height = textInset.top + size.height;
            }
            else {
                selfRect.size.height = imageInset.top + imageView.frame.size.height;
            }
        }
        
        [self setFrame:selfRect];
    }
    else {
        [self setFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
    }
}


#pragma mark - Setter Methods

- (void) setTapEnabled:(BOOL)tapEnabled {
    if (isTapEnabled != tapEnabled) {
        isTapEnabled = tapEnabled;
        [tapGesture setEnabled:tapEnabled];
    }
}


#pragma mark - Private Methods

- (void) tapGesture:(UITapGestureRecognizer *)__tapGesture {
    if ([delegate respondsToSelector:@selector(labelDidTapped:)]) {
        [delegate labelDidTapped:self];
    }
}


#pragma mark - Delegate

- (void) dealloc {
    [self setText:nil];
    imageView = nil;
    
    [self removeGestureRecognizer:tapGesture];
    tapGesture = nil;
}

@end
