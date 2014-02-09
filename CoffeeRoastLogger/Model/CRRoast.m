//
//  CRRoast.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/02.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoast.h"
#import "CRBean.h"
#import "CREnvironment.h"
#import "CRHeating.h"


@implementation CRRoast

@dynamic result;
@dynamic score;
@dynamic imageData;
@dynamic beans;
@dynamic environment;
@dynamic heating;

- (CRHeating *)heatingAtIndex:(NSUInteger)index
{
    if(index > self.heating.count) {
        return nil;
    }
    for(CRHeating *heating in self.heating) {
        if(heating.index == index) {
            return heating;
        }
    }
    
    return nil;
}

@end
