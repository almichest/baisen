//
//  CRNewItemViewController.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/01/26.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRRoast;
@interface CRRoastItemEditingViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *completeButton;

@property (nonatomic) CRRoast *roastItem;

@end
