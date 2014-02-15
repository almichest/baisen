//
//  CRHeatingInformation.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRHeatingInformation.h"
#import "CRTypes.h"

@implementation CRHeatingInformation

- (instancetype)init
{
    self = [super init];
    if(self) {
        _temperature = kHeatingTemperatureDefaultValue;
    }
    
    return self;
}

@end
