//
//  CRImageRootViewCell.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/02.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRImageRootViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *folderNameLabel;

@end
