//
//  CRRoastManager.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastManager.h"

@implementation CRRoastManager
static CRRoastManager *_sharedManager;

+ (CRRoastManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CRRoastManager alloc] init];
    });
    
    return _sharedManager;
}

@end
