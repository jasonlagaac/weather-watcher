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

- (void)retrieveWeatherAtLatitude:(CGFloat)latitude
                        longitude:(CGFloat)longitude
                          success:(void ( ^ ) (NSDictionary *data) )successBlock
                             fail:(void ( ^ ) () )failBlock;

- (void)retrieveFiveDayWeatherForecastAtLatitude:(CGFloat)latitude
                                       longitude:(CGFloat)longitude
                                         success:(void ( ^ )(NSArray *data))successBlock
                                            fail:(void ( ^ )())failBlock;

- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;

@end
