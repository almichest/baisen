//
//  CRRoastManager.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRRoast;
@class CRRoastInformation;
@class CRRoastDataSource;
@protocol CRRoastManagerDelegate;
@interface CRRoastManager : NSObject

@property(nonatomic, weak) id<CRRoastManagerDelegate> delegate;
@property(nonatomic, readonly) CRRoastDataSource *dataSource;

+ (CRRoastManager *)sharedManager;

- (CRRoast *)addNewRoastInformation:(CRRoastInformation *)information;
- (CRRoast *)updateRoastItem:(CRRoast *)roast withRoastInformation:(CRRoastInformation *)information;
- (void)removeRoastInformationAtIndex:(NSUInteger)index;

@end

@protocol CRRoastManagerDelegate <NSObject>

- (void)managerDidFailSavingWithError:(NSError *)error;

@end