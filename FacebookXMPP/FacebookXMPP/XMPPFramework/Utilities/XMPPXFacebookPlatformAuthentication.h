//
//  XMPPXFacebookPlatformAuthentication.h
//  iPhoneXMPP
//
//  Created by Eric Chamberlain on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import "DDXML.h"
#endif

#import "XMPPSASLAuthentication.h"

@interface XMPPXFacebookPlatformAuthentication : NSObject <XMPPSASLAuthentication>
{
  NSString *appId;
  NSString *accessToken;
  NSString *nonce;
  NSString *method;
  NSString *sessionSecret;
}

@property (nonatomic,copy) NSString *appId;
@property (nonatomic,copy) NSString *accessToken;
@property (nonatomic,copy) NSString *nonce;
@property (nonatomic,copy) NSString *method;
@property (nonatomic,copy) NSString *sessionSecret;

- (id)initWithChallenge:(NSXMLElement *)challenge appId:(NSString *)appId accessToken:(NSString *)accessToken;

@end 
