#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BZFoursquare.h"

#define kClientID       @"X1Q2I1TQJBYZCSLLCLQQCUATIPHFDXNLNSQOFZNN410IQDW5"
#define kCallbackURL    @"fsqdemo://foursquare"

extern const NSString *LocationManagerNotAuthorized;


typedef void(^LocationCallback)(BOOL success, CLLocation *location);
typedef void(^reverseGeoCallback)(BOOL success, CLLocation *location , NSString *displayname);
typedef void(^foursquarePlacesCallback)(BOOL success,NSArray *places);


@interface LocationManager : NSObject <CLLocationManagerDelegate,BZFoursquareRequestDelegate>

+ (LocationManager *)sharedInstance;

+ (BOOL) isEnabled;
-(BOOL)findMyLocation:(LocationCallback)callback;
-(BOOL)findMyLocationWithDetails:(reverseGeoCallback)callback;
-(void)findFourSquarePlaces:(CLLocationCoordinate2D)latLong  callBackOn:(foursquarePlacesCallback)callback;


@end
