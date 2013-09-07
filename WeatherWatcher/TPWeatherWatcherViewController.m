//
//  TPWeatherViewController.m
//  WeatherWatcher
//
//  Created by Jason Lagaac on 6/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import "TPWeatherWatcherViewController.h"
#import "TPWeatherForecastItem.h"
#import "TPWeather.h"

// Convert an API image code to a localised version
UIImage* APIImageToLocalImage(NSString *apiImageName)
{
    NSString *imageName;
    
    if ([apiImageName isEqualToString:@"01d"] || [apiImageName isEqualToString:@"01n"]) {
        imageName = @"Clear.png";
    } else if ([apiImageName isEqualToString:@"02d"] || [apiImageName isEqualToString:@"02n"] ||
               [apiImageName isEqualToString:@"03d"] || [apiImageName isEqualToString:@"03n"] ||
               [apiImageName isEqualToString:@"04d"] || [apiImageName isEqualToString:@"04n"]) {
        imageName = @"Cloud.png";
    } else if ([apiImageName isEqualToString:@"09d"] || [apiImageName isEqualToString:@"09n"] ||
               [apiImageName isEqualToString:@"10d"] || [apiImageName isEqualToString:@"10n"]) {
        imageName = @"Rain.png";
    } else if ([apiImageName isEqualToString:@"11d"] || [apiImageName isEqualToString:@"11n"]) {
        imageName = @"Storm.png";
    } else if ([apiImageName isEqualToString:@"13d"] || [apiImageName isEqualToString:@"13n"]) {
        imageName = @"Snow.png";
    } else if ([apiImageName isEqualToString:@"50d"] || [apiImageName isEqualToString:@"50n"]) {
        imageName = @"Fog.png";
    }
    
    return [UIImage imageNamed:imageName];
}

// Colours related to temperature
UIColor* colorForTemperature(float temperature)
{
    UIColor *temperatureColour;
    
    if (temperature < 0) {
        temperatureColour = [UIColor colorWithRed:(143.0f/255.0f)
                                           green:(225.0f/255.0f)
                                            blue:(235.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 0 && temperature < 10) {
        temperatureColour =  [UIColor colorWithRed:(51.0f/255.0f)
                                            green:(175.0f/255.0f)
                                             blue:(198.0f/255.0f)
                                            alpha:1.0f];
    } else if (temperature > 10 && temperature < 20) {
        temperatureColour = [UIColor colorWithRed:(94.0f/255.0f)
                                           green:(230.0f/255.0f)
                                            blue:(189.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 20 && temperature < 30) {
        temperatureColour = [UIColor colorWithRed:(105.0f/255.0f)
                                           green:(230.0f/255.0f)
                                            blue:(189.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 30 && temperature < 40) {
        temperatureColour = [UIColor colorWithRed:(227.0f/255.0f)
                                           green:(227.0f/255.0f)
                                            blue:(25.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 40 && temperature < 50) {
        temperatureColour = [UIColor colorWithRed:(217.0f/255.0f)
                                           green:(141.0f/255.0f)
                                            blue:(20.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 50) {
        temperatureColour = [UIColor colorWithRed:(191.0f/255.0f)
                                           green:(36.0f/255.0f)
                                            blue:(36.0f/255.0f)
                                           alpha:1.0f];
    }
    
    return temperatureColour;
}

@interface TPWeatherWatcherViewController ()
@property (nonatomic, strong) NSMutableArray *forecastItems;
@property (nonatomic, strong) TPWeather *weather;
@end

@implementation TPWeatherWatcherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.weather = [[TPWeather alloc] init];
        [self initialiseForecastItems];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(weatherLoaded:)
                                                     name:kTPWeatherNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(forecastLoaded:)
                                                     name:kTPFiveDayForecastNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.forecastItems = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.weather startMonitoringLocation];
    [self drawForecast];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialiseForecastItems
{
    self.forecastItems = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < kTPMaxForecastItems; i++) {
        TPWeatherForecastItem *forecast = [[[NSBundle mainBundle] loadNibNamed:@"TPWeatherForecastItem"
                                                                         owner:self
                                                                       options:nil] objectAtIndex:0];        
        [self.forecastItems addObject:forecast];
    }
}

- (void)drawForecast
{
    for (int i = 0; i < kTPMaxForecastItems; i++) {
        TPWeatherForecastItem *item = [self.forecastItems objectAtIndex:i];
        CGRect newItemFrame = item.frame;
        newItemFrame.origin = CGPointMake(newItemFrame.size.width * i, newItemFrame.origin.y);
        item.frame = newItemFrame;
        
        [self.fiveDayForecast addSubview:item];
    }
}



#pragma mark - Notification Handlers
////////////////////////////////////////////////////////////////////////////////

- (void)weatherLoaded:(NSNotification *)notification
{
    NSDictionary *currentForecast = [notification object];
    float currentTemperature = [[[currentForecast objectForKey:@"main"] objectForKey:@"temp_max"] floatValue];
    self.temperature.text = [NSString stringWithFormat:@"%0.1f", currentTemperature];
 
    NSString *apiWeatherImageName = [[[currentForecast objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
    UIImage *weatherImage = APIImageToLocalImage(apiWeatherImageName);
    self.weatherStateIcon.image = weatherImage;
    
    NSLog(@"Weather Loaded: %f", currentTemperature);
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.backgroundColor = colorForTemperature(currentTemperature);
                     }];
}

- (void)forecastLoaded:(NSNotification *)notification
{
    NSLog(@"Forecast Loaded: %@", NSStringFromClass ([[notification object] class]));
    NSLog(@"Forecast Loaded: %@", [notification object]);

    NSArray *forecastData = [[notification object] objectForKey:@"list"];
    
    for (int i = 0; i < kTPMaxForecastItems; i++)
    {
        TPWeatherForecastItem *forecastItem = [self.forecastItems objectAtIndex:i];
        NSDictionary *forecast = [forecastData objectAtIndex:i];
        float temperature = [[[forecast objectForKey:@"temp"] objectForKey:@"max"] floatValue];
        forecastItem.temperature.text = [NSString stringWithFormat:@"%0.1f", temperature];
        
        NSString *weatherIconName = [[[forecast objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
        forecastItem.weatherIcon.image = APIImageToLocalImage(weatherIconName);
        
        // Set the forecast day
        NSTimeInterval epochTime = [[forecast objectForKey:@"dt"] doubleValue];
        NSDate *date =[[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE"];
        NSLog(@"Loaded Date: %@", [formatter stringFromDate:date]);

        forecastItem.day.text = [[formatter stringFromDate:date] uppercaseString];
    }
}

@end
