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

NSInteger const maximumForecastItems = 5;

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
        [self initialiseForecastItems];
        self.weather = [[TPWeather alloc] init];
    }
    return self;
}

- (void)dealloc
{
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
    
    for (int i = 0; i < maximumForecastItems; i++) {
        TPWeatherForecastItem *forecast = [[[NSBundle mainBundle] loadNibNamed:@"TPWeatherForecastItem"
                                                                         owner:self
                                                                       options:nil] objectAtIndex:0];        
        [self.forecastItems addObject:forecast];
    }
}

- (void)drawForecast
{
    for (int i = 0; i < maximumForecastItems; i++) {
        TPWeatherForecastItem *item = [self.forecastItems objectAtIndex:i];
        CGRect newItemFrame = item.frame;
        newItemFrame.origin = CGPointMake(newItemFrame.size.width * i, newItemFrame.origin.y);
        item.frame = newItemFrame;
        
        [self.fiveDayForecast addSubview:item];
    }
}


@end
