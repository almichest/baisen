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
    
    self.okButton.action = @selector(didPushOKButton);
    self.cancelButton.action = @selector(didPushCancelButton);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPushOKButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.completion) {
            self.completion(self.datePicker.date);
        }
    }];
}

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
