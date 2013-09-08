//
//  WeatherModel.h
//  WeatherWatcher
//
//  Created by Jason Lagaac on 5/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TPWeather : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *existingLocations;

- (void)retrieveWeatherAtLatitude:(double)latitude
                        longitude:(double)longitude;

- (void)retrieveFiveDayWeatherForecastAtLatitude:(double)latitude
                                       longitude:(double)longitude;

- (void)retrieveLocationNameAtLatitude:(double)latitude
                             longitude:(double)longitude;

- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;

@end
