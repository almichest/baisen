//
//  CREnvironmentInformation.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CREnvironmentInformation.h"
#import "CRTypes.h"

@implementation CREnvironmentInformation

- (instancetype)init
{
    self = [super init];
    if(self) {
        _humidity = kHumidityDefaultValue;
        _temperature = kRoomTemperatureDefaultValue;
    }
    return self;
}
@end
