//
//  CRDatePickerAlertView.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/04.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRDatePickerAlertView.h"

@implementation CRDatePickerAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    [self addSubview:picker];
}

@end
