//
//  CRRoastItemCell.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/05.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRRoastItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *beansNameLabel;

@end
