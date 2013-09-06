
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
    
}

- (void)tearDown
{
    sut = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super tearDown];
}

- (void)weatherRetrieved:(NSNotification *)notification
{
    weatherDataLoaded = YES;
    dispatch_semaphore_signal(semaphore);
}

- (void)forecastRetrieved:(NSNotification *)notification
{
    forecastDataLoaded = YES;
    dispatch_semaphore_signal(semaphore);
}



- (void)testWeatherStateIconShouldBeConnected
{
    [sut view];
    assertThat(sut.weatherStateIcon, notNilValue());
}

- (void)testLocationNameLabelShouldBeConnected
{
    [sut view];
    assertThat(sut.currentLocationName, notNilValue());
}

- (void)testLocationLabelShouldHaveACityName
{
    [sut view];
    assertThat(sut.currentLocationName.text, equalTo(@"NEW YORK"));
}

- (void)testTemperatureLabelShouldBeConnected
{
    [sut view];
    assertThat(sut.temperature, notNilValue());
}

- (void)testTemperatureLabelShouldHaveATemperatureValue
{
    [sut view];
    assertThat(sut.temperature.text, equalTo(@"9000"));
}

- (void)testFiveDayForecastAreaShouldBeConnected
{
    [sut view];
    assertThat(sut.fiveDayForecast, notNilValue());
}

- (void)testShouldLoadWeatherOnLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastRetrieved:)
                                                 name:kFiveDayForecastNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weatherRetrieved:)
                                                 name:kForecastNotification
                                               object:nil];
    semaphore = dispatch_semaphore_create(0);
    [sut view];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

    assertThatBool(weatherDataLoaded, equalToBool(YES));
    assertThatBool(forecastDataLoaded, equalToBool(YES));
}




@end
