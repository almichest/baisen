//
//  CREnvironment.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRRoast;

@interface CREnvironment : NSManagedObject

@property (nonatomic) float humidity;
@property (nonatomic) float temperature;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) CRRoast *roast;

@end
