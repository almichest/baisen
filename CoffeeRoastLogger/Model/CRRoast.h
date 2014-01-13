//
//  CRRoast.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRBean, CREnvironment, CRHeating;

@interface CRRoast : NSManagedObject

@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) CRBean *bean;
@property (nonatomic, retain) CREnvironment *environment;
@property (nonatomic, retain) NSSet *heating;
@end

@interface CRRoast (CoreDataGeneratedAccessors)

- (void)addHeatingObject:(CRHeating *)value;
- (void)removeHeatingObject:(CRHeating *)value;
- (void)addHeating:(NSSet *)values;
- (void)removeHeating:(NSSet *)values;

@end
