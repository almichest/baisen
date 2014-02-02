//
//  CRUtility.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/01.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRUtility.h"

@implementation CRUtility

NSString *dateStringFromNSDate(NSDate *date)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = @"YYYY/MM/dd HH:mm";
    return [formatter stringFromDate:date];
}
@end
