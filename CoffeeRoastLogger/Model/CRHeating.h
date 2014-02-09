//
//  CRHeating.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/10.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRRoast;

@interface CRHeating : NSManagedObject

@property (nonatomic) float temperature;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) int16_t index;
@property (nonatomic, retain) CRRoast *roast;

@end
