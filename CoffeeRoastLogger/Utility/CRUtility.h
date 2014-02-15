//
//  CRUtility.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/01.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *dateStringFromNSDate(NSDate *date);

float roomTempratureFromValue(float celsius);
float roastTempratureFromValue(float celsius);

float celsiusRoomTempratureFromValue(float value);
float celsiusRoastTempratureFromValue(float value);

float roastLengthFromValue(NSTimeInterval seconds);
NSTimeInterval secondRoastLengthFromValue(float value);

NSArray *validBeanInformationsFromRawInformations(NSArray *infromations);
NSArray *validHeatingInformationsFromRawInformations(NSArray *infromations);
