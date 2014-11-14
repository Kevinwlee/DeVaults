//
//  AppDelegate.m
//  DeVaults
//
//  Created by Kevin Lee on 11/7/14.
//  Copyright (c) 2014 Kevin Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "CCHUserDefaults.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[ContextHub sharedInstance] setDebug:YES];
    [ContextHub registerWithAppId:@"64e074f5-ae48-4f13-834a-4e2cafe9a2fe"];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //Fetch Defaults using DeVaults Class
    [[CCHUserDefaults sharedInstance] fetchDefaultsWithCompletion:nil];
    
    return YES;
}

#pragma mark - Push Registration Callback

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[CCHPush sharedInstance] registerDeviceToken:deviceToken alias:@"kevin@chaione.com" tags:@[@"devault-user"] completionHandler:^(NSError *error) {
        NSLog(@"Registered For Push");
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did fail to register for push %@", error);
}

#pragma mark - Remote Notification

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[CCHPush sharedInstance] application:application didReceiveRemoteNotification:userInfo completionHandler:^(enum UIBackgroundFetchResult result, CCHContextHubPush *contextHubPush) {
        // Handle defaults in background
        [[CCHUserDefaults sharedInstance] updateDefaultsWithPush:contextHubPush completion:^{
            completionHandler(result);
        }];
        NSLog(@"Did get push %@", userInfo);
    }];
}

#pragma mark - Life Cycle

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
