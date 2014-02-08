//
//  CRConfiguration.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/09.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRConfiguration : NSObject

+ (CRConfiguration *)sharedConfiguration;

@property(nonatomic) BOOL useFahrenheitForRoom;
@property(nonatomic) BOOL useFahrenheitForRoast;

@property(nonatomic) BOOL useMinutesForHeatingLength;

@end
