
#import "TPWeatherWatcherViewController.h"

#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface TPWeatherWatcherViewControllerTest : SenTestCase
@end

@implementation TPWeatherWatcherViewControllerTest
{
    // test fixture ivars go here
    TPWeatherWatcherViewController *sut;
    dispatch_semaphore_t semaphore;
    BOOL weatherDataLoaded;
    BOOL forecastDataLoaded;
}

- (void)setUp
{
    [super setUp];
    
    weatherDataLoaded = NO;
    forecastDataLoaded = NO;
    
    sut = [[TPWeatherWatcherViewController alloc] initWithNibName:@"TPWeatherWatcher"
                                                           bundle:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weatherRetrieved:)
                                                 name:kTPWeatherNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastRetrieved:)
                                                 name:kTPFiveDayForecastNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationNameRetrieved:)
                                                 name:kTPReverseGeocodingNotification
                                               object:nil];

    
    semaphore = dispatch_semaphore_create(0);
    [sut view];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

}

- (void)tearDown
{
    sut = nil;
    semaphore = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super tearDown];
}


- (void)weatherRetrieved:(NSNotification *)notification
{
    weatherDataLoaded = YES;
    
    if (forecastDataLoaded) {
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)forecastRetrieved:(NSNotification *)notification
{
    forecastDataLoaded = YES;
    
    if (weatherDataLoaded) {
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)locationNameRetrieved:(NSNotification *)notification
{
    if (weatherDataLoaded && forecastDataLoaded) {
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)testWeatherStateIconShouldBeConnected
{
    assertThat(sut.weatherStateIcon, notNilValue());
}

- (void)testLocationNameLabelShouldBeConnected
{
    assertThat(sut.currentLocationName, notNilValue());
}

- (void)testLocationLabelShouldHaveACityName
{
    assertThatInteger(sut.currentLocationName.text.length, isNot(equalToInteger(0)));
}

- (void)testTemperatureLabelShouldBeConnected
{
    assertThat(sut.temperature, notNilValue());
}

- (void)testTemperatureLabelShouldHaveATemperatureValue
{
    assertThat(sut.temperature.text, isNot(equalTo(@"")));
}

- (void)testFiveDayForecastAreaShouldBeConnected
{
    assertThat(sut.fiveDayForecast, notNilValue());
}

- (void)testShouldLoadWeatherOnLoad
{
    assertThatBool(weatherDataLoaded, equalToBool(YES));
    assertThatBool(forecastDataLoaded, equalToBool(YES));
}

- (void)testShouldHaveMenuButtonConnected
{
    assertThat(sut.menuButton, notNilValue());
}

- (void)testPressedMenuButtonShouldShowMenu
{
    [sut.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    assertThatFloat(sut.mainContent.center.x, isNot(equalToFloat(160.0f)));
}


- (void)testPressedMenuButtonTwiceShouldHideMenu
{
    [sut.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [sut.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    assertThatFloat(sut.mainContent.center.x, equalToFloat(160.0f));
}

- (void)testShouldHaveLocationListTableConnected
{
    assertThat(sut.locationListTable, notNilValue());
}

- (void)testLocationListTableShouldHaveAConnectedDelegate
{
    assertThat(sut.locationListTable.delegate, notNilValue());
}

- (void)testLocationListTableShouldHaveAConnectedDataSource
{
    assertThat(sut.locationListTable.dataSource, notNilValue());
}

- (void)testLocationTableListShouldHaveTotalNumberOfRowsInSection
{
    assertThatInteger([sut.locationListTable numberOfRowsInSection:0], notNilValue());
}

@end
