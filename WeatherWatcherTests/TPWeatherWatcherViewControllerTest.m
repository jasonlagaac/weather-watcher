
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
}

- (void)setUp
{
    [super setUp];
    sut = [[TPWeatherWatcherViewController alloc] initWithNibName:@"TPWeatherWatcher"
                                                           bundle:nil];
    
    [sut view];
}

- (void)tearDown
{
    [super tearDown];
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
    assertThat(sut.currentLocationName.text, equalTo(@"NEW YORK"));
}

- (void)testTemperatureLabelShouldBeConnected
{
    assertThat(sut.temperature, notNilValue());
}

- (void)testTemperatureLabelShouldHaveATemperatureValue
{
    assertThat(sut.temperature.text, equalTo(@"9000"));
}

- (void)testFiveDayForecastAreaShouldBeConnected
{
    assertThat(sut.fiveDayForecast, notNilValue());
}





@end
