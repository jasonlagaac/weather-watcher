//
//  TPWeatherViewController.h
//  WeatherWatcher
//
//  Created by Jason Lagaac on 6/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPWeatherWatcherViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UIImageView *weatherStateIcon;
@property (nonatomic, strong) IBOutlet UILabel *currentLocationName;
@property (nonatomic, strong) IBOutlet UILabel *temperature;
@property (nonatomic, strong) IBOutlet UIView *fiveDayForecast;
@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIView *mainContent;
@property (nonatomic, strong) IBOutlet UITableView *locationListTable;

- (IBAction)presentMenu:(id)sender;

@end
