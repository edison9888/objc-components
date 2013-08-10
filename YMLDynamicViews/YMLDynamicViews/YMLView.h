//
//  YMLView.h
//  YMLDynamicViews
//
//  Created by Karthik Keyan B on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMLView : UIView {
    NSString *layoutId;
}

@property (nonatomic, copy) NSString *layoutId;

- (id) initWithLayoutId:(NSString *)layoutId;
- (UIView *) viewWithTag:(NSInteger)tag;
- (void) addControl:(NSDictionary *)controlData;
- (void) layoutControlsByZIndex;

@end
