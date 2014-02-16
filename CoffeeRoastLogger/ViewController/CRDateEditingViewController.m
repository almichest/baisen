//
//  CRDateEditingViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/28.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRDateEditingViewController.h"

@interface CRDateEditingViewController ()

@end

@implementation CRDateEditingViewController

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
    [self.okButton addTarget:self action:@selector(didPushOKButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPushOKButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    if(self.completion) {
        self.completion(self.datePicker.date);
    }
    
}

@end
