//
//  CRRoastInformation.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRBeanInformation;
@class CREnvironmentInformation;
@interface CRRoastInformation : NSObject

@property (nonatomic) NSString *result;

@property (nonatomic) NSInteger score;

/** Array of CRBeanInformation */
@property (nonatomic) NSArray *beans;

@property (nonatomic) CREnvironmentInformation *environment;

/** Array of CRHeatingInformation */
@property (nonatomic) NSArray *heatingInformations;

@end
