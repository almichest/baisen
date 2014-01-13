//
//  CRBean.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRRoast;

@interface CRBean : NSManagedObject

@property (nonatomic, retain) NSString * area;
@property (nonatomic) int16_t quantity;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) CRRoast *roast;

@end
