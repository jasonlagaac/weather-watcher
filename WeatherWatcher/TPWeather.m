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
@end


@implementation TPWeather

- (id)init
{
    if (self = [super init]) {
        self.client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        
        // Initialise the location manager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 1000.0f;
        self.locationManager.delegate = self;
}
    
    return self;
}

- (void)dealloc
{
    self.client = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;

}

#pragma mark - Weather Retrieveal Actions
/////////////////////////////////////////////////////////////////////////////////

- (void)retrieveWeatherAtLatitude:(double)latitude
                        longitude:(double)longitude
                          success:(void ( ^ )(NSDictionary *data))successBlock
                             fail:(void ( ^ )())failBlock
{
    NSString *getPath = [NSString stringWithFormat:@"weather?lat=%f&lon=%f&units=metric&APPID=%@", latitude, longitude, kAppID];
    [self.client getPath:getPath
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      id payload = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
                     NSLog(@"Payload: %@", payload);
                      successBlock(payload);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failBlock();
                  }];
}

- (void)retrieveFiveDayWeatherForecastAtLatitude:(double)latitude
                                       longitude:(double)longitude
                                         success:(void ( ^ )(NSArray *data))successBlock
                                            fail:(void ( ^ )())failBlock
{
    NSString *getPath = [NSString stringWithFormat:@"forecast/daily?lat=%f&lon=%f&units=metric&cnt=5&APPID=%@", latitude, longitude, kAppID];
    [self.client getPath:getPath
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     id payload = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:nil];
                     successBlock(payload);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failBlock();
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
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 300.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        [self retrieveWeatherAtLatitude:location.coordinate.latitude
                              longitude:location.coordinate.longitude
                                success:^(NSDictionary *data) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kTPWeatherNotification
                                                                                        object:data];
                                } fail:^{
                                    
                                }];
        
        [self retrieveFiveDayWeatherForecastAtLatitude:location.coordinate.latitude
                                             longitude:location.coordinate.longitude
                                               success:^(NSDictionary *data) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kTPFiveDayForecastNotification
                                                                                                       object:data];
                                               } fail:^{
                                    
                                               }];
    }
}

@end
