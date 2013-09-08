//
//  WeatherWatcher - Test.m
//  Copyright 2013 Jason Lagaac. All rights reserved.
//
//  Created by: Jason Lagaac
//

#import "TPWeather.h"

#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface TPWeatherTest : SenTestCase
@end

@implementation TPWeatherTest
{
    // test fixture ivars go here
    double latitude;
    double longitude;
    TPWeather *sut;

    dispatch_semaphore_t semaphore;
    NSDictionary *weatherData;
    NSArray *weatherForecast;
    NSString *locationName;
}

- (void)setUp
{
    [super setUp];
    sut = [[TPWeather alloc] init];
    
    weatherData = nil;
    weatherForecast = nil;
    locationName = nil;
    
    semaphore = dispatch_semaphore_create(0);

}

- (void)tearDown
{
    sut = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super tearDown];
}

- (void)weatherRetrieved:(NSNotification *)notification
{
    if (!weatherData) {
        NSLog(@"Weather Retrieved Here %@", weatherData);
        weatherData = [notification object];
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)forecastRetrieved:(NSNotification *)notification
{
    if (!weatherForecast) {
        weatherForecast = [[notification object] copy];
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)locationNameRetrieved:(NSNotification *)notification
{
    if (!locationName) {
        locationName = [[notification object] copy];
        dispatch_semaphore_signal(semaphore);
    }
}


#pragma mark - Test cases
////////////////////////////////////////////////////////////////////////////////

- (void)testShouldRetrieveCurrentWeatherAtLocation
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weatherRetrieved:)
                                                 name:kTPWeatherNotification
                                               object:nil];
    // When
    [sut retrieveWeatherAtLatitude:-33.880036
                         longitude:151.200238];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    // Then
    assertThat(weatherData, notNilValue());
}


- (void)testShouldRetrieveTheFiveDayWeatherForecastForLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastRetrieved:)
                                                 name:kTPFiveDayForecastNotification
                                               object:nil];
    
    // When
    [sut retrieveFiveDayWeatherForecastAtLatitude:-33.880036
                                        longitude:151.200238];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    // Then
    assertThat(weatherForecast, notNilValue());
}

- (void)testShouldRetrieveWeatherWithLocationServices
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weatherRetrieved:)
                                                 name:kTPWeatherNotification
                                               object:nil];
    // When
    [sut startMonitoringLocation];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    assertThat(weatherData, notNilValue());
}

- (void)testShouldRetrieveForecastWithLocationServices
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastRetrieved:)
                                                 name:kTPFiveDayForecastNotification
                                               object:nil];
    
    semaphore = dispatch_semaphore_create(0);
    
    // When
    [sut startMonitoringLocation];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    assertThat(weatherForecast, notNilValue());
}

- (void)testShouldRetrieveTheLocationName
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationNameRetrieved:)
                                                 name:kTPReverseGeocodingNotification
                                               object:nil];
    // When
    [sut startMonitoringLocation];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    assertThat(locationName, notNilValue());
}


@end
