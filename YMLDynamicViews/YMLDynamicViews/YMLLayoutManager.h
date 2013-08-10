//
//  YMLLayoutManager.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YMLView;

@interface YMLLayoutManager : NSObject

+ (YMLLayoutManager *) layoutManager;

- (YMLView *) layoutForId:(NSString *)layoutId;
- (YMLView *) layoutForId:(NSString *)layoutId superView:(UIView *)superView;

@end
