//
//  TPWeatherWatcherMenuViewController.h
//  WeatherWatcher
//
//  Created by Jason Lagaac on 8/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPWeatherWatcherMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *locationListTable;

@end
