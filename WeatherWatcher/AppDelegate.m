//
//  AppDelegate.m
//  WeatherWatcher
//
//  Created by Jason Lagaac on 5/09/13.
//  Copyright (c) 2013 Jason Lagaac. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFHTTPClient.h>
#import "TPWeatherWatcherViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) AFHTTPClient *reachabilityClient;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[TPWeatherWatcherViewController alloc] initWithNibName:@"TPWeatherWatcher"
                                                                                      bundle:nil];
    [self.window makeKeyAndVisible];
    
    // Setup a general reachability handler
    self.reachabilityClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.google.com"]];
    [self.reachabilityClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            // Not reachable
            [[NSNotificationCenter defaultCenter] postNotificationName:kTPNetworkUnavailable
                                                                object:nil];
        } else {
            // Reachable
            [[NSNotificationCenter defaultCenter] postNotificationName:kTPNetworkAvailable
                                                                object:nil];
        }
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
