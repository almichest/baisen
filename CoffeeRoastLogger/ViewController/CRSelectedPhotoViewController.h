//
//  CRSelectedPhotoViewController.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/03.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CRSelectedPhotoViewController : UIViewController

@property (nonatomic) ALAsset *selectedAsset;
@property (weak, nonatomic) IBOutlet UIImageView *selectedPhotoImageView;

@end

extern NSString *const CRSelectedPhotoViewControllerPhotoSelectNotification;
extern NSString *const CRSelectedPhotoViewControllerPhotoSelectNotificationKeyPhoto;
