//
//  Defines.h
//  YMLImageFilter
//
//  Created by கார்த்திக் கேயன் on 6/22/13.
//  Copyright (c) 2013 கார்த்திக் கேயன். All rights reserved.
//

#ifndef YMLImageFilter_Defines_h
#define YMLImageFilter_Defines_h

#define VIEW_FRAME              [[UIScreen mainScreen] applicationFrame]
#define OS_VERSION              [[[UIDevice currentDevice] systemVersion] floatValue]
#define CLEAR_COLOR             [UIColor clearColor]
#define WHITE_COLOR             [UIColor whiteColor]
#define VIEW_BACKGROUND_COLOR   [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]
#define SCREEN_SIZE             [[UIScreen mainScreen] bounds]
#define IS_IPHONE_5             (SCREEN_SIZE.size.height > 480)?YES:NO
#define TU_IMAGE_SIZE           CGSizeMake(312, 312)
#define BORDER_GREEN_COLOR      [UIColor colorWithRed:8.0/255.0 green:186.0/255.0 blue:177.0/255.0 alpha:1.0]

#endif
