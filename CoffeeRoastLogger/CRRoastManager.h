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
@interface CRRoastManager : NSObject

+ (CRRoastManager *)sharedManager;

- (CRRoast *)addNewRoastInformation:(CRRoastInformation *)information;
- (void)removeRoastInformationAtIndex:(NSUInteger)index;
- (void)saveRoastRecords;

@end
