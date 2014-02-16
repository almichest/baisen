//
//  CRDateEditingViewController.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/28.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRDateEditingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property(nonatomic, copy) void (^completion)(NSDate *date);

@end
