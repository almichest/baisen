//
//  CRConfigRootViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRConfigRootViewController.h"
#import "CRConfigCell.h"
#import "CRConfiguration.h"
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"

#define kSettingSwitchTag   10
#define kLoadintViewTag     20
@interface CRConfigRootViewController ()<CRRoastDataSourceSettingDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

#define kiCloudSettingSection       0
#define kAboutSection               1
#define kLicenceInformationSection  2

#define kConfigCellIdentifier   @"ConfigCell"

@implementation CRConfigRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConfigCell" bundle:nil] forCellReuseIdentifier:kConfigCellIdentifier];
    [CRRoastManager sharedManager].dataSource.settingDelegate = self;
    self.closeButton.target = self;
    self.closeButton.action = @selector(close:);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kiCloudSettingSection :
            return NSLocalizedString(@"EnableICloudTitle", nil);
        case kAboutSection :
            return NSLocalizedString(@"AboutTitle", nil);
        case kLicenceInformationSection :
            return NSLocalizedString(@"LicenceTitle", nil);
        default :
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:kConfigCellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case kiCloudSettingSection :
            cell.settingSwitch.hidden = NO;
            cell.settingSwitch.on = [CRConfiguration sharedConfiguration].iCloudAvailable;
            cell.settingSwitch.tag = kSettingSwitchTag;
            [cell.settingSwitch addTarget:self action:@selector(iCloudSettingChanged:) forControlEvents:UIControlEventValueChanged];
            cell.settingLabel.text = NSLocalizedString(@"EnableICloud", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case kAboutSection :
            cell.settingSwitch.hidden = YES;
            cell.settingLabel.text = NSLocalizedString(@"About", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
        case kLicenceInformationSection :
            cell.settingSwitch.hidden = YES;
            cell.settingLabel.text = NSLocalizedString(@"Licence", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default :
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyLog(@"section = %d", indexPath.section);
    MyLog(@"row = %d", indexPath.row);
    switch (indexPath.section) {
        case kAboutSection :
            [self performSegueWithIdentifier:@"about" sender:nil];
            break;
        case kLicenceInformationSection :
            [self performSegueWithIdentifier:@"licenceInformation" sender:nil];
            break;
        default :
            break;
    }
}

- (void)iCloudSettingChanged:(UISwitch *)sender
{
    [self willStartICloudSettings];
    [CRRoastManager sharedManager].dataSource.iCloudAvailable = sender.on;
}

#pragma mark - CRRoastDataSoruceSettingDelegate
- (void)dataSource:(CRRoastDataSource *)dataSource didLoadDataWithCloud:(BOOL)isCloud
{
    [self didFinishICloudSettings];
    UISwitch *iCloudSwitch = (UISwitch *)[self.view viewWithTag:kSettingSwitchTag];
    if(iCloudSwitch.on == isCloud) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SettingComplete", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)dataSourceCannotUseCloud:(CRRoastDataSource *)dataSource
{
    [self didFinishICloudSettings];
    UISwitch *iCloudSwitch = (UISwitch *)[self.view viewWithTag:kSettingSwitchTag];
    iCloudSwitch.on = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"iCloudUnavailable", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)willStartICloudSettings
{
    UIView *loadingBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    loadingBackgroundView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    indicator.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f);
    [loadingBackgroundView addSubview:indicator];
    loadingBackgroundView.tag = kLoadintViewTag;
    [self.navigationController.view addSubview:loadingBackgroundView];
}

- (void)didFinishICloudSettings
{
    [[self.navigationController.view viewWithTag:kLoadintViewTag] removeFromSuperview];
}

@end
