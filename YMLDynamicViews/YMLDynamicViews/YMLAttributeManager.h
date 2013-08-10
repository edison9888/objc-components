//
//  YMLAttributeManager.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YMLAttributeManager : NSObject

+ (YMLAttributeManager *) attributeManager;

- (void) applyAttribute:(NSDictionary *)attribute forView:(UIView *)view;
- (void) applyAttribute:(NSDictionary *)attribute forView:(UIView *)view inSuperView:(UIView *)superView;

@end
