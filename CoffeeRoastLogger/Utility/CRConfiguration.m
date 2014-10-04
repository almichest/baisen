//
//  CRConfiguration.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/09.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRConfiguration.h"

#define kRoomFahrenheitKey      @"roomFahrenheit"
#define kRoastFahrenheitKey     @"roastFahrenheit"
#define kRoastUnitMinutesKey    @"roastUnitMinutes"
#define kICloudKey              @"useICloud"
#define kICloudConfiguredKey    @"iCloudConfigured"

@implementation CRConfiguration
@dynamic useFahrenheitForRoom;
@dynamic useFahrenheitForRoast;

static CRConfiguration *_sharedConfiguration;
+ (CRConfiguration *)sharedConfiguration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[CRConfiguration alloc] initPrivate];
    });
    
    return _sharedConfiguration;
}

- (instancetype)init
{
    NSException *exception = [[NSException alloc] initWithName:NSStringFromClass(self.class) reason:@"Singleton" userInfo:nil];
    @throw exception;
    return nil;
}

- (instancetype)initPrivate
{
    return [super init];
}

- (BOOL)useFahrenheitForRoom
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRoomFahrenheitKey];
}

- (void)setUseFahrenheitForRoom:(BOOL)useFahrenheitForRoom
{
    [[NSUserDefaults standardUserDefaults] setBool:useFahrenheitForRoom forKey:kRoomFahrenheitKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:CRConfigurationRoomTempratureUnitDidChangeNotification object:nil];
}

- (BOOL)useFahrenheitForRoast
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRoastFahrenheitKey];
}

- (void)setUseFahrenheitForRoast:(BOOL)useFahrenheitForRoast
{
    [[NSUserDefaults standardUserDefaults] setBool:useFahrenheitForRoast forKey:kRoastFahrenheitKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:CRConfigurationRoastTempratureUnitDidChangeNotification object:nil];
}

- (BOOL)useMinutesForHeatingLength
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRoastUnitMinutesKey];
}

- (void)setUseMinutesForHeatingLength:(BOOL)useMinitesForHeatingLength
{
    [[NSUserDefaults standardUserDefaults] setBool:useMinitesForHeatingLength forKey:kRoastUnitMinutesKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:CRConfigurationRoastLengthUnitDidChangeNotification object:nil];
}

- (BOOL)iCloudAvailable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kICloudKey];
}

- (void)setICloudAvailable:(BOOL)iCloudAvailable
{
    [[NSUserDefaults standardUserDefaults] setBool:iCloudAvailable forKey:kICloudKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:CRConfigurationiClundAvailabilityDidChangeNotification object:nil];
}

- (BOOL)iCloudConfigured
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kICloudConfiguredKey];
}

- (void)setICloudConfigured:(BOOL)iCloudConfigured
{
    [[NSUserDefaults standardUserDefaults] setBool:iCloudConfigured forKey:kICloudConfiguredKey];
}

@end

NSString *const CRConfigurationRoomTempratureUnitDidChangeNotification = @"CRConfigurationRoomTempratureUnitDidChangeNotification";
NSString *const CRConfigurationRoastTempratureUnitDidChangeNotification = @"CRConfigurationRoastTempratureUnitDidChangeNotification";

NSString *const CRConfigurationRoastLengthUnitDidChangeNotification = @"CRConfigurationRoastLengthUnitDidChangeNotification";

NSString *const CRConfigurationiClundAvailabilityDidChangeNotification = @"CRConfigurationiCloudAvailabilityDidChangeNotification";
