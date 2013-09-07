//
//  WeatherWatcher - TPWeatherWatcherMenuViewControllerTest.m
//  Copyright 2013 Jason Lagaac. All rights reserved.
//
//  Created by: Jason Lagaac
//

    // Class under test
#import "TPWeatherWatcherMenuViewController.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>


@interface TPWeatherWatcherMenuViewControllerTest : SenTestCase
@end

@implementation TPWeatherWatcherMenuViewControllerTest
{
    // test fixture ivars go here
    TPWeatherWatcherMenuViewController *sut;
}

- (void)setUp
{
    [super setUp];
    
    sut = [[TPWeatherWatcherMenuViewController alloc] initWithNibName:@"TPWeatherWatcherMenuViewController"
                                                               bundle:nil];
    [sut view];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTableViewShouldBeConnected
{    
    assertThat(sut.locationListTable, notNilValue());
}

- (void)testTableViewShouldHaveConnectedDelegate
{
    assertThat(sut.locationListTable.delegate, notNilValue());
}

- (void)testTableViewShouldHaveConnectedDataSource
{
    assertThat(sut.locationListTable.dataSource, notNilValue());
}

@end
