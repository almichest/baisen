//
//  CRUtility.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/01.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRUtility.h"
#import "CRConfiguration.h"

@implementation CRUtility

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

NSInteger roastLengthFromValue(NSTimeInterval seconds)
{
    if([CRConfiguration sharedConfiguration].useMinutesForHeatingLength) {
        return (seconds / 60);
    } else {
        return seconds;
    }
}

NSTimeInterval secondRoastLengthFromValue(NSTimeInterval value)
{
    if([CRConfiguration sharedConfiguration].useMinutesForHeatingLength) {
        return value * 60;
    } else {
        return value;
    }
}

@end
