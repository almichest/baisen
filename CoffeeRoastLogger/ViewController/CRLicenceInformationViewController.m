//
//  CRLicenceInformationViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRLicenceInformationViewController.h"

@interface CRLicenceInformationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation CRLicenceInformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LICENSE" ofType:nil];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.textLabel.text = text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
