//
//  CRHeating.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRRoast;

@interface CRHeating : NSManagedObject

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) float temperature;
@property (nonatomic, retain) CRRoast *roast;

@end
