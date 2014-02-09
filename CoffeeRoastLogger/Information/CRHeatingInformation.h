//
//  CRHeatingInformation.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRHeatingInformation : NSObject

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSUInteger index;
@property (nonatomic) float temperature;

@end
