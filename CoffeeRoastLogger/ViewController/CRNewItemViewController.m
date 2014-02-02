//
//  CRNewItemViewController.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/01/26.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CRNewItemViewController.h"
#import "CRDateEditingViewController.h"
#import "CRConditionCell.h"
#import "CRMemoTextView.h"
#import "CRTwoItemsCell.h"
#import "CRUtility.h"

#import "CRBeanInformation.h"
#import "CREnvironmentInformation.h"
#import "CRHeatingInformation.h"
#import "CRRoastInformation.h"

#import "CRRoastManager.h"

#define kDefaultCellIdentifier      @"Cell"
#define kTwoItemCellIdentifier      @"TwoItemCell"
#define kConditionCellIdentifier    @"ConditionCell"
#define kEmptyCellIdentifier        @"EmptyCell"
#define kDateSection            0
#define kBeanSection            1
#define kHeatingSection         2
#define kOtherConditionSection  3
#define kResultSection          4
#define kImageSection           5

#define kDateLabelTag                10
#define kBeanCellTag                100
#define kHeatingCellTag             200
#define kTempratureFieldTag         500
#define kHumidityFieldTag           600
#define kScoreFieldTag              700
#define kMemoViewTag                800

#define kMaxBeanCount                10
#define kMaxHeatingCount             50
@interface CRNewItemViewController ()

@end

@implementation CRNewItemViewController
{
    UIDatePicker *_datePicker;
    NSUInteger _beanCount;
    NSUInteger _heatCount;
    NSDate *_date;
    UIImage *_image;
    
    NSMutableArray *_beanButtonsArray;
    NSMutableArray *_heatingButtonsArray;
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
    UIBarButtonItem const *cancelItem = self.cancelButton;
    cancelItem.target = self;
    cancelItem.action = @selector(didPushDismissButton:);
    
    UIBarButtonItem const *completeItem = self.completeButton;
    completeItem.target = self;
    completeItem.action = @selector(didPushCompleteButton:);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoItemsCell" bundle:nil] forCellReuseIdentifier:kTwoItemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConditionCell" bundle:nil] forCellReuseIdentifier:kConditionCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyCell" bundle:nil] forCellReuseIdentifier:kEmptyCellIdentifier];
    
    _beanButtonsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _heatingButtonsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _beanCount = 1;
    _heatCount = 1;
    _date = [NSDate date];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard:)];
    [self.view addGestureRecognizer:gestureRecognizer];
}


- (void)closeSoftKeyboard:(UIGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (void)didPushDismissButton:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushCompleteButton:(UIBarButtonItem *)item
{
    [self save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    CRRoastInformation *information = [[CRRoastInformation alloc] init];
    information.beans = [self beanInformations];
    information.environment = [self environmentInformation];
    information.heatingInformations = [self heatingInformations];
    
    information.score = ((UITextField *)[self.tableView viewWithTag:kScoreFieldTag]).text.integerValue;
    information.result = ((UITextView *)[self.tableView viewWithTag:kMemoViewTag]).text;
    
    [[CRRoastManager sharedManager] addNewRoastInformation:information];
}

- (NSArray *)beanInformations
{
    NSMutableArray *mutableBeanInformations = [[NSMutableArray alloc] initWithCapacity:_beanCount];
    
    for(NSUInteger index = 0; index < _beanCount; index++) {
        CRBeanInformation *information = [[CRBeanInformation alloc] init];
        CRTwoItemsCell *cell = (CRTwoItemsCell *)[self.tableView viewWithTag:kBeanCellTag + index];
        information.area = cell.firstItemField.text;
        information.quantity = cell.secondItemField.text.integerValue;
        mutableBeanInformations[index] = information;
    }
    
    return mutableBeanInformations.copy;
}

- (CREnvironmentInformation *)environmentInformation
{
    CREnvironmentInformation *information = [[CREnvironmentInformation alloc] init];
    information.temperature = ((UITextField *)[self.tableView viewWithTag:kTempratureFieldTag]).text.integerValue;
    information.humidity = ((UITextField *)[self.tableView viewWithTag:kHumidityFieldTag]).text.integerValue;
    information.date = _date.timeIntervalSince1970;
    return information;
}

- (NSArray *)heatingInformations
{
    NSMutableArray *mutableHeatingInformations = [[NSMutableArray alloc] initWithCapacity:_heatCount];
    
    for(NSUInteger index = 0; index < _heatCount; index++) {
        CRHeatingInformation *information = [[CRHeatingInformation alloc] init];
        CRTwoItemsCell *cell = (CRTwoItemsCell *)[self.tableView viewWithTag:kHeatingCellTag + index];
        information.temperature = cell.firstItemField.text.floatValue;
        information.time = cell.secondItemField.text.integerValue;
        mutableHeatingInformations[index] = information;
    }
    
    return mutableHeatingInformations.copy;
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
                return _image.size.height;
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
            return @"Date";
        case kBeanSection :
            return @"Beans";
        case kHeatingSection :
            return @"Heating";
        case kOtherConditionSection :
            return @"Other Condition";
        case kResultSection :
            return @"Result";
        case kImageSection :
            return @"Add Image";
        default :
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case kDateSection : {
            cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = dateStringFromNSDate(_date);
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.tag = kDateLabelTag;
            UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 50, 0, 50, cell.frame.size.height)];
            [editButton addTarget:self action:@selector(showDatePickerView) forControlEvents:UIControlEventTouchUpInside];
            [editButton setTitle:@"Edit" forState:UIControlStateNormal];
            [editButton setTitleColor:editButton.tintColor forState:UIControlStateNormal];
            [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [cell addSubview:editButton];
            
            break;
        }
        case kBeanSection :
            if(indexPath.row < _beanCount) {
                cell = [tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
                CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
                itemCell.firstItemField.placeholder = @"Kind";
                itemCell.secondItemField.placeholder = @"Quantity";
                itemCell.secondItemField.keyboardType = UIKeyboardTypeNumberPad;
                itemCell.firstItemField.text = @"";
                itemCell.secondItemField.text = @"";
                itemCell.tag = kBeanCellTag + indexPath.row;
                UIButton *button = [self buttonToRemoveBean];
                _beanButtonsArray[indexPath.row] = button;
                [cell.contentView addSubview:button];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier forIndexPath:indexPath];
                [cell.contentView addSubview:[self buttonToAddBean]];
            }
            break;
        case kHeatingSection :
            if(indexPath.row < _heatCount) {
                cell = [tableView dequeueReusableCellWithIdentifier:kTwoItemCellIdentifier];
                CRTwoItemsCell *itemCell = (CRTwoItemsCell *)cell;
                itemCell.firstItemField.placeholder = @"Temprature";
                itemCell.secondItemField.placeholder = @"Length";
                itemCell.firstItemField.keyboardType = UIKeyboardTypeNumberPad;
                itemCell.secondItemField.keyboardType = UIKeyboardTypeNumberPad;
                itemCell.firstItemField.text = @"";
                itemCell.secondItemField.text = @"";
                itemCell.tag = kHeatingCellTag + indexPath.row;
                UIButton *button = [self buttonToRemoveHeating];
                _heatingButtonsArray[indexPath.row] = button;
                [cell.contentView addSubview:button];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier forIndexPath:indexPath];
                [cell.contentView addSubview:[self buttonToAddHeating]];
            }
            break;
        case kOtherConditionSection :
            cell = [tableView dequeueReusableCellWithIdentifier:kConditionCellIdentifier];
            if(indexPath.row == 0) {
                ((CRConditionCell *)cell).valueTextField.placeholder = @"Temprature";
                cell.tag = kTempratureFieldTag;
            } else if(indexPath.row == 1) {
                ((CRConditionCell *)cell).valueTextField.placeholder = @"Humidity";
                cell.tag = kHumidityFieldTag;
            }
            break;
        case kResultSection :
            if(indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kConditionCellIdentifier];
                ((CRConditionCell *)cell).valueTextField.placeholder = @"Score";
                cell.tag = kScoreFieldTag;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier forIndexPath:indexPath];
                CGRect frame = CGRectMake(11, 10, 294, cell.frame.size.height - 20);
                CRMemoTextView *memoTextView = [[CRMemoTextView alloc] initWithFrame:frame];
                memoTextView.layer.borderWidth = 1.0f;    //ボーダーの幅
                memoTextView.layer.cornerRadius = 4.0f;    //ボーダーの角の丸み
                memoTextView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1].CGColor;
                memoTextView.font = [UIFont systemFontOfSize:14];
                memoTextView.placeHolder = @"Memo";
                memoTextView.placeHolderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
                [cell.contentView addSubview:memoTextView];
                cell.tag = kMemoViewTag;
            }
            break;
        case kImageSection :
            cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier];
            if(_image == nil) {
                [cell.contentView addSubview:[self buttonToSetImage]];
            }
            cell.imageView.image = nil;
            cell.textLabel.text = @"";
            break;
        default :
            cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];
            break;
    }
    
    return cell;
}

- (void)showDatePickerView
{
    [self performSegueWithIdentifier:@"editDate" sender:nil];
    
}

- (UIDatePicker *)datePickerForFrame:(CGRect)frame;
{
    if(!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    }
    
    return _datePicker;
}

- (UIButton *)buttonToAddBean
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 43)];
    [button addTarget:self action:@selector(addNewCellForBean) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    return button;
}

- (UIButton *)buttonToRemoveBean
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 43)];
    [button addTarget:self action:@selector(removeBeanCell:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"-" forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    return button;
    
}

- (UIButton *)buttonToAddHeating
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 43)];
    [button addTarget:self action:@selector(addNewCellForHeating) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    return button;
}

- (UIButton *)buttonToRemoveHeating
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 43)];
    [button addTarget:self action:@selector(removeHeatingCell:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"-" forState:UIControlStateNormal];
    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    return button;
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Only 10 beans can be input." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    _beanCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_beanCount - 1 inSection:kBeanSection];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)removeBeanCell:(UIButton *)button
{
    _beanCount--;
    NSUInteger index = [_beanButtonsArray indexOfObject:button];
    [_beanButtonsArray removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kBeanSection];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)addNewCellForHeating
{
    if(_heatCount >= kMaxHeatingCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Only 50 heating procedure can be input." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    _heatCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_heatCount - 1 inSection:kHeatingSection];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)removeHeatingCell:(UIButton *)button
{
    _heatCount--;
    NSUInteger index = [_heatingButtonsArray indexOfObject:button];
    [_heatingButtonsArray removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kHeatingSection];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)setImage
{
    
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editDate"]) {
        CRDateEditingViewController *viewController = segue.destinationViewController;
        viewController.completion = ^(NSDate *date) {
            _date = date;
            [self.tableView reloadData];
        };
    }
}

@end
