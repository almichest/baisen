//
//  CRAlbumContentsViewController.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/02.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@interface CRAlbumContentsViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
