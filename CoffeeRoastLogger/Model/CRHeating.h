//
//  CRHeating.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/11.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRRoast;

@interface CRHeating : NSManagedObject

@property (nonatomic) float temperature;
@property (nonatomic) int16_t time;
@property (nonatomic, retain) CRRoast *roast;

@end
