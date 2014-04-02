//
//  CRSelectedPhotoViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/03.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRSelectedPhotoViewController.h"

@interface CRSelectedPhotoViewController ()

@end

@implementation CRSelectedPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ALAssetRepresentation *assetRepresentation = [self.selectedAsset defaultRepresentation];
    self.selectedPhotoImageView.image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:UIImageOrientationUp];
       UIBarButtonItem *submitButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(didPushSubmitButton:)];
    self.navigationItem.rightBarButtonItem = submitButtonItem;
}

- (void)didPushSubmitButton:(UIBarButtonItem *)button
{
    UIImage *image = self.selectedPhotoImageView.image;
    [[NSNotificationCenter defaultCenter] postNotificationName:CRSelectedPhotoViewControllerPhotoSelectNotification
                                                        object:nil
                                                      userInfo:@{CRSelectedPhotoViewControllerPhotoSelectNotificationKeyPhoto : image}];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

NSString *const CRSelectedPhotoViewControllerPhotoSelectNotification = @"CRSelectedPhotoViewControllerPhotoSelectNotification";
NSString *const CRSelectedPhotoViewControllerPhotoSelectNotificationKeyPhoto = @"CRSelectedPhotoViewControllerPhotoSelectNotificationKeyPhoto";
