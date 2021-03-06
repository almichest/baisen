//
//  CRRoast.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/11.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoast.h"
#import "CRBean.h"
#import "CREnvironment.h"
#import "CRHeating.h"


@implementation CRRoast

@dynamic imageData;
@dynamic result;
@dynamic score;
@dynamic beans;
@dynamic environment;
@dynamic heating;

- (NSString *)scoreDescription
{
    if(self.score == INT16_MIN) {
        return NSLocalizedString(@"NotInput", nil);
    } else {
        return [NSString stringWithFormat:@"%d", self.score];
    }
}

@end
