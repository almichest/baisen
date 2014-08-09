//
//  CRUtility.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/01.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRUtility.h"
#import "CRTypes.h"
#import "CRConfiguration.h"
#import "CRHeatingInformation.h"
#import "CRBeanInformation.h"

NSString *dateStringFromNSDate(NSDate *date)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = @"YYYY/MM/dd HH:mm";
    return [formatter stringFromDate:date];
}

float roomTempratureFromValue(float celsius)
{
    if([CRConfiguration sharedConfiguration].useFahrenheitForRoom) {
        return (9.0f / 5.0f) * celsius + 32.0f;
    } else {
        return celsius;
    }
}

float roastTempratureFromValue(float celsius)
{
    if([CRConfiguration sharedConfiguration].useFahrenheitForRoast) {
        return (9.0f / 5.0f) * celsius + 32.0f;
    } else {
        return celsius;
    }
}

float celsiusRoomTempratureFromValue(float value)
{
    if([CRConfiguration sharedConfiguration].useFahrenheitForRoom) {
        return (5.0f / 9.0f) * (value - 32.0f);
    } else {
        return value;
    }
}

float celsiusRoastTempratureFromValue(float value)
{
    if([CRConfiguration sharedConfiguration].useFahrenheitForRoast) {
        return (5.0f / 9.0f) * (value - 32.0f);
    } else {
        return value;
    }
}

float roastLengthFromValue(NSTimeInterval seconds)
{
    if([CRConfiguration sharedConfiguration].useMinutesForHeatingLength) {
        return (seconds / 60.0f);
    } else {
        return seconds;
    }
}

NSTimeInterval secondRoastLengthFromValue(float value)
{
    if([CRConfiguration sharedConfiguration].useMinutesForHeatingLength) {
        return value * 60.0f;
    } else {
        return value;
    }
}

NSArray *validBeanInformationsFromRawInformations(NSArray *informations)
{
    NSMutableArray *mutableInformations = [[NSMutableArray alloc] initWithCapacity:informations.count];
    for(CRBeanInformation *information in informations) {
        if(information.area.length > 0) {
            [mutableInformations addObject:information];
        }
    }
    if(mutableInformations.count == 0) {
        CRBeanInformation *information = [[CRBeanInformation alloc] init];
        information.area = NSLocalizedString(@"NotInput", nil);
        information.quantity = 0;
        [mutableInformations addObject:information];
    }
    return mutableInformations.copy;
}

NSArray *validHeatingInformationsFromRawInformations(NSArray *informations)
{
    NSMutableArray *mutableInformations = [[NSMutableArray alloc] initWithCapacity:informations.count];
    for(CRHeatingInformation *information in informations) {
        if(information.temperature > 0) {
            [mutableInformations addObject:information];
        }
    }
    if(mutableInformations.count == 0) {
        CRHeatingInformation *information = [[CRHeatingInformation alloc] init];
        information.temperature = kHeatingTemperatureDefaultValue;
        information.time = 0;
        [mutableInformations addObject:information];
    }
    return mutableInformations.copy;
}
