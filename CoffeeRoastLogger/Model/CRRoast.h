//
//  CRRoast.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/15.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRBean, CREnvironment, CRHeating;

@interface CRRoast : NSManagedObject

@property (nonatomic, retain) NSString * result;
@property (nonatomic) int16_t score;
@property (nonatomic, retain) NSSet *beans;
@property (nonatomic, retain) CREnvironment *environment;
@property (nonatomic, retain) NSSet *heating;
@end

@interface CRRoast (CoreDataGeneratedAccessors)

- (void)addBeansObject:(CRBean *)value;
- (void)removeBeansObject:(CRBean *)value;
- (void)addBeans:(NSSet *)values;
- (void)removeBeans:(NSSet *)values;

- (void)addHeatingObject:(CRHeating *)value;
- (void)removeHeatingObject:(CRHeating *)value;
- (void)addHeating:(NSSet *)values;
- (void)removeHeating:(NSSet *)values;

@end
