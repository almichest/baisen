//
//  CREnvironment.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/11.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CREnvironment.h"
#import "CRRoast.h"
#import "CRUtility.h"
#import "CRTypes.h"

@implementation CREnvironment

@dynamic date;
@dynamic humidity;
@dynamic temperature;
@dynamic roast;

- (NSString *)temperatureDescription
{
    if(self.temperature == kRoomTemperatureDefaultValue) {
        return NSLocalizedString(@"NotInput", nil);
    } else {
        return [NSString stringWithFormat:@"%.0f", roomTempratureFromValue(self.temperature)];
    }
}

- (NSString *)humidityDescription
{
    if(self.humidity == kHumidityDefaultValue) {
        return NSLocalizedString(@"NotInput", nil);
    } else {
        return [NSString stringWithFormat:@"%.0f", self.humidity];
    }
}

@end
