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
    } else if (temperature > 0 && temperature < 15) {
        temperatureColour =  [UIColor colorWithRed:(51.0f/255.0f)
                                            green:(175.0f/255.0f)
                                             blue:(198.0f/255.0f)
                                            alpha:1.0f];
    } else if (temperature > 15 && temperature < 25) {
        temperatureColour = [UIColor colorWithRed:(94.0f/255.0f)
                                           green:(230.0f/255.0f)
                                            blue:(189.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 25 && temperature < 35) {
        temperatureColour = [UIColor colorWithRed:(105.0f/255.0f)
                                           green:(230.0f/255.0f)
                                            blue:(189.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 35 && temperature < 45) {
        temperatureColour = [UIColor colorWithRed:(227.0f/255.0f)
                                           green:(227.0f/255.0f)
                                            blue:(25.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 45 && temperature < 55) {
        temperatureColour = [UIColor colorWithRed:(217.0f/255.0f)
                                           green:(141.0f/255.0f)
                                            blue:(20.0f/255.0f)
                                           alpha:1.0f];
    } else if (temperature > 55) {
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
@property (nonatomic) BOOL weatherLoaded;
@property (nonatomic) BOOL forecastLoaded;
@property (nonatomic) BOOL locationNameLoaded;
@end

@implementation TPWeatherWatcherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.weather = [[TPWeather alloc] init];
        [self initialiseForecastItems];
        
        self.weatherLoaded = NO;
        self.forecastLoaded = NO;
        self.locationNameLoaded = NO;

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(weatherLoaded:)
                                                     name:kTPWeatherNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(forecastLoaded:)
                                                     name:kTPFiveDayForecastNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationNameLoaded:)
                                                     name:kTPReverseGeocodingNotification
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
    
    // Determine screen layout if it is a 3.5 inch screen.
    if (!IS_4INCH_SCREEN) {
        [self layoutInterface];
    }
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

#pragma mark - Interface Layout Actions
////////////////////////////////////////////////////////////////////////////////

- (void)layoutInterface {
    self.currentLocationName.center = CGPointMake(self.currentLocationName.center.x, self.currentLocationName.center.y - 25.0f);
    self.fiveDayForecast.center = CGPointMake(self.fiveDayForecast.center.x, self.fiveDayForecast.center.y - 65.0f);
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


#pragma mark - Element Load Actions
////////////////////////////////////////////////////////////////////////////////

- (void)reloadElements
{
    if (self.weatherLoaded && self.locationNameLoaded && self.locationNameLoaded)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             // Fade out first if visible
                             self.fiveDayForecast.alpha = 1.0f;
                             self.currentLocationName.alpha = 1.0f;
                             self.temperature.alpha = 1.0f;
                             self.weatherStateIcon.alpha = 1.0f;
                             self.menuButton.alpha = 1.0f;
                         } completion:^(BOOL finished) {
                             self.locationNameLoaded = NO;
                             self.weatherLoaded = NO;
                             self.forecastLoaded = NO;
                         }];
    }
}


#pragma mark - Notification Handlers
////////////////////////////////////////////////////////////////////////////////

- (void)weatherLoaded:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         // Fade out first if visible
                         self.temperature.alpha = 0.0f;
                         self.weatherStateIcon.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         NSDictionary *currentForecast = [notification object];
                         float currentTemperature = [[[currentForecast objectForKey:@"main"] objectForKey:@"temp_max"] floatValue];
                         self.temperature.text = [NSString stringWithFormat:@"%0.1f", currentTemperature];
                         
                         NSString *apiWeatherImageName = [[[currentForecast objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
                         UIImage *weatherImage = APIImageToLocalImage(apiWeatherImageName);
                         self.weatherStateIcon.image = weatherImage;                         
                         self.weatherLoaded = YES;
                         
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.mainContent.backgroundColor = colorForTemperature(currentTemperature);
                                          } completion:^(BOOL finished) {
                                              [self reloadElements];
                                          }];
                         
                         
                     }];
    
}


- (void)forecastLoaded:(NSNotification *)notification
{
    NSArray *forecastData = [[notification object] objectForKey:@"list"];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         // Fade out first if visible
                         self.fiveDayForecast.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         
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
                             
                             forecastItem.day.text = [[formatter stringFromDate:date] uppercaseString];
                             self.forecastLoaded = YES;                             
                             [self reloadElements];
                         }
                     }];
}

- (void)locationNameLoaded:(NSNotification *)notification
{
    NSLog(@"Location Name Loaded");
    [UIView animateWithDuration:1.0f
                     animations:^{
                         // Fade out first if visible
                         self.currentLocationName.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         self.currentLocationName.text = [[notification object] uppercaseString];
                         self.locationNameLoaded = YES;
                         [self reloadElements];
                     }];
}



#pragma mark - Interface Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)presentMenu:(id)sender
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         if (self.mainContent.center.x == 160.0f) {
                             self.mainContent.center = CGPointMake(400.0f, self.mainContent.center.y);
                         } else {
                             self.mainContent.center = CGPointMake(160.0f, self.mainContent.center.y);
                         }
                     }];
}


#pragma mark - Table Data Source
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weather.existingLocations.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *existingLocation = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.textColor = [UIColor whiteColor];

    switch (indexPath.row ) {
        case 0:
            cell.textLabel.text = @"Current Location";
            break;
        default:
            existingLocation = [self.weather.existingLocations objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = [existingLocation objectForKey:@"name"];
    }
    
    return cell;
}


#pragma mark - Table Delegate Actions
////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *location;
    
    switch (indexPath.row) {
        case 0:
            // Load weather for the current location
            [self.weather startMonitoringLocation];
            break;
            
        default:
            // Load weather based on existing default location
            location = [[self.weather existingLocations] objectAtIndex:indexPath.row - 1];
            [self.weather stopMonitoringLocation];
            
            [self.weather retrieveWeatherAtLatitude:[[location objectForKey:@"latitude"] doubleValue]
                                          longitude:[[location objectForKey:@"longitude"] doubleValue]];
            [self.weather retrieveFiveDayWeatherForecastAtLatitude:[[location objectForKey:@"latitude"] doubleValue]
                                                         longitude:[[location objectForKey:@"longitude"] doubleValue]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTPReverseGeocodingNotification
                                                                object:[location objectForKey:@"name"]];
            break;
    }
}





@end
