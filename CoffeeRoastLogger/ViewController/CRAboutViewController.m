//
//  CRAboutViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRAboutViewController.h"

#define kAboutAppSection    0
#define kDeveloperSection   1
#define kTwitterSection     2
#define kAppStoreSection    3

@interface CRAboutViewController ()

@end

@implementation CRAboutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kAboutAppSection :
            return NSLocalizedString(@"AppExplanationTitle", nil);
        case kDeveloperSection :
            return NSLocalizedString(@"AboutDeveloperTitle", nil);
        case kTwitterSection :
            return NSLocalizedString(@"TwitterAccountTitle", nil);
        default :
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kAboutAppSection : {
            NSString *explanation = NSLocalizedString(@"AppExplanation", nil);
            return [self frameForText:explanation].size.height + 30;
        }
        default :
            return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    switch (indexPath.section) {
        case kAboutAppSection :
            cell.textLabel.text = NSLocalizedString(@"AppExplanation", nil);
            break;
        case kDeveloperSection :
            cell.textLabel.text = NSLocalizedString(@"AboutDeveloper", nil);
            break;
        case kTwitterSection :
            cell.textLabel.text = NSLocalizedString(@"TwitterAccount", nil);
            break;
        case kAppStoreSection :
        default :
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTwitterSection :
            [self openTwitterClient];
            return;
        default :
            return;
    }
}

- (void)openTwitterClient
{
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/yamazaki_sensei"];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Private
- (CGRect)frameForText:(NSString *)text;
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]};
    return [text boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

@end
