//
//  TUGridCell.h
//  Tourean
//
//  Created by Karthik Keyan B on 11/24/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "AQGridViewCell.h"

#define GRID_SIZE       CGSizeMake(80, 80)

extern CGRect contentRect;

@interface TUGridCell : AQGridViewCell

@property (nonatomic, assign) BOOL enableHighlighting;

- (void) setImage:(UIImage *)image;
- (void) clear;

@end
