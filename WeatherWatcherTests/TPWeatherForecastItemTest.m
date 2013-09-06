//
//  WeatherWatcher - TPWeatherForecastItemTest.m
//  Copyright 2013 Jason Lagaac. All rights reserved.
//
//  Created by: Jason Lagaac
//

    // Class under test
#import "TPWeatherForecastItem.h"

    // Collaborators

    // Test support
#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface TPWeatherForecastItemTest : SenTestCase
@end

@implementation TPWeatherForecastItemTest
{
    // test fixture ivars go here
    TPWeatherForecastItem *sut;
}

- (void)setUp
{
    sut = [[[NSBundle mainBundle] loadNibNamed:@"TPWeatherForecastItem"
                                         owner:self
                                       options:nil] objectAtIndex:0];
    [sut layoutSubviews];
}


- (void)tearDown
{
    sut = nil;
    [super tearDown];
}


- (void)testShouldHaveWeatherIconConnected
{
    assertThat(sut.weatherIcon, notNilValue());
}

- (void)testShouldHaveTemperatureLabelConnected
{
    assertThat(sut.temperature, notNilValue());
}

- (void)testShouldHaveDayLabelConnected
{
    assertThat(sut.day, notNilValue());
}



@end 
