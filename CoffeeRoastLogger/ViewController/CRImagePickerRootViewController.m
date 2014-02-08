//
//  CRImagePickerRootViewController.m
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/02.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRImagePickerRootViewController.h"
#import "CRImageRootViewCell.h"
#import "CRAlbumContentsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kImageRootViewCellIdentifier    @"ImageRootViewCell"

@interface CRImagePickerRootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation CRImagePickerRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Image";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didPushCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageRootCell" bundle:nil] forCellReuseIdentifier:kImageRootViewCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {

        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
        }
        else
        {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
}

- (void)didPushCancelButton:(UIBarButtonItem *)button
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  64;
}

// determine the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CRImageRootViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageRootViewCellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *groupForCell = self.groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell.thumbnailImageView.image = posterImage;
    cell.folderNameLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showContents" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showContents"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MyLog(@"section - %d", selectedIndexPath.section);
        MyLog(@"row - %d", selectedIndexPath.row);
        if (self.groups.count > (NSUInteger)selectedIndexPath.row) {
            
            // hand off the asset group (i.e. album) to the next view controller
            CRAlbumContentsViewController *albumContentsViewController = [segue destinationViewController];
            albumContentsViewController.assetsGroup = self.groups[selectedIndexPath.row];
        }
    }
}

@end
