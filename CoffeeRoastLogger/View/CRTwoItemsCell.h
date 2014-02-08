//
//  CRBeanCell.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/28.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRTwoItemsCellButton;
@interface CRTwoItemsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CRTwoItemsCellButton *button;
@property (weak, nonatomic) IBOutlet UITextField *firstItemField;
@property (weak, nonatomic) IBOutlet UITextField *secondItemField;

@property (weak, nonatomic) IBOutlet UIButton *firstItemFieldButton;
@property (weak, nonatomic) IBOutlet UIButton *secondItemFieldButton;


@end

