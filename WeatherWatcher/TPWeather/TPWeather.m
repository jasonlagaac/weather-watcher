//
//  WeatherModel.m
//  WeatherWatcher
//
//  Created by Jason Lagaac on 5/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import "TPWeather.h"
#import <AFNetworking/AFNetworking.h>

// Define the Base URL Format
@interface TPWeather ()
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) BOOL staticLocation;
@end


@implementation TPWeather

- (id)init
{
    if (self = [super init]) {
        self.client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        self.currentLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        
        // Initialise the location manager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000.0f;
        self.locationManager.delegate = self;
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];
        self.existingLocations = [NSMutableArray arrayWithContentsOfFile:plistPath];
}
    
    return self;
}

- (void)dealloc
{
    self.client = nil;
    self.currentLocation = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;

}

#pragma mark - Retrieveal Actions
/////////////////////////////////////////////////////////////////////////////////

- (void)retrieveWeatherAtLatitude:(double)latitude
                        longitude:(double)longitude
{
    NSString *getPath = [NSString stringWithFormat:@"weather?lat=%f&lon=%f&units=metric&APPID=%@", latitude, longitude, kAppID];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.client getPath:getPath
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      id payload = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     [[NSNotificationCenter defaultCenter] postNotificationName:kTPWeatherNotification
                                                                         object:payload];
                 } failure:nil];
}

- (void)retrieveFiveDayWeatherForecastAtLatitude:(double)latitude
                                       longitude:(double)longitude
{
    NSString *getPath = [NSString stringWithFormat:@"forecast/daily?lat=%f&lon=%f&units=metric&cnt=5&APPID=%@", latitude, longitude, kAppID];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.client getPath:getPath
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     id payload = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:nil];
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     [[NSNotificationCenter defaultCenter] postNotificationName:kTPFiveDayForecastNotification
                                                                         object:payload];
                 } failure:nil];
}

- (void)retrieveLocationNameAtLatitude:(double)latitude
                             longitude:(double)longitude
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                      longitude:longitude];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTPReverseGeocodingNotification
                                                            object:[[placemarks objectAtIndex:0] locality]];
        
    }];
}


#pragma mark - CLLocation Delegates
////////////////////////////////////////////////////////////////////////////////

- (void)startMonitoringLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopMonitoringLocation
{
    self.currentLocation = nil;
    self.currentLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    [self.locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 300.0 && [self.currentLocation distanceFromLocation:location]) {
        // load new weather details
        
        self.currentLocation = location;
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        [self retrieveWeatherAtLatitude:location.coordinate.latitude
                              longitude:location.coordinate.longitude];

        [self retrieveFiveDayWeatherForecastAtLatitude:location.coordinate.latitude
                                             longitude:location.coordinate.longitude];
        
        [self retrieveLocationNameAtLatitude:location.coordinate.latitude
                                   longitude:location.coordinate.longitude];
    }
}

@end
