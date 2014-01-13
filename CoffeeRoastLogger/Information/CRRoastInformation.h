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

@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) CRBeanInformation *bean;
@property (nonatomic, retain) CREnvironmentInformation *environment;
@property (nonatomic, retain) NSArray *heatingInformations;

@end
