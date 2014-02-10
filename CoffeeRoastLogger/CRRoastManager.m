//
//  CRRoastManager.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastManager.h"

#import "CRRoastDataSource.h"
#import "CRRoastInformation.h"

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

- (instancetype)init
{
    self = [super init];
    if(self) {
        _dataSource = [[CRRoastDataSource alloc] init];
    }
    
    return self;
}

- (CRRoast *)addNewRoastInformation:(CRRoastInformation *)information;
{
    return [_dataSource addRoastInformation:information];
}

- (CRRoast *)updateRoastItem:(CRRoast *)roast withRoastInformation:(CRRoastInformation *)information
{
    return [_dataSource updateRoastItem:roast withRoastInformation:information];
}

- (void)removeRoastInformationAtIndex:(NSUInteger)index;
{
    [_dataSource removeRoastInformationAtIndex:index];
}

@end
