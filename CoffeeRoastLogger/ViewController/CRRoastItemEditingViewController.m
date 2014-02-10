//
//  CRNewItemViewController.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/01/26.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CRRoastItemEditingViewController.h"
#import "CRDateEditingViewController.h"
#import "CRSelectedPhotoViewController.h"
#import "CRConditionCell.h"
#import "CRMemoTextView.h"
#import "CRTwoItemsCell.h"
#import "CRTwoItemsCellButton.h"

#import "CRUtility.h"
#import "CRConfiguration.h"

#import "CRBeanInformation.h"
#import "CREnvironmentInformation.h"
#import "CRHeatingInformation.h"
#import "CRRoastInformation.h"

#import "CRRoastManager.h"

#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRHeating.h"
#import "CRBean.h"

#define kDefaultCellIdentifier      @"Cell"
#define kTwoItemCellIdentifier      @"TwoItemCell"
#define kConditionCellIdentifier    @"ConditionCell"
#define kEmptyCellIdentifier        @"EmptyCell"
#define kDateSection            0
#define kImageSection           1
#define kBeanSection            2
#define kHeatingSection         3
#define kOtherConditionSection  4
#define kResultSection          5

#define kBeanKindInputBaseTag       100
#define kBeanQuantityInputBaseTag   200
#define kHeatingTempratureBaseTag   300
#define kHeatingLengthBaseTag       400

#define kTempratureFieldTag         500
#define kHumidityFieldTag           600
#define kScoreFieldTag              700
#define kMemoViewTag                800

#define kImageViewTag               900

#define kImageSelectionActionSheetTag           0
#define kRoomTempratureUnitActionSheetTag       1
#define kHeatingTempratureUnitActionSheetTag    2
#define kHeatingLengthUnitActionSheetTag        3

#define kFahrenheitIndexInActionSheet   0
#define kCelsiusIndexInActionSheet      1

#define kMinuteIndexInActionSheet       0
#define kSecondIndexInActionSheet       1

#define kFahrenheit @"°F"
#define kCelcius    @"°C"

#define kMaxBeanCount                10
#define kMaxHeatingCount             50
@interface CRRoastItemEditingViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic) BOOL useFahrenheitForRoom;
@property(nonatomic) BOOL useFahrenheitForHeating;
@property(nonatomic) BOOL useMinuteForRoastLength;

@end

@implementation CRRoastItemEditingViewController
{
    CRRoastInformation *_roastInformation;
    NSMutableArray *_beanInformations;
    CREnvironmentInformation *_environmentInformation;
    NSMutableArray *_heatingInformations;
    
    NSUInteger _beanCount;
    NSUInteger _heatCount;
    NSDate *_date;
    UIImage *_image;
    
    NSMutableArray *_beanButtonsArray;
    NSMutableArray *_heatingButtonsArray;
    
    id _observer;
    
    UITextField *_currentTextField;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_roastItem == nil) {
        _roastInformation = [[CRRoastInformation alloc] init];
        _roastInformation.score = NSIntegerMin;
        _beanInformations = @[[[CRBeanInformation alloc] init]].mutableCopy;
        _environmentInformation = [[CREnvironmentInformation alloc] init];
        _heatingInformations = @[[[CRHeatingInformation alloc] init]].mutableCopy;
        
        _beanButtonsArray = [[NSMutableArray alloc] initWithCapacity:0];
        _heatingButtonsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        _beanCount = 1;
        _heatCount = 1;
        _date = [NSDate date];
        _environmentInformation.date = _date.timeIntervalSince1970;
    } else {
        _roastInformation = [[CRRoastInformation alloc] init];
        _roastInformation.score = _roastItem.score;
        
        _beanInformations = [[NSMutableArray alloc] initWithCapacity:_roastItem.beans.count];
        for(CRBean *bean in _roastItem.beans) {
            CRBeanInformation *information = [[CRBeanInformation alloc] init];
            information.area = bean.area;
            information.quantity = bean.quantity;
            [_beanInformations addObject:information];
        }
        
        _environmentInformation = [[CREnvironmentInformation alloc] init];
        _environmentInformation.date = _roastItem.environment.date;
        _environmentInformation.temperature = _roastItem.environment.temperature;
        _environmentInformation.humidity = _roastItem.environment.humidity;
        
        _heatingInformations = [[NSMutableArray alloc] initWithCapacity:_roastItem.heating.count];
        for(CRHeating *heating in _roastItem.heating) {
            CRHeatingInformation *information = [[CRHeatingInformation alloc] init];
            information.temperature = heating.temperature;
            information.time = heating.time;
            [_heatingInformations addObject:information];
        }
        
        _beanButtonsArray = [[NSMutableArray alloc] initWithCapacity:_beanInformations.count - 1];
        _heatingButtonsArray = [[NSMutableArray alloc] initWithCapacity:_heatingInformations.count - 1];
        
        _beanCount = _beanInformations.count;
        _heatCount = _heatingInformations.count;
        _date = [NSDate dateWithTimeIntervalSince1970:_roastItem.environment.date];
        
        _image = [UIImage imageWithData:_roastItem.imageData];
        
    }
    
    UIBarButtonItem const *cancelItem = self.cancelButton;
    cancelItem.target = self;
    cancelItem.action = @selector(didPushDismissButton:);
    
    UIBarButtonItem const *completeItem = self.completeButton;
    completeItem.target = self;
    completeItem.action = @selector(didPushCompleteButton:);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoItemsCell" bundle:nil] forCellReuseIdentifier:kTwoItemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConditionCell" bundle:nil] forCellReuseIdentifier:kConditionCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyCell" bundle:nil] forCellReuseIdentifier:kEmptyCellIdentifier];
    
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:CRSelectedPhotoViewControllerPhotoSelectNotification object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        UIImage *image = note.userInfo[CRSelectedPhotoViewControllerPhotoSelectNotificationKeyPhoto];
        [self resizeImage:image];
        [self.tableView reloadData];
    }];
    
    [[CRConfiguration sharedConfiguration] addObserver:self forKeyPath:@"useFahrenheitForRoom" options:NSKeyValueObservingOptionNew context:nil];
    [[CRConfiguration sharedConfiguration] addObserver:self forKeyPath:@"useFahrenheitForRoast" options:NSKeyValueObservingOptionNew context:nil];
    [[CRConfiguration sharedConfiguration] addObserver:self forKeyPath:@"useMinutesForHeatingLength" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)dealloc
{
    [[CRConfiguration sharedConfiguration] removeObserver:self forKeyPath:@"useFahrenheitForRoom"];
    [[CRConfiguration sharedConfiguration] removeObserver:self forKeyPath:@"useFahrenheitForRoast"];
    [[CRConfiguration sharedConfiguration] removeObserver:self forKeyPath:@"useMinutesForHeatingLength"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"useFahrenheitForRoom"]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kOtherConditionSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if([keyPath isEqualToString:@"useFahrenheitForRoast"]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kHeatingSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if([keyPath isEqualToString:@"useMinutesForHeatingLength"]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kHeatingSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)closeSoftKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - action
- (void)didPushDismissButton:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushCompleteButton:(UIBarButtonItem *)item
{
    [self closeSoftKeyboard];
    [self save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    _roastInformation.beans = _beanInformations;
    _roastInformation.environment = _environmentInformation;
    _roastInformation.heatingInformations = _heatingInformations;
    _roastInformation.image = _image;
    
    if(_roastItem == nil) {
        [[CRRoastManager sharedManager] addNewRoastInformation:_roastInformation];
    } else {
        [[CRRoastManager sharedManager] updateRoastItem:self.roastItem withRoastInformation:_roastInformation];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kResultSection :
            return indexPath.row == 1 ? 100 : 43;
        case kImageSection :
            if(_image == nil)
                return 43;
            else
                return _image.size.height + 10;
        default :
            return 43;
    }
}

- (CGFloat)heightForDatePickerAtRow:(NSInteger)row
{
    return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kDateSection :
            return 1;
        case kBeanSection :
            return _beanCount + 1;
        case kHeatingSection :
            return _heatCount + 1;
        case kOtherConditionSection :
            return 2;
        case kResultSection :
            return 2;
        case kImageSection :
            return 1;
        default :
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kDateSection :
            return NSLocalizedString(@"DateLabel", nil);
        case kBeanSection :
            return NSLocalizedString(@"BeansLabel", nil);
        case kHeatingSection :
            return NSLocalizedString(@"HeatingsLabel", nil);
        case kOtherConditionSection :
            return NSLocalizedString(@"OtherConditionLabel", nil);
        case kResultSection :
            return NSLocalizedString(@"ResultLabel", nil);
        case kImageSection :
            return NSLocalizedString(@"AddImageLabel", nil);
        default :
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kDateSection :
            return [self dateSectionCell];
        case kBeanSection :
            return [self beanSectionCellAtIndexPath:indexPath];
        case kHeatingSection :
            return [self heatingSectionCellAtIndexPath:indexPath];
        case kOtherConditionSection :
            return [self otherConditionSectionCellAtIndexPath:indexPath];
        case kResultSection :
            return [self resultSectionCellAtIndexPath:indexPath];
        case kImageSection :
            return [self imageSectionCell];
        default :
            return [self defaultCell];
    }
}

#pragma mark - Cell factory
- (UITableViewCell *)dateSectionCell
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    cell.textLabel.text = dateStringFromNSDate(_date);
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (UITableViewCell *)beanSectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row < _beanCount) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
        CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
        [itemCell.button setTitle:@"-" forState:UIControlStateNormal];
        [itemCell.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [itemCell.button addTarget:self action:@selector(removeBeanCell:) forControlEvents:UIControlEventTouchUpInside];
        itemCell.button.userInteractionEnabled = YES;
        
        CRBeanInformation *information = _beanInformations[indexPath.row];
        
        /* First item */
        itemCell.firstItemField.hidden = NO;
        itemCell.firstItemField.placeholder = NSLocalizedString(@"BeanKindLabel", nil);
        itemCell.firstItemField.text = @"";
        itemCell.firstItemField.tag = kBeanKindInputBaseTag + indexPath.row;
        itemCell.firstItemField.delegate = self;
        itemCell.firstItemField.text = information.area;
        itemCell.firstItemIndicator.hidden = YES;
        itemCell.firstItemFieldButton.hidden = YES;
        
        /* Second item */
        itemCell.secondItemField.hidden = NO;
        itemCell.secondItemField.placeholder = NSLocalizedString(@"BeanQuantityLabel", nil);
        itemCell.secondItemField.keyboardType = UIKeyboardTypeNumberPad;
        itemCell.secondItemField.text = @"";
        itemCell.secondItemField.tag = kBeanQuantityInputBaseTag + indexPath.row;
        itemCell.secondItemField.delegate = self;
        [itemCell.secondItemFieldButton setTitle:@"g" forState:UIControlStateNormal];
        itemCell.secondItemIndicator.hidden = YES;
        
        NSString *quantityString = information.quantity > 0 ? [NSString stringWithFormat:@"%d", information.quantity] : @"";
        itemCell.secondItemField.text = quantityString;
        
        _beanButtonsArray[indexPath.row] = itemCell.button;
        itemCell.button.indexPath = indexPath;
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
        CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
        itemCell.firstItemField.hidden = YES;
        itemCell.secondItemField.hidden = YES;
        [itemCell.button setTitle:@"+" forState:UIControlStateNormal];
        [itemCell.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [itemCell.button addTarget:self action:@selector(addNewCellForBean) forControlEvents:UIControlEventTouchUpInside];
        itemCell.button.userInteractionEnabled = YES;
        
        [itemCell.firstItemFieldButton setTitle:@"" forState:UIControlStateNormal];
        itemCell.firstItemIndicator.hidden = YES;
        [itemCell.secondItemFieldButton setTitle:@"" forState:UIControlStateNormal];
        itemCell.secondItemIndicator.hidden = YES;
    }
    
    return cell;
    
}

- (UITableViewCell *)heatingSectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row < _heatCount) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
        CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
        [itemCell.button setTitle:@"-" forState:UIControlStateNormal];
        [itemCell.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [itemCell.button addTarget:self action:@selector(removeHeatingCell:) forControlEvents:UIControlEventTouchUpInside];
        itemCell.button.userInteractionEnabled = YES;
        
        CRHeatingInformation *information = _heatingInformations[indexPath.row];
        
        /* First item*/
        NSString *firstButtonTitle = self.useFahrenheitForHeating ? kFahrenheit : kCelcius;
        [itemCell.firstItemFieldButton setTitle:firstButtonTitle forState:UIControlStateNormal];
        [itemCell.firstItemFieldButton addTarget:self action:@selector(showHeatingTempratureUnitSelectionSheet) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *firstIndicatorRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHeatingTempratureUnitSelectionSheet)];
        itemCell.firstItemRecognizerArea.userInteractionEnabled = YES;
        [self clearGestureRecognizerInView:itemCell.firstItemRecognizerArea];
        [itemCell.firstItemRecognizerArea addGestureRecognizer:firstIndicatorRecognizer];
        
        itemCell.firstItemField.hidden = NO;
        itemCell.firstItemField.placeholder = NSLocalizedString(@"HeatingTemperatureLabel", nil);
        itemCell.firstItemField.keyboardType = UIKeyboardTypeNumberPad;
        itemCell.firstItemField.text = @"";
        itemCell.firstItemField.tag = kHeatingTempratureBaseTag + indexPath.row;
        NSString *tempratureString = information.temperature > 0 ? [NSString stringWithFormat:@"%.0f", roastTempratureFromValue(information.temperature)] : @"";
        itemCell.firstItemIndicator.hidden = NO;
        itemCell.firstItemField.text = tempratureString;
        itemCell.firstItemField.delegate = self;
        itemCell.firstItemFieldButton.hidden = NO;
        
        /* Second item */
        NSString *secondButtonTitle = self.useMinuteForRoastLength ? NSLocalizedString(@"MinuteLabel", nil) : NSLocalizedString(@"SecondLabel", nil);
        [itemCell.secondItemFieldButton setTitle:secondButtonTitle forState:UIControlStateNormal];
        [itemCell.secondItemFieldButton addTarget:self action:@selector(showHeatingLengthUnitSelectionSheet) forControlEvents:UIControlEventTouchUpInside];
        
        itemCell.secondItemField.hidden = NO;
        itemCell.secondItemField.placeholder = NSLocalizedString(@"HeatingLengthLabel", nil);
        itemCell.secondItemField.keyboardType = UIKeyboardTypeNumberPad;
        itemCell.secondItemField.inputAccessoryView = [self separatorViewInKeyboard];
        itemCell.secondItemField.text = @"";
        itemCell.secondItemField.tag = kHeatingLengthBaseTag + indexPath.row;
        NSString *lengthString = information.time > 0 ? [NSString stringWithFormat:@"%.1f", roastLengthFromValue(information.time)] : @"";
        itemCell.secondItemField.text = lengthString;
        itemCell.secondItemField.delegate = self;
        UITapGestureRecognizer *secondIndicatorRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHeatingLengthUnitSelectionSheet)];
        itemCell.secondItemIndicator.hidden = NO;
        itemCell.secondItemRecognizerArea.userInteractionEnabled = YES;
        [self clearGestureRecognizerInView:itemCell.secondItemRecognizerArea];
        [itemCell.secondItemRecognizerArea addGestureRecognizer:secondIndicatorRecognizer];
        itemCell.secondItemFieldButton.hidden = NO;
        
        _heatingButtonsArray[indexPath.row] = itemCell.button;
        itemCell.button.indexPath = indexPath;
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
        CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
        itemCell.firstItemField.hidden = YES;
        itemCell.secondItemField.hidden = YES;
        [itemCell.button setTitle:@"+" forState:UIControlStateNormal];
        [itemCell.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [itemCell.button addTarget:self action:@selector(addNewCellForHeating) forControlEvents:UIControlEventTouchUpInside];
        itemCell.button.userInteractionEnabled = YES;
        
        [itemCell.firstItemFieldButton setTitle:@"" forState:UIControlStateNormal];
        itemCell.firstItemIndicator.hidden = YES;
        [itemCell.secondItemFieldButton setTitle:@"" forState:UIControlStateNormal];
        itemCell.secondItemIndicator.hidden = YES;
    }
    
    return cell;
}

- (UITableViewCell *)otherConditionSectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kConditionCellIdentifier];
    CRConditionCell *conditionCell = (CRConditionCell *)cell;
    if(indexPath.row == 0) {
        conditionCell.valueTextField.placeholder = NSLocalizedString(@"RoomTemperatureLabel", nil);
        conditionCell.valueTextField.tag = kTempratureFieldTag;
        conditionCell.valueTextField.delegate = self;
        NSString *tempratureString = _environmentInformation.temperature > 0 ? [NSString stringWithFormat:@"%.0lf", roomTempratureFromValue(_environmentInformation.temperature)] : @"";
        conditionCell.valueTextField.text = tempratureString;
        NSString *buttonTitle = self.useFahrenheitForRoom ? kFahrenheit : kCelcius;
        [conditionCell.button setTitle:buttonTitle forState:UIControlStateNormal];
        conditionCell.indicatorImage.hidden = NO;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRoomTempratureUnitSelectionSheet)];
        [self clearGestureRecognizerInView:conditionCell.recognizerField];
        conditionCell.recognizerField.userInteractionEnabled = YES;
        [conditionCell.recognizerField addGestureRecognizer:recognizer];
        
    } else if(indexPath.row == 1) {
        conditionCell.valueTextField.placeholder = NSLocalizedString(@"HumidityLabel", nil);
        conditionCell.valueTextField.tag = kHumidityFieldTag;
        NSString *humidityString = _environmentInformation.humidity > 0 ? [NSString stringWithFormat:@"%.0lf", _environmentInformation.humidity] : @"";
        conditionCell.valueTextField.text = humidityString;
        conditionCell.valueTextField.delegate = self;
        NSString *buttonTitle = @"%";
        [conditionCell.button setTitle:buttonTitle forState:UIControlStateNormal];
        conditionCell.indicatorImage.hidden = YES;
        
        conditionCell.recognizerField.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (UITableViewCell *)resultSectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kConditionCellIdentifier];
        CRConditionCell *conditionCell = (CRConditionCell *)cell;
        conditionCell.valueTextField.placeholder = NSLocalizedString(@"ScoreLabel", nil);
        conditionCell.valueTextField.tag = kScoreFieldTag;
        conditionCell.valueTextField.delegate = self;
        if(_roastInformation.score != NSIntegerMin) {
            conditionCell.valueTextField.text = [NSString stringWithFormat:@"%d", _roastInformation.score];
        }
        conditionCell.indicatorImage.hidden = YES;
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier forIndexPath:indexPath];
        UIView *imageView = [cell viewWithTag:kImageViewTag];
        [imageView removeFromSuperview];
        CGRect frame = CGRectMake(11, 10, 294, cell.frame.size.height - 20);
        CRMemoTextView *memoTextView = [[CRMemoTextView alloc] initWithFrame:frame];
        memoTextView.layer.borderWidth = 1.0f;    //ボーダーの幅
        memoTextView.layer.cornerRadius = 4.0f;    //ボーダーの角の丸み
        memoTextView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1].CGColor;
        memoTextView.font = [UIFont systemFontOfSize:14];
        memoTextView.placeHolder = NSLocalizedString(@"MemoLabel", nil);
        memoTextView.placeHolderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [cell addSubview:memoTextView];
        memoTextView.tag = kMemoViewTag;
        memoTextView.text = _roastInformation.result;
        memoTextView.delegate = self;
    }
    
    return cell;
}

- (UITableViewCell *)imageSectionCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier];
    UIView *textView = [cell viewWithTag:kMemoViewTag];
    [textView removeFromSuperview];
    if(_image == nil) {
        [cell addSubview:[self buttonToSetImage]];
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, _image.size.width, _image.size.height)];
        imageView.image = _image;
        imageView.userInteractionEnabled = YES;
        [cell addSubview:imageView];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImage)];
        [imageView addGestureRecognizer:gestureRecognizer];
        imageView.tag = kImageViewTag;
    }
    
    return cell;
}

- (UITableViewCell *)defaultCell
{
    return [self.tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
}

- (void)showDatePickerView
{
    [self performSegueWithIdentifier:@"editDate" sender:nil];
}

- (UIButton *)buttonToSetImage
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 43)];
    [button addTarget:self action:@selector(setImage) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    return button;
}

- (void)addNewCellForBean
{
    if(_beanCount >= kMaxBeanCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SorryMessageLabel", nil) message:NSLocalizedString(@"BeanItemLimitMessage", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [_beanInformations addObject:[[CRBeanInformation alloc] init]];
    _beanCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_beanCount - 1 inSection:kBeanSection];
    MyLog();
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    MyLog();
}

- (void)removeBeanCell:(CRTwoItemsCellButton *)button
{
    [self closeSoftKeyboard];
    button.userInteractionEnabled = NO;
    NSUInteger index = [_beanButtonsArray indexOfObject:button];
    _beanCount--;
    [_beanButtonsArray removeObject:button];
    [_beanInformations removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kBeanSection];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kBeanSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)addNewCellForHeating
{
    if(_heatCount >= kMaxHeatingCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SorryMessageLabel", nil) message:NSLocalizedString(@"HeatingItemLimitMessage", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [_heatingInformations addObject:[[CRHeatingInformation alloc] init]];
    _heatCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_heatCount - 1 inSection:kHeatingSection];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)removeHeatingCell:(CRTwoItemsCellButton *)button
{
    [self closeSoftKeyboard];
    NSUInteger index = [_heatingButtonsArray indexOfObject:button];
    [_heatingButtonsArray removeObject:button];
    [_heatingInformations removeObjectAtIndex:index];
    _heatCount--;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kHeatingSection];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
       [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kHeatingSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)setImage
{
    [self showImageSelectionSheet];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == kDateSection) {
        [self showDatePickerView];
    } else {
        [self closeSoftKeyboard];
    }
}

#pragma mark - Show UIActionSheet
- (void)showImageSelectionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectPhotoLabel", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLabel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SelectPhotoFromLibraryLabel", nil), NSLocalizedString(@"NewPhotoLabel", nil), nil];
    actionSheet.destructiveButtonIndex = 10;
    actionSheet.cancelButtonIndex = 2;
    actionSheet.tag = kImageSelectionActionSheetTag;
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)showRoomTempratureUnitSelectionSheet
{
    [self closeSoftKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SetRoomTemperatureUnitLabel", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLabel", nil) destructiveButtonTitle:nil otherButtonTitles:kFahrenheit, kCelcius, nil];
    actionSheet.tag =
    actionSheet.destructiveButtonIndex = 10;
    actionSheet.cancelButtonIndex = 2;
    actionSheet.tag = kRoomTempratureUnitActionSheetTag;
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)showHeatingTempratureUnitSelectionSheet
{
    [self closeSoftKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SetHeatingTemperatureUnitLabel", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLabel", nil) destructiveButtonTitle:nil otherButtonTitles:kFahrenheit, kCelcius, nil];
    actionSheet.destructiveButtonIndex = 10;
    actionSheet.cancelButtonIndex = 2;
    actionSheet.tag = kHeatingTempratureUnitActionSheetTag;
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)showHeatingLengthUnitSelectionSheet
{
    [self closeSoftKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SetHeatingLengthUnitLabel", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLabel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MinuteLabel", nil), NSLocalizedString(@"SecondLabel", nil), nil];
    actionSheet.destructiveButtonIndex = 10;
    actionSheet.cancelButtonIndex = 2;
    actionSheet.tag = kHeatingLengthUnitActionSheetTag;
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kImageSelectionActionSheetTag :
            [self selectImageWithButtonIndex:buttonIndex];
            break;
        case kRoomTempratureUnitActionSheetTag :
            [self selectRoomTempratureUnitWithButtonIndex:buttonIndex];
            break;
        case kHeatingTempratureUnitActionSheetTag :
            [self selectHeatingTempratureUnitWithButtonIndex:buttonIndex];
            break;
        case kHeatingLengthUnitActionSheetTag :
            [self selectHeatingLengthUnitWithButtonIndex:buttonIndex];
            break;
        default :
            break;
            
    }
}

- (void)selectImageWithButtonIndex:(NSUInteger)index
{
    switch (index) {
        case 0 :
            [self selectImageFromLibrary];
            break;
        case 1 :
            [self takePhoto];
            break;
        default :
            break;
    }
    
}

- (void)selectHeatingTempratureUnitWithButtonIndex:(NSUInteger)index
{
    switch (index) {
        case kFahrenheitIndexInActionSheet :
            [self setUseFahrenheitForHeating:YES];
            break;
        case kCelsiusIndexInActionSheet :
            [self setUseFahrenheitForHeating:NO];
            break;
        default :
            break;
    }
}

- (void)selectRoomTempratureUnitWithButtonIndex:(NSUInteger)index
{
   switch (index) {
    case kFahrenheitIndexInActionSheet :
           [self setUseFahrenheitForRoom:YES];
           break;
    case kCelsiusIndexInActionSheet :
           [self setUseFahrenheitForRoom:NO];
           break;
    default :
        break;
   }
}

- (void)selectHeatingLengthUnitWithButtonIndex:(NSUInteger)index
{
   switch (index) {
    case kMinuteIndexInActionSheet :
           [self setUseMinuteForRoastLength:YES];
           break;
    case kSecondIndexInActionSheet :
           [self setUseMinuteForRoastLength:NO];
           break;
    default :
        break;
   }
}

#pragma mark - Select Image
- (void)selectImageFromLibrary
{
    [self performSegueWithIdentifier:@"selectImage" sender:nil];
}


- (void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self resizeImage:image];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editDate"]) {
        CRDateEditingViewController *viewController = segue.destinationViewController;
        viewController.completion = ^(NSDate *date) {
            _date = date;
            _environmentInformation.date = date.timeIntervalSince1970;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDateSection] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
    }
}

#pragma mark - Private
- (void)resizeImage:(UIImage *)image
{
    UIImage *resizedImage;
    if(image.size.width > 320) {
        float ratio = 320 / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(ratio * image.size.width, ratio * image.size.height));
        [image drawInRect:CGRectMake(0, 0, ratio * image.size.width, ratio * image.size.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        resizedImage = image;
    }
    
    _image = resizedImage;
    
}

- (void)appendSeparatorToCurrentTextField
{
    NSString *currentString = _currentTextField.text;
    if(currentString.length > 0 && [currentString rangeOfString:@"."].location == NSNotFound) {
        _currentTextField.text = [NSString stringWithFormat:@"%@.", _currentTextField.text];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    MyLog(@"tag = %d", textField.tag);
    if(textField.tag == kScoreFieldTag) {
        NSInteger score = textField.text.integerValue;
        if(score < -100 || score > 100) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SorryMessageLabel", nil) message:NSLocalizedString(@"ScoreLimitMessage", nil) delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            textField.text = @"";
        } else {
            _roastInformation.score = score;
        }
    } else if(textField.tag == kTempratureFieldTag) {
        float saveValue = celsiusRoomTempratureFromValue(textField.text.floatValue);
        _environmentInformation.temperature = saveValue;
    } else if(textField.tag == kHumidityFieldTag) {
        _environmentInformation.humidity = textField.text.integerValue;
    } else if(textField.tag >= kBeanKindInputBaseTag && textField.tag < kBeanQuantityInputBaseTag) {
        NSUInteger index = textField.tag % 100;
        ((CRBeanInformation *)(_beanInformations[index])).area = textField.text;
    } else if(textField.tag >= kBeanQuantityInputBaseTag && textField.tag < kHeatingTempratureBaseTag) {
        NSUInteger index = textField.tag % 100;
        ((CRBeanInformation *)(_beanInformations[index])).quantity = textField.text.integerValue;
    } else if(textField.tag >= kHeatingTempratureBaseTag && textField.tag < kHeatingLengthBaseTag) {
        NSUInteger index = textField.tag % 100;
        float saveValue = celsiusRoastTempratureFromValue(textField.text.floatValue);
        ((CRHeatingInformation *)(_heatingInformations[index])).temperature = saveValue;
    } else if(textField.tag >= kHeatingLengthBaseTag && textField.tag < kTempratureFieldTag) {
        NSUInteger index = textField.tag % 100;
        NSTimeInterval saveValue = secondRoastLengthFromValue(textField.text.floatValue);
        ((CRHeatingInformation *)(_heatingInformations[index])).time = saveValue;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _roastInformation.result = textView.text;
}

#pragma mark - getter
- (BOOL)useFahrenheitForRoom
{
    return [CRConfiguration sharedConfiguration].useFahrenheitForRoom;
}

- (void)setUseFahrenheitForRoom:(BOOL)useFahrenheitForRoom
{
    [CRConfiguration sharedConfiguration].useFahrenheitForRoom = useFahrenheitForRoom;
}

- (BOOL)useFahrenheitForHeating
{
    return [CRConfiguration sharedConfiguration].useFahrenheitForRoast;
}

- (void)setUseFahrenheitForHeating:(BOOL)useFahrenheitForRoast
{
    [CRConfiguration sharedConfiguration].useFahrenheitForRoast = useFahrenheitForRoast;
}

- (BOOL)useMinuteForRoastLength
{
    return [CRConfiguration sharedConfiguration].useMinutesForHeatingLength;
}

- (void)setUseMinuteForRoastLength:(BOOL)useMinuteForRoastLength
{
    [CRConfiguration sharedConfiguration].useMinutesForHeatingLength = useMinuteForRoastLength;
}

#pragma mark - Utility
- (void)clearGestureRecognizerInView:(UIView *)view
{
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        [view removeGestureRecognizer:recognizer];
    }
}

- (UIView *)separatorViewInKeyboard
{
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(240, 0, 120, 30)];
    accessoryView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(215, 0, 105, 30)];
    label.text = @".";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.borderWidth = 1.0f;
    label.layer.borderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2].CGColor;
    label.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appendSeparatorToCurrentTextField)];
    [label addGestureRecognizer:recognizer];
    
    [accessoryView addSubview:label];
    
    return accessoryView;
}

@end

