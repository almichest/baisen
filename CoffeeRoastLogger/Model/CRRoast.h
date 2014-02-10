//
//  CRRoast.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/10.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CRBean, CREnvironment, CRHeating;

@interface CRRoast : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * result;
@property (nonatomic) int16_t score;
@property (nonatomic, retain) NSSet *beans;
@property (nonatomic, retain) CREnvironment *environment;
@property (nonatomic, retain) NSOrderedSet *heating;
@end

@interface CRRoast (CoreDataGeneratedAccessors)

- (void)addBeansObject:(CRBean *)value;
- (void)removeBeansObject:(CRBean *)value;
- (void)addBeans:(NSSet *)values;
- (void)removeBeans:(NSSet *)values;

- (void)insertObject:(CRHeating *)value inHeatingAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHeatingAtIndex:(NSUInteger)idx;
- (void)insertHeating:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHeatingAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHeatingAtIndex:(NSUInteger)idx withObject:(CRHeating *)value;
- (void)replaceHeatingAtIndexes:(NSIndexSet *)indexes withHeating:(NSArray *)values;
- (void)addHeatingObject:(CRHeating *)value;
- (void)removeHeatingObject:(CRHeating *)value;
- (void)addHeating:(NSOrderedSet *)values;
- (void)removeHeating:(NSOrderedSet *)values;
@end
