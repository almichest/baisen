//
//  CRMainViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRMainViewController.h"
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"
#import "CRConfiguration.h"

#define kCloudNotificationAlertViewTag  10 
#define kCloudUnavailableAlertViewTag   11

@interface CRMainViewController ()<CRRoastDataSourceSettingDelegate, UIAlertViewDelegate>

@end

@implementation CRMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CRRoastManager sharedManager].dataSource.settingDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if(![CRConfiguration sharedConfiguration].iCloudConfigured) {
        [self showiCloudConfirmationAlertView];
    } else {
        BOOL useCloud = [CRConfiguration sharedConfiguration].iCloudAvailable;
        [[CRRoastManager sharedManager].dataSource refreshToUseCloud:useCloud];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [CRRoastManager sharedManager].dataSource.settingDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InitialLoadingDelegate
- (void)dataSourceDidBecomeAvailable:(CRRoastDataSource *)dataSource
{
    [self transitToNextView];
}


- (void)dataSourceCannotUseCloud:(CRRoastDataSource *)dataSource
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"iCloudUnavailable", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    alertView.tag = kCloudUnavailableAlertViewTag;
    [alertView show];
}

- (void)showiCloudConfirmationAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UseiCloud", nil) message:NSLocalizedString(@"UsingiCloudNotification", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alertView.tag = kCloudNotificationAlertViewTag;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kCloudNotificationAlertViewTag :
            [self handleCloudAlertViewSelectionWithButtonIndex:buttonIndex];
            break;
        case kCloudUnavailableAlertViewTag :
            [self handleCloudUnavailableAlertViewDismissed];
            break;
        default :
            break;
    }
}

#pragma mark - AlertView next action
- (void)handleCloudAlertViewSelectionWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0 :
            [[CRRoastManager sharedManager].dataSource refreshToUseCloud:NO];
            break;
        case 1 :
            [[CRRoastManager sharedManager].dataSource refreshToUseCloud:YES];
            break;
        default :
            break;
    }
    [CRConfiguration sharedConfiguration].iCloudConfigured = YES;
}

- (void)handleCloudUnavailableAlertViewDismissed
{
    [self transitToNextView];
}

- (void)transitToNextView
{
    [CRConfiguration sharedConfiguration].iCloudConfigured = YES;
    [self performSegueWithIdentifier:@"loadingComplete" sender:nil];
}

@end
