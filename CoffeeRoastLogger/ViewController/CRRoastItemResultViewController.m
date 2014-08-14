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
#import "CREmptyCell.h"

#import "CRUtility.h"
#import "CRConfiguration.h"
#import "CRSocialUtility.h"

#import "CRRoastManager.h"
#import "CRRoastDataSource.h"

#import <Social/Social.h>
@interface CRRoastItemResultViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, readonly) UIImage *image;

@property CRRoastManager *manager;
@property CRRoastDataSource *dataSource;

@end

typedef NS_ENUM(NSUInteger, TableViewSection)
{
    TableViewSectionDate            = 0,
    TableViewSectionImage           = 1,
    TableViewSectionBean            = 2,
    TableViewSectionHeating         = 3,
    TableViewSectionOtherCondition  = 4,
    TableViewSectionResult          = 5,
    TableViewSectionMemo            = 6,
    
};

#define kResultItemCellIdentifier           @"ResultItemCell"
#define kResultItemHeaderCellIdentifier     @"ResultItemHeaderCell"
#define kResultMemoCellIdentifier           @"ResultMemoCell"
#define kResultEmptyCellIdentifier          @"EmptyCell"

@implementation CRRoastItemResultViewController
{
    CGRect _memoFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultItemCell" bundle:nil] forCellReuseIdentifier:kResultItemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultItemHeaderCell" bundle:nil] forCellReuseIdentifier:kResultItemHeaderCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultMemoCell" bundle:nil] forCellReuseIdentifier:kResultMemoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyCell" bundle:nil] forCellReuseIdentifier:kResultEmptyCellIdentifier];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    UIImage *shareImage = [UIImage imageNamed:@"share_button"];
    UIImage *scaledImage = [UIImage imageWithCGImage:shareImage.CGImage scale:3.0f orientation:shareImage.imageOrientation];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:scaledImage style:UIBarButtonItemStylePlain target:self action:@selector(shareRoastInformation)];
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, shareItem];
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFromRightToLeft:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFromLeftToRight:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    
}

- (void)swipeFromRightToLeft:(id)sender
{
    NSUInteger nextIndex;
    NSUInteger currentIndex = [self indexOfCurrentItem];
    if(currentIndex == self.dataSource.countOfRoastInformation - 1) {
        return;
    } else {
        nextIndex = currentIndex + 1;
    }
    
    UIImage *currentImage = [self currentViewImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:currentImage];
    [self.view addSubview:imageView];
    [self showRoastItemAtIndex:nextIndex];
    self.view.frame = CGRectOffset(self.view.frame, self.view.frame.size.width, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, -self.view.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    
}

- (void)swipeFromLeftToRight:(id)sender
{
    NSUInteger nextIndex;
    NSUInteger currentIndex = [self indexOfCurrentItem];
    if(currentIndex == 0) {
        return;
    } else {
        nextIndex = currentIndex - 1;
    }
    [self showRoastItemAtIndex:nextIndex];
}

- (void)showRoastItemAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CRRoast *nextRoast = [self.dataSource roastInformationAtIndexPath:indexPath];
    self.roast = nextRoast;
    [self.tableView reloadData];
}

- (UIImage *)currentViewImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSUInteger)indexOfCurrentItem
{
    return  [self.dataSource indexOfRoastInformation:self.roast];
}

- (void)shareRoastInformation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Twitter", nil), NSLocalizedString(@"Facebook", nil), nil];
    [actionSheet showInView:self.view];
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
        case TableViewSectionDate :
            return 1;
        case TableViewSectionImage :
            return 1;
        case TableViewSectionBean :
            return self.roast.beans.count + 1;
        case TableViewSectionHeating :
            return self.roast.heating.count + 1;
        case TableViewSectionOtherCondition :
            return 2;
        case TableViewSectionResult :
            return 1;
        case TableViewSectionMemo :
            return 1;
        default :
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TableViewSectionDate :
            return 44;
        case TableViewSectionImage :
            return self.image.size.height + 8;
        case TableViewSectionBean :
            if(indexPath.row == 0) {
                return 20;
            } else {
                return 44;
            }
        case TableViewSectionHeating :
            if(indexPath.row == 0) {
                return 20;
            } else {
                return 44;
            }
        case TableViewSectionOtherCondition :
            return 44;
        case TableViewSectionResult :
            return 44;
        case TableViewSectionMemo :
            return [self memoLabelFrame].size.height + 30;
        default :
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TableViewSectionDate :
            return NSLocalizedString(@"DateLabel", nil);
        case TableViewSectionImage :
            return NSLocalizedString(@"PhotoLabel", nil);
        case TableViewSectionBean :
            return NSLocalizedString(@"BeansLabel", nil);
        case TableViewSectionHeating :
            return NSLocalizedString(@"HeatingsLabel", nil);
        case TableViewSectionOtherCondition :
            return NSLocalizedString(@"OtherConditionLabel", nil);
        case TableViewSectionResult :
            return NSLocalizedString(@"ResultLabel", nil);
        case TableViewSectionMemo :
            return NSLocalizedString(@"MemoLabel", nil);
        default :
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
       switch (indexPath.section) {
           case TableViewSectionDate : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultEmptyCellIdentifier forIndexPath:indexPath];
               NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.roast.environment.date];
               cell.textLabel.text = dateStringFromNSDate(date);
               break;
           }
           case TableViewSectionImage : {
               cell = [[UITableViewCell alloc] init];
               cell.frame = CGRectMake(0, 0, 320, self.image.size.height);
               UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
               imageView.contentMode = UIViewContentModeScaleAspectFit;
               imageView.image = self.image;
               [cell addSubview:imageView];
               break;
           }
           case TableViewSectionBean : {
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
           case TableViewSectionHeating : {
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
                   itemCell.nameLabel.text = heating.temperatureDescription;
                   if([CRConfiguration sharedConfiguration].useMinutesForHeatingLength) {
                       itemCell.valueLabel.text = [NSString stringWithFormat:@"%.1f", roastLengthFromValue(heating.time)];
                   } else {
                       itemCell.valueLabel.text = [NSString stringWithFormat:@"%.0f", roastLengthFromValue(heating.time)];
                   }
               }
               break;
           }
           case TableViewSectionOtherCondition : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
               CRResultItemCell *itemCell = (CRResultItemCell *)cell;
               itemCell.separetorView.hidden = NO;
               if(indexPath.row == 0) {
                   NSString *tempUnit = [CRConfiguration sharedConfiguration].useFahrenheitForRoom ? @"°F" : @"°C";
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"%@ [%@]",NSLocalizedString(@"RoomTemperatureLabel", nil), tempUnit];
                   itemCell.valueLabel.text = self.roast.environment.temperatureDescription;
               } else if(indexPath.row == 1) {
                   itemCell.nameLabel.text = [NSString stringWithFormat:@"%@ [%%]",NSLocalizedString(@"HumidityLabel", nil)]; ;
                   itemCell.valueLabel.text = self.roast.environment.humidityDescription;
               }
               break;
           }
           case TableViewSectionResult : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultItemCellIdentifier];
               CRResultItemCell *itemCell = (CRResultItemCell *)cell;
               itemCell.separetorView.hidden = NO;
               if(indexPath.row == 0) {
                   itemCell.nameLabel.text = NSLocalizedString(@"ScoreLabel", nil);
                   NSString *scoreLabelText = self.roast.scoreDescription;
                   itemCell.valueLabel.text = scoreLabelText;
               } else {
                   itemCell.nameLabel.text = NSLocalizedString(@"MemoLabel", nil);
                   itemCell.valueLabel.text = self.roast.result;
               }
               break;
           }
           case TableViewSectionMemo : {
               cell = [tableView dequeueReusableCellWithIdentifier:kResultMemoCellIdentifier];
               CRResultMemoCell *memoCell = (CRResultMemoCell *)cell;
               memoCell.memoLabel.text = self.roast.result;
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0 :
            [self showTwitterPostView];
            break;
        case 1 :
            [self showFacebookPostView];
            break;
        default :
            break;
    }
}

#pragma mark - Share
- (void)showTwitterPostView
{
    NSString *postMessage = [self postMessage];
    if(postMessage) {
        [CRSocialUtility showTwitterPostViewWithMessage:postMessage image:[UIImage imageWithData:self.roast.imageData] onViewController:self completion:^(CRSocialUtilitySharingResult result) {
            if(result == CRSocialUtilitySharingResultSuccess) {
                [self showSharingCompleteView];
            } else {
                [self showSharingErrorAlertView];
            }
        }];
    } else {
        [self showCannotShareAlertView];
    }
}

- (void)showFacebookPostView
{
    NSString *postMessage = [self postMessage];
    if(postMessage) {
        [CRSocialUtility showFacebookPostViewWithMessage:postMessage image:[UIImage imageWithData:self.roast.imageData] onViewController:self completion:^(CRSocialUtilitySharingResult result) {
            if(result == CRSocialUtilitySharingResultSuccess) {
                [self showSharingCompleteView];
            } else {
                [self showSharingErrorAlertView];
            }
        }];
    } else {
        [self showCannotShareAlertView];
    }
}

- (void)showSharingCompleteView
{
    UIAlertView *shareErrorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SharingComplete", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [shareErrorAlertView show];
}

- (NSString *)postMessage
{
    NSMutableString *message = @"".mutableCopy;
    [message appendString:NSLocalizedString(@"SharingMessageHead", nil)];
    for(CRBean *bean in self.roast.beans) {
        if([bean.area isEqualToString:NSLocalizedString(@"NotInput", nil)]) {
            return nil;
        }
        [message appendFormat:@"%@",bean.area];
        [message appendFormat:@" %@g%@",@(bean.quantity), NSLocalizedString(@"And", nil)];
    }
    message = [message substringToIndex:message.length - NSLocalizedString(@"And", nil).length].mutableCopy;
    [message appendString:NSLocalizedString(@"SharingMessageFoot", nil)];
    return message.copy;
}

- (void)showSharingErrorAlertView
{
    UIAlertView *shareErrorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"SharingFailure", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [shareErrorAlertView show];
}

- (void)showCannotShareAlertView
{
    UIAlertView *shareErrorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"CannotShare", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [shareErrorAlertView show];
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
