//
//  WeatherWatcher - Test.m
//  Copyright 2013 Jason Lagaac. All rights reserved.
//
//  Created by: Jason Lagaac
//

#import "TPWeatherModel.h"

#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface TPWeatherModelTest : SenTestCase
@end

@implementation TPWeatherModelTest
{
    // test fixture ivars go here
    CGFloat latitude;
    CGFloat longitude;
    TPWeatherModel *sut;

    dispatch_semaphore_t semaphore;
    __block NSDictionary *weatherData;
    __block NSArray *weatherForecast;
}

- (void)setUp
{
    [super setUp];
    sut = [[TPWeatherModel alloc] init];

}

- (void)tearDown
{
    sut = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super tearDown];
}

- (void)weatherRetrieved:(NSNotification *)notification
{
    weatherData = [[notification object] copy];
    dispatch_semaphore_signal(semaphore);
}

#pragma mark - Test cases
////////////////////////////////////////////////////////////////////////////////

- (void)testShouldRetrieveCurrentWeatherAtLocation
{
    // Given
    semaphore = dispatch_semaphore_create(0);

    // When
    [sut retrieveWeatherAtLatitude:-33.880036
                         longitude:151.200238
                           success:^(NSDictionary *data) {
                               weatherData = [data copy];                               
                               dispatch_semaphore_signal(semaphore);
                           } fail:^{
                               weatherData = nil;
                               dispatch_semaphore_signal(semaphore);
                           }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    // Then
    assertThat(weatherData, notNilValue());
}


- (void)testShouldRetrieveTheFiveDayWeatherForecastForLocation
{
    // Given
    semaphore = dispatch_semaphore_create(0);
    
    // When
    [sut retrieveFiveDayWeatherForecastAtLatitude:-33.880036
                                        longitude:151.200238
                                          success:^(NSArray *data){
                                              weatherForecast = [data copy];
                                              dispatch_semaphore_signal(semaphore);
                                          } fail:^{
                                              dispatch_semaphore_signal(semaphore);
                                          }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    // Then
    assertThat(weatherForecast, notNilValue());
}

- (void)testShouldRetrieveWeatherWithLocationServices
{
    //Given
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weatherRetrieved:)
                                                 name:kForecastNotification
                                               object:nil];
    semaphore = dispatch_semaphore_create(0);
    
    // When
    [sut startMonitoringLocation];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    assertThat(weatherData, notNilValue());
}

@end
