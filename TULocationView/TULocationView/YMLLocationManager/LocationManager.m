#import "LocationManager.h"
#import "BZFoursquare.h"

NSString *LocationManagerNotAuthorized = @"LocationManagerNotAuthorized";

@interface LocationManager ()


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy) LocationCallback  locCallback;
@property (nonatomic, copy) reverseGeoCallback  reverseGeoCallback;
@property (nonatomic, copy) foursquarePlacesCallback  fSquareCallBack;
@property (nonatomic, strong) BZFoursquare *fsquare;


@end

static LocationManager *sharedCLDelegate = nil;

@implementation LocationManager

@synthesize geocoder,locationManager,locCallback,reverseGeoCallback,fsquare,fSquareCallBack;

+ (BOOL) isEnabled {
    return ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);
}

-(void)findMyLocation
{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        if(!self.locationManager) {
            self.locationManager=[[CLLocationManager alloc] init];
            [self.locationManager setDelegate:self];
        }
        [self.locationManager stopUpdatingHeading];
        self.locationManager.distanceFilter=100;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        [self.locationManager startUpdatingLocation];
    }
    else {
        if (self.reverseGeoCallback) {
            self.reverseGeoCallback(NO, nil, LocationManagerNotAuthorized);
            self.reverseGeoCallback = nil;
        }
        else if (self.locCallback) {
            self.locCallback(NO, nil);
            self.locCallback = nil;
        }
    }
}

-(BOOL)findMyLocation:(LocationCallback)callback
{
    BOOL accept = FALSE;
    
    if(self.locCallback == Nil)
    {
        self.locCallback = callback;
        [self findMyLocation];
        accept = TRUE;
    }
    
    return accept;
}

-(BOOL)findMyLocationWithDetails:(reverseGeoCallback)callback
{
    BOOL accept = FALSE;
    
    if(self.locCallback == Nil)
    {
        self.reverseGeoCallback = callback;
        [self findMyLocation];
        accept = TRUE;
    }
    
    return accept;

}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
//	float lat = newLocation.coordinate.latitude;
//	float longt = newLocation.coordinate.longitude;
//	NSString *latitudeStr = [[NSString alloc] initWithFormat:@"%f",lat];
//    NSString *longitudeStr = [[NSString alloc] initWithFormat:@"%f",longt];
//	[locationManager stopUpdatingLocation];
	
    if(locCallback)
    {
        self.locCallback(TRUE,manager.location);
        self.locCallback =nil;
    
    }
    
    if(reverseGeoCallback)
    {
        [self.geocoder reverseGeocodeLocation:manager.location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (error) {
                if (self.reverseGeoCallback) {
                    self.reverseGeoCallback (FALSE,Nil,@"failure");
                    self.reverseGeoCallback =Nil;
                }
            }
            else {
                if([placemarks count]>0)
                {
                    CLPlacemark *mark = [placemarks objectAtIndex:0];
                    
                    NSString *displayString = [NSString stringWithFormat:@"%@, %@",mark.locality, mark.ISOcountryCode];
                    
                    if (self.reverseGeoCallback) {
                        self.reverseGeoCallback(TRUE,manager.location,displayString);
                        self.reverseGeoCallback =nil;
                    }
                }
            }
        }];
    }

    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
	[self.locationManager stopUpdatingLocation];
	self.locationManager.delegate=nil;
	self.locationManager =nil;
    
    if(self.reverseGeoCallback)
    {
        if (self.reverseGeoCallback) {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                self.reverseGeoCallback (FALSE, nil, LocationManagerNotAuthorized);
            }
            else {
                self.reverseGeoCallback (FALSE, nil, @"failure");
            }
            self.reverseGeoCallback =Nil;
        }
    }
    else if(self.locCallback)
    {
        self.locCallback (TRUE, nil);
        self.locCallback = nil;
    }
    
}

+ (LocationManager *)sharedInstance
{
    
    @synchronized(self)
	{
        if (sharedCLDelegate == nil)
		{
           sharedCLDelegate = [super allocWithZone:NULL];
           sharedCLDelegate.geocoder = [[CLGeocoder alloc] init];
            sharedCLDelegate.fsquare = [[BZFoursquare alloc] initWithClientID:kClientID callbackURL:kCallbackURL];
            sharedCLDelegate.fsquare.version = @"20111119";
            sharedCLDelegate.fsquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        }
    }
    return sharedCLDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    
    @synchronized(self)
	{
        if (sharedCLDelegate == nil)
		{
            sharedCLDelegate = [super allocWithZone:zone];
			return sharedCLDelegate; 
		}
    }
    return nil; 
}


- (void)dealloc
{

}



-(void)findFourSquarePlaces:(CLLocationCoordinate2D)latLong  callBackOn:(foursquarePlacesCallback)callback
{
    self.fSquareCallBack = callback;
    
    NSString *latlong = [NSString stringWithFormat:@"%f,%f",latLong.latitude,latLong.longitude];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:latlong, @"ll",@"8000",@"radius",@"X1Q2I1TQJBYZCSLLCLQQCUATIPHFDXNLNSQOFZNN410IQDW5",@"client_id",@"0PKKEXFKVJCCJHWV2CY1QE3J2W454EDZH4ZGM2WMYXAQUGHY",@"client_secret",@"DATEVERIFIED",@"v",nil];

   // self.fsquare.sessionDelegate =self;
    BZFoursquareRequest *fsRequest = [self.fsquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [fsRequest start];

}


#pragma mark - BZFoursquareRequestDelegate

-(void)requestDidFinishLoading:(BZFoursquareRequest *)request
{
    NSArray *Venues = [request.response objectForKey:@"groups"];
    NSMutableArray *arrayofPlaces = [[NSMutableArray alloc] init];

    if([Venues count] > 0)
    {
        NSArray *groups = [[Venues objectAtIndex:0] objectForKey:@"items"];
               for (int i =0; i<[groups count]; i++)
        {
            NSDictionary *dict = [groups objectAtIndex:i];
            NSString *name =[dict objectForKey:@"name"];
            NSString *category = @"";
            NSString *icon = @"";
            if([[dict objectForKey:@"categories"] count] > 0)
            {
                category  = [[[dict objectForKey:@"categories"] objectAtIndex:0]objectForKey:@"name"];
                icon = [[[dict objectForKey:@"categories"] objectAtIndex:0]objectForKey:@"icon"];
                if ([[UIScreen mainScreen] scale] == 2.0) {
                    NSRange range = NSMakeRange([icon length] - 4, 4);
                    icon = [icon stringByReplacingOccurrencesOfString:@".png"
                                                           withString:@"_64.png"
                                                              options:NSCaseInsensitiveSearch
                                                                range:range];
                }
            }
            else
            {
                category = @"No category";
            }
            NSString *placeid = [dict objectForKey:@"id"];
            NSString *lattitude = [[[dict objectForKey:@"location"]objectForKey:@"lat"] stringValue];
            NSString *longitude  = [[[dict objectForKey:@"location"]objectForKey:@"lng"] stringValue];
            NSString *distance  = [[[dict objectForKey:@"location"]objectForKey:@"distance"] stringValue];
            
            NSDictionary *placesDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name", category,@"category",icon,@"icon",placeid,@"id",lattitude,@"latitude",longitude,@"longitude",distance,@"distance",nil];
            
            [arrayofPlaces addObject:placesDict];
        }
             
    }

    self.fSquareCallBack(TRUE, arrayofPlaces);
    
}

-(void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error
{
     self.fSquareCallBack(FALSE, Nil);
}

@end

