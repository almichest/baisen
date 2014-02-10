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

#import "CRRoastItemEditingViewController.h"

#import "CRResultItemCell.h"
#import "CRResultItemHeaderCell.h"
#import "CRResultMemoCell.h"

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
#define kMemoSection            6

#define kResultItemCellIdentifier           @"ResultItemCell"
#define kResultItemHeaderCellIdentifier     @"ResultItemHeaderCell"
#define kResultMemoCellIdentifier           @"ResultMemoCell"

@implementation CRRoastItemResultViewController
{
    CGRect _memoFrame;
}

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
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultMemoCell" bundle:nil] forCellReuseIdentifier:kResultMemoCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
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
            return 1;
        case kMemoSection :
            return 1;
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
            return 44;
        case kMemoSection :
            return [self memoLabelFrame].size.height + 30;
        default :
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kDateSection :
            return NSLocalizedString(@"DateLabel", nil);
        case kImageSection :
            return NSLocalizedString(@"PhotoLabel", nil);
        case kBeanSection :
            return NSLocalizedString(@"BeansLabel", nil);
        case kHeatingSection :
            return NSLocalizedString(@"HeatingsLabel", nil);
        case kOtherConditionSection :
            return NSLocalizedString(@"OtherConditionLabel", nil);
        case kResultSection :
            return NSLocalizedString(@"ResultLabel", nil);
        case kMemoSection :
            return NSLocalizedString(@"MemoLabel", nil);
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
                   headerCell.firstNameLabel.text = NSLocalizedString(@"BeanKindLabel", nil);
                   headerCell.secondNameLabel.text = [NSString stringWithFormat:@"%@ [g]", NSLocalizedString(@"BeanQuantityLabel", nil)];
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
                   headerCell.firstNameLabel.text = [NSString stringWithFormat:@"%@ [%@]",NSLocalizedString(@"HeatingTemperatureLabel", nil), tempUnit];
                   NSString *lengthUnit = [CRConfiguration sharedConfiguration].useMinutesForHeatingLength ? NSLocalizedString(@"MinuteLabel", nil) : NSLocalizedString(@"SecondLabel", nil);
                   headerCell.secondNameLabel.text = [NSString stringWithFormat:@"%@ [%@]",NSLocalizedString(@"HeatingLengthLabel", nil), lengthUnit];
               } else {
                   cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
                   CRResultItemCell *itemCell = (CRResultItemCell *)cell;
                   itemCell.separetorView.hidden = NO;
                   NSOrderedSet *heatings = self.roast.heating;
                   CRHeating *heating = [heatings objectAtIndex:indexPath.row - 1];
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
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"%@ [%@]",NSLocalizedString(@"RoomTemperatureLabel", nil), tempUnit];
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.roast.environment.temperature];
               } else if(indexPath.row == 1) {
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"%@ [%%]",NSLocalizedString(@"HumidityLabel", nil)]; ;
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.roast.environment.humidity];
               }
               break;
           }
           case kResultSection : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
               CRResultItemCell *itemCell = (CRResultItemCell *)cell;
               itemCell.separetorView.hidden = NO;
               if(indexPath.row == 0) {
                   itemCell.nameLabel.text = NSLocalizedString(@"ScoreLabel", nil);
                   itemCell.valueLabel.text = [NSString stringWithFormat:@"%d", self.roast.score];
               } else {
                   itemCell.nameLabel.text = NSLocalizedString(@"MemoLabel", nil);
                   itemCell.valueLabel.text = self.roast.result;
               }
               break;
           }
           case kMemoSection : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultMemoCellIdentifier];
               CRResultMemoCell *memoCell = (CRResultMemoCell *)cell;
               memoCell.memoLabel.text = self.roast.result;
               memoCell.memoLabel.frame = CGRectMake(0, 0, [self memoLabelFrame].size.width, [self memoLabelFrame].size.height);
               break;
           }
               
        default :
           break;
       }
    
    cell.userInteractionEnabled = NO;
    return cell;
}

#pragma mark - Private
- (CGRect)memoLabelFrame
{
    MyLog(@"result = %@", self.roast.result);
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]};
    return [self.roast.result boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

#pragma mark - getter
- (UIImage *)image
{
    return [UIImage imageWithData:self.roast.imageData];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CRRoastItemEditingViewController *viewController = navigationController.viewControllers[0];
        viewController.roastItem = self.roast;
    }
}

@end
