//
//  CRRoastItemViewController.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/02/05.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastItemResultViewController.h"
#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRBean.h"
#import "CRHeating.h"

#import "CRResultItemCell.h"
#import "CRResultItemHeaderCell.h"

#import "CRUtility.h"
#import "CRConfiguration.h"

@interface CRRoastItemResultViewController ()

@property(nonatomic, readonly) UIImage *image;

@end

#define kDateSection            0
#define kImageSection           1
#define kBeanSection            2
#define kHeatingSection         3
#define kOtherConditionSection  4
#define kResultSection          5

#define kResultItemCellIdentifier           @"ResultItemCell"
#define kResultItemHeaderCellIdentifier     @"ResultItemHeaderCell"

@implementation CRRoastItemResultViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultItemCell" bundle:nil] forCellReuseIdentifier:kResultItemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultItemHeaderCell" bundle:nil] forCellReuseIdentifier:kResultItemHeaderCellIdentifier];

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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kDateSection :
            return 1;
        case kImageSection :
            return 1;
        case kBeanSection :
            return self.roast.beans.count + 1;
        case kHeatingSection :
            return self.roast.heating.count + 1;
        case kOtherConditionSection :
            return 2;
        case kResultSection :
            return 2;
        default :
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kDateSection :
            return 44;
        case kImageSection :
            return self.image.size.height + 8;
        case kBeanSection :
            if(indexPath.row == 0) {
                return 20;
            } else {
                return 44;
            }
        case kHeatingSection :
            if(indexPath.row == 0) {
                return 20;
            } else {
                return 44;
            }
        case kOtherConditionSection :
            return 44;
        case kResultSection :
            if(indexPath.row == 0) {
                return 44;
            } else {
                return 100;
            }
        default :
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
       switch (section) {
        case kDateSection :
            return @"Date";
        case kImageSection :
            return @"Photo";
        case kBeanSection :
            return @"Beans";
        case kHeatingSection :
            return @"Heatings";
        case kOtherConditionSection :
            return @"Other Conditions";
        case kResultSection :
           return @"Result";
        default :
            return @"";
       }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
       switch (indexPath.section) {
           case kDateSection : {
               cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"forIndexPath:indexPath];
               NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.roast.environment.date];
               cell.textLabel.text = dateStringFromNSDate(date);
               break;
           }
           case kImageSection : {
               cell = [[UITableViewCell alloc] init];
               cell.frame = CGRectMake(0, 0, 320, self.image.size.height);
               UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
               imageView.image = self.image;
               [cell addSubview:imageView];
               break;
           }
           case kBeanSection : {
               if(indexPath.row == 0) {
                   cell = [tableView dequeueReusableCellWithIdentifier:kResultItemHeaderCellIdentifier];
                   CRResultItemHeaderCell *headerCell = (CRResultItemHeaderCell *)cell;
                   headerCell.firstNameLabel.text = @"Kind";
                   headerCell.secondNameLabel.text = @"Quantity [g]";
               } else {
                   cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
                   CRResultItemCell *itemCell = (CRResultItemCell *)cell;
                   itemCell.separetorView.hidden = NO;
                   CRBean *bean = [self.roast.beans allObjects][indexPath.row - 1];
                   itemCell.nameLabel.text = bean.area;
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%u", bean.quantity];
               }
               break;
           }
           case kHeatingSection : {
               if(indexPath.row == 0) {
                   cell = [tableView dequeueReusableCellWithIdentifier:kResultItemHeaderCellIdentifier];
                   CRResultItemHeaderCell *headerCell = (CRResultItemHeaderCell *)cell;
                   NSString *tempUnit = [CRConfiguration sharedConfiguration].useFahrenheitForRoast ? @"°F" : @"°C";
                   headerCell.firstNameLabel.text = [NSString stringWithFormat:@"Temp. [%@]", tempUnit];
                   NSString *lengthUnit = [CRConfiguration sharedConfiguration].useMinutesForHeatingLength ? @"min." : @"sec.";
                   headerCell.secondNameLabel.text = [NSString stringWithFormat:@"Length [%@]", lengthUnit];
               } else {
                   cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
                   CRResultItemCell *itemCell = (CRResultItemCell *)cell;
                   itemCell.separetorView.hidden = NO;
                   CRHeating *heating = [self.roast heatingAtIndex:indexPath.row - 1];
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"%.0f", roastTempratureFromValue(heating.temperature)];
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%.0f", roastLengthFromValue(heating.time)];
               }
               break;
           }
           case kOtherConditionSection : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
               CRResultItemCell *itemCell = (CRResultItemCell *)cell;
               itemCell.separetorView.hidden = NO;
               if(indexPath.row == 0) {
                   NSString *tempUnit = [CRConfiguration sharedConfiguration].useFahrenheitForRoom ? @"°F" : @"°C";
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"Temp. [%@]", tempUnit];
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.roast.environment.temperature];
               } else if(indexPath.row == 1) {
                   itemCell.nameLabel.text = @"Humidity [%]";
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.roast.environment.humidity];
               }
               break;
           }
           case kResultSection : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
               CRResultItemCell *itemCell = (CRResultItemCell *)cell;
               itemCell.separetorView.hidden = NO;
               if(indexPath.row == 0) {
                   itemCell.nameLabel.text = @"Score";
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%d", self.roast.score];
               } else {
                   itemCell.nameLabel.text = @"Memo";
                   itemCell.valueLabel.text = self.roast.result;
               }
               break;
           }
        default :
           break;
       }
    
    return cell;
}

#pragma mark - getter
- (UIImage *)image
{
    return [UIImage imageWithData:self.roast.imageData];
}

@end
