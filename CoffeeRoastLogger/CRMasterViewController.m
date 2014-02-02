//
//  CRMasterViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRMasterViewController.h"
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"
#import "CRRoast.h"
#import "CREnvironment.h"

#import "CRUtility.h"

@interface CRMasterViewController ()<CRRoastDataSourceDelegate>

@property(nonatomic, readonly) CRRoastManager *manager;
@property(nonatomic, readonly) CRRoastDataSource *dataSource;
@end

@implementation CRMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource.delegate = self;
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
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.countOfRoastInformation;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CRRoast *roast = [self.dataSource roastInformationAtIndexPath:indexPath];
    NSTimeInterval interval = roast.environment.date;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    cell.textLabel.text = dateStringFromNSDate(date);
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

#pragma mark - CRRoastDataSourceDelegate
- (void)dataSourceWillChangeContent:(CRRoastDataSource *)dataSource
{
    
}

- (void)dataSource:(CRRoastDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(CRRoastDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)dataSourceDidChangeContent:(CRRoastDataSource *)dataSource
{
    
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

@end
