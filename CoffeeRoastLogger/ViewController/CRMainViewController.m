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

@interface CRMainViewController ()<CRRoastDataSourceInitialLoadingDelegate>

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
    [CRRoastManager sharedManager].dataSource.initialLoadingDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InitialLoadingDelegate
- (void)dataSourceHasBeenReady:(CRRoastDataSource *)dataSource
{
    [self performSegueWithIdentifier:@"loadingComplete" sender:nil];
}

@end
