//
//  CRHeating.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/11.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRHeating.h"
#import "CRRoast.h"
#import "CRUtility.h"
#import "CRTypes.h"

@implementation CRHeating

@dynamic temperature;
@dynamic time;
@dynamic roast;

- (NSString *)temperatureDescription
{
    if(self.temperature == kHeatingTemperatureDefaultValue) {
        return NSLocalizedString(@"NotInput", nil);
    } else {
        return [NSString stringWithFormat:@"%.0f", roastTempratureFromValue(self.temperature)];
    }
}

@end
