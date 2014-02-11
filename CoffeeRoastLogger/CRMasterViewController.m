//
//  CRMasterViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRMasterViewController.h"
#import "CRRoastItemResultViewController.h"
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"
#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRRoastItemCell.h"

#import "CRUtility.h"
#import <QuartzCore/QuartzCore.h>

#define kRoastItemCellIdentifier    @"RoastItemCell"
#define kShowItemSegueIdentifier    @"showItem"
@interface CRMasterViewController ()<CRRoastDataSourceDelegate>

@property(nonatomic, readonly) CRRoastManager *manager;
@property(nonatomic, readonly) CRRoastDataSource *dataSource;
@end

@implementation CRMasterViewController
{
    NSUInteger _order;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource.delegate = self;
//    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
//    MyLog(@"%lld", [store longLongForKey:@"hoge"]);
    [self.tableView registerNib:[UINib nibWithNibName:@"RoastItemCell" bundle:nil] forCellReuseIdentifier:kRoastItemCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    _order = log10(self.dataSource.countOfRoastInformation) + 1;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.countOfRoastInformation;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRRoastItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoastItemCellIdentifier forIndexPath:indexPath];
    CRRoast *roast = [self.dataSource roastInformationAtIndexPath:indexPath];
    NSTimeInterval interval = roast.environment.date;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    cell.numberLabel.text = [NSString stringWithFormat:@"%u", (unsigned int)(indexPath.row + 1)];
    cell.dateLabel.text = dateStringFromNSDate(date);
    if(roast.imageData) {
        cell.photoImageView.image = [UIImage imageWithData:roast.imageData];
    } else {
        cell.photoImageView.image = [UIImage imageNamed:@"icon@2x"];
    }
    cell.photoImageView.layer.masksToBounds = YES;
    cell.photoImageView.layer.cornerRadius = 5.0f;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource removeRoastInformationAtIndex:indexPath.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kShowItemSegueIdentifier sender:nil];
}

#pragma mark - CRRoastDataSourceDelegate
- (void)dataSourceWillChangeContent:(CRRoastDataSource *)dataSource
{
    [self.tableView beginUpdates];
    
}

- (void)dataSource:(CRRoastDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(CRRoastDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if(type == CRRoastDataSourceChangeInsert) {
         NSArray *indexPaths = @[newIndexPath];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if(type == CRRoastDataSourceChangeDelete) {
        NSArray *indexPaths = @[indexPath];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSourceDidChangeContent:(CRRoastDataSource *)dataSource
{
    [self.tableView endUpdates];
}

#pragma mark - getter
- (CRRoastManager *)manager
{
    return [CRRoastManager sharedManager];
}

- (CRRoastDataSource *)dataSource
{
    return self.manager.dataSource;
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kShowItemSegueIdentifier]) {
        CRRoastItemResultViewController *viewController = segue.destinationViewController;
        viewController.roast = [self.dataSource roastInformationAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

@end
