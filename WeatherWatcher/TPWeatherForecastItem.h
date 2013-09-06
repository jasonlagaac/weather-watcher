//
//  TPWeatherForecastItem.h
//  WeatherWatcher
//
//  Created by Jason Lagaac on 6/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPWeatherForecastItem : UIView

@property (nonatomic, strong) IBOutlet UIImageView *weatherIcon;
@property (nonatomic, strong) IBOutlet UILabel *temperature;
@property (nonatomic, strong) IBOutlet UILabel *day;


@end
