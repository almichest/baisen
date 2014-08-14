//
//  CRMasterViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/13.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastContentsViewController.h"
#import "CRRoastItemResultViewController.h"
#import "CRRoastManager.h"
#import "CRRoastDataSource.h"
#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRBean.h"
#import "CRRoastItemCell.h"

#import "CRUtility.h"
#import <QuartzCore/QuartzCore.h>

#define kRoastItemCellIdentifier    @"RoastItemCell"
#define kShowItemSegueIdentifier    @"ShowResult"
@interface CRRoastContentsViewController ()<CRRoastDataSourceDelegate>

@property(nonatomic, readonly) CRRoastManager *manager;
@property(nonatomic, readonly) CRRoastDataSource *dataSource;
@end

static NSString *beansNamesStringFromBeans(NSSet *beans);
@implementation CRRoastContentsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
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
    self.dataSource.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.dataSource.delegate = nil;
    [super viewDidDisappear:animated];
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
    cell.beansNameLabel.text = beansNamesStringFromBeans(roast.beans);
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
}

- (void)dataSourceDidChangeContent:(CRRoastDataSource *)dataSource
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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

static NSString *beansNamesStringFromBeans(NSSet *beans)
{
    NSMutableString *beanNames = [[NSMutableString alloc] init];
    NSArray *beansArray = beans.allObjects;
    
    for(CRBean *bean in beansArray) {
        [beanNames appendString:bean.area];
        if(bean != beansArray.lastObject) {
            [beanNames appendString:@", "];
        }
    }
    
    return beanNames.copy;
}
