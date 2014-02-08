//
//  CRResultItemCell.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/08.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRResultItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *separetorView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end
