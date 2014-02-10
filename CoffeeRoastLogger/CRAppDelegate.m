//
//  CRAppDelegate.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRAppDelegate.h"
#import "CRRoastManager.h"
#import "CRRoastInformation.h"
#import "CRRoast.h"

#import "CRMasterViewController.h"

static NSString *const iCloudUseKey = @"iCloudUse";

@interface CRAppDelegate()<UIAlertViewDelegate>

@end

@implementation CRAppDelegate

- (instancetype)init
{
    self = [super init];
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [self iCloudToken];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
//        [store setLongLong:1000 forKey:@"hoge"];
//        [store synchronize];
//    });
    return YES;
}

- (void)iCloudToken
{
    BOOL iCloudAvailavleAtFirstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:iCloudUseKey];
    id iCloudCurrentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if(iCloudCurrentToken) {
        NSData *newTOken = [NSKeyedArchiver archivedDataWithRootObject:iCloudCurrentToken];
        
        [[NSUserDefaults standardUserDefaults] setObject:newTOken forKey:@"com.hira.coffee.logger"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudAccountAvailabilityChanged:) name:NSUbiquityIdentityDidChangeNotification object:nil];
        if(iCloudAvailavleAtFirstLaunch) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Choose Storage Option" message:@"Use iCloud Storage ?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            
            [alertView show];
        };
        
    } else {
        [self initializeiCloud];
    }
}

- (void)initializeiCloud
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]) {
            MyLog(@"iCloud is available");
        } else {
            MyLog(@"iCloud is not available");
        }
    });
}

- (void)iCloudAccountAvailabilityChanged:(NSNotification *)notification
{
    id iCloudCurrentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if(iCloudCurrentToken) {
        NSData *newToken = [NSKeyedArchiver archivedDataWithRootObject:iCloudCurrentToken];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0 :
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:iCloudUseKey];
            [self initializeiCloud];
            break;
        case 1 :
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:iCloudUseKey];
    }
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
    // Saves changes in the application's managed object context before the application terminates.
}

@end
