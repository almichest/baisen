//
//  CRRoastDataSource.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastDataSource.h"
#import "UbiquityStoreManager.h"

#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRBean.h"
#import "CRHeating.h"

#import "CRConfiguration.h"

#import "CRRoastInformation.h"
#import "CREnvironmentInformation.h"
#import "CRBeanInformation.h"
#import "CRHeatingInformation.h"

@interface CRRoastDataSource() <NSFetchedResultsControllerDelegate, UbiquityStoreManagerDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

static CRRoastInformation *roastInformationFromRoastItem(CRRoast *roastItem);

@implementation CRRoastDataSource
{
    UbiquityStoreManager *_storeManager;
    NSArray *_tempRoastInformations;
    BOOL _useCloud;
    BOOL _completed;
    
    NSManagedObjectContext *_oldContext;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshToUseCloud:(BOOL)useCloud
{
    _useCloud = useCloud;
    _completed = NO;
    _oldContext = _managedObjectContext;
    
    [self reset];
    
    if(useCloud != [CRConfiguration sharedConfiguration].iCloudAvailable && _managedObjectContext) {
        [self willMigrate];
    }
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"CRCoffeeData.sqlite"];
    _storeManager = [[UbiquityStoreManager alloc] initStoreNamed:nil withManagedObjectModel:self.managedObjectModel localStoreURL:storeURL containerIdentifier:nil storeConfiguration:nil storeOptions:nil delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudContentsWillChange:)
                                                 name:USMStoreWillChangeNotification
                                               object:_storeManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudContentsDidChange:)
                                                 name:USMStoreDidChangeNotification
                                               object:_storeManager];
}

- (void)reset
{
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _fetchedResultsController = nil;
    _persistentStoreCoordinator = nil;
}

- (void)iCloudContentsWillChange:(NSNotification *)notification
{
    MyLog(@"iCloudContentsWillChange");
}

- (void)iCloudContentsDidChange:(NSNotification *)notification
{
    MyLog(@"iCloudContentsDidChange");
}

#pragma mark - migration
- (void)willMigrate
{
    NSArray *roastItems = self.fetchedResultsController.fetchedObjects;
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:roastItems.count];
    for(CRRoast *roastItem in roastItems) {
        [mutableItems addObject:roastInformationFromRoastItem(roastItem)];
        [self.managedObjectContext deleteObject:roastItem];
    }
    
    _tempRoastInformations = mutableItems.copy;
    [self save];
}

#pragma mark - get
- (CRRoast *)roastInformationAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


#pragma mark - add
- (CRRoast *)addRoastInformation:(CRRoastInformation *)information
{
    CRRoast *roast = [self roastWithRoastInformation:information];
    [self save];
    
    return roast;
}

- (NSArray *)addRoastInformations:(NSArray *)informations
{
    NSMutableArray *mutableRoastItems = [[NSMutableArray alloc] initWithCapacity:informations.count];
    for(CRRoastInformation *information in informations) {
        CRRoast *roast = [self roastWithRoastInformation:information];
        [mutableRoastItems addObject:roast];
    }
    
    [self save];
    
    return mutableRoastItems.copy;
}

- (CRRoast *)updateRoastItem:(CRRoast *)roast withRoastInformation:(CRRoastInformation *)information
{
    roast.environment = [self environmentWithEnvironmentInformation:information.environment];
    roast.beans = [self beansWithBeansInformations:information.beans];
    roast.heating = [self heatingsWithHeatingInformations:information.heatingInformations];
    
    roast.score = information.score;
    roast.result = information.result;
    if(information.image) {
        roast.imageData = [self dataFromImage:information.image];
    }
    
    [self save];
    
    return roast;
}

#pragma mark - add private
- (CRRoast *)roastWithRoastInformation:(CRRoastInformation *)information
{
    CRRoast *roast = [NSEntityDescription insertNewObjectForEntityForName:@"Roast" inManagedObjectContext:self.managedObjectContext];
    roast.result = information.result;
    roast.score = information.score;
    roast.environment = [self environmentWithEnvironmentInformation:information.environment];
    roast.beans = [self beansWithBeansInformations:information.beans];
    roast.heating = [self heatingsWithHeatingInformations:information.heatingInformations];
    if(information.image) {
        roast.imageData = [self dataFromImage:information.image];
    }
    return roast;
}

- (CREnvironment *)environmentWithEnvironmentInformation:(CREnvironmentInformation *)information
{
   CREnvironment *environment = [NSEntityDescription insertNewObjectForEntityForName:@"Environment" inManagedObjectContext:self.managedObjectContext];
    environment.humidity = information.humidity;
    environment.temperature = information.temperature;
    environment.date = information.date;
    
    return environment;
}

- (NSSet *)beansWithBeansInformations:(NSArray *)informations
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:informations.count];
    for(CRBeanInformation *information in informations) {
        CRBean *bean = [NSEntityDescription insertNewObjectForEntityForName:@"Bean" inManagedObjectContext:self.managedObjectContext];
        bean.area = information.area;
        bean.quantity = information.quantity;
        bean.state = information.state;
        
        [set addObject:bean];
    }
    
    return set;
}

- (NSOrderedSet *)heatingsWithHeatingInformations:(NSArray *)informations
{
    NSMutableArray *mutableHeatings = [[NSMutableArray alloc] initWithCapacity:informations.count];
    for(CRHeatingInformation *information in informations) {
        CRHeating *heating = [NSEntityDescription insertNewObjectForEntityForName:@"Heating" inManagedObjectContext:self.managedObjectContext];
        heating.time = information.time;
        heating.temperature = information.temperature;
        [mutableHeatings addObject:heating];
    }
    
    NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithArray:mutableHeatings];
    
    return orderedSet;
}

- (NSData *)dataFromImage:(UIImage *)image
{
    return UIImageJPEGRepresentation(image, 0.8f);
}

#pragma mark - remove
- (void)removeRoastInformationAtIndex:(NSUInteger)index
{
    CRRoast *roast = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.managedObjectContext deleteObject:roast];
    [self save];
}

#pragma mari - count
- (NSUInteger)countOfRoastInformation
{
    return ((id<NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[0]).numberOfObjects;
}

#pragma mark - save
- (void)save
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CRRoastDataSourceDidFailSavingNotification object:self userInfo:@{CRRoastDataSourceDidFailSavingErrorKey : error}];
        }
    });
}

#pragma mark - CoreData objects
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Roast" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"environment.date" ascending:NO];
    request.sortDescriptors = @[descriptor];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CRRoastDataSourceDidFailInitializationNotification object:self];
    }
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"CRCoffeeData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CRRoastDataSourceDidFailInitializationNotification object:self];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CRCoffeeData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.delegate dataSource:self didChangeObject:anObject atIndexPath:indexPath forChangeType:(CRRoastDataSourceChangeType)type newIndexPath:newIndexPath];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.delegate dataSourceWillChangeContent:self];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.delegate dataSourceDidChangeContent:self];
}

#pragma mark - UbiquityStoreManagerDelegate
- (NSManagedObjectContext *)ubiquityStoreManager:(UbiquityStoreManager *)manager managedObjectContextForUbiquityChanges:(NSNotification *)note
{
    return self.managedObjectContext;
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager willLoadStoreIsCloud:(BOOL)isCloudStore
{
    
    [self.managedObjectContext performBlockAndWait:^{
        
        NSError *error = nil;
        if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CRRoastDataSourceDidFailSavingNotification object:self];
        }
        
        [self.managedObjectContext reset];
    }];
    
    [self reset];
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didLoadStoreForCoordinator:(NSPersistentStoreCoordinator *)coordinator isCloud:(BOOL)isCloudStore
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        context.persistentStoreCoordinator = coordinator;
        context.mergePolicy = NSOverwriteMergePolicy;
        _managedObjectContext = context;
        
        BOOL complete = NO;
        [CRConfiguration sharedConfiguration].iCloudAvailable = isCloudStore;
        
        /* _oldContextが nilのときもこれで問題ない */
        complete = (_useCloud == isCloudStore) && (_managedObjectContext != _oldContext);
        
        if(!_useCloud) {
            _storeManager.cloudEnabled = NO;
        } else {
            if(!_storeManager.cloudAvailable) {
                [self notifyCloudUnavailable];
            } else {
                _storeManager.cloudEnabled = YES;
            }
        }
                
        if(complete && !_completed) {
            _completed = YES;
            [self.settingDelegate dataSourceDidBecomeAvailable:self];
        }
    });
}

- (void)notifyCloudUnavailable
{
    [self.settingDelegate dataSourceCannotUseCloud:self];
}

@end

static CRRoastInformation *roastInformationFromRoastItem(CRRoast *roastItem)
{
    CRRoastInformation *information = [[CRRoastInformation alloc] init];
    information.result = roastItem.result;
    information.score = roastItem.score;
    information.image = [UIImage imageWithData:roastItem.imageData];
    
    CREnvironmentInformation *environmentInformation = [[CREnvironmentInformation alloc] init];
    environmentInformation.temperature = roastItem.environment.temperature;
    environmentInformation.humidity = roastItem.environment.humidity;
    environmentInformation.date = roastItem.environment.date;
    information.environment = environmentInformation;
    
    NSMutableArray *beanInformations = [[NSMutableArray alloc] initWithCapacity:roastItem.beans.count];
    for(CRBean *bean in roastItem.beans) {
        @autoreleasepool {
            CRBeanInformation *beanInformation = [[CRBeanInformation alloc] init];
            beanInformation.area = bean.area;
            beanInformation.quantity = bean.quantity;
            [beanInformations addObject:beanInformation];
        }
    }
    information.beans = beanInformations.copy;
    
    NSMutableArray *heatingInformations = [[NSMutableArray alloc] initWithCapacity:roastItem.heating.count];
       for(CRHeating *heating in roastItem.heating) {
        @autoreleasepool {
            CRHeatingInformation *heatingInformation = [[CRHeatingInformation alloc] init];
            heatingInformation.temperature = heating.temperature;
            heatingInformation.time = heating.time;
            [heatingInformations addObject:heatingInformation];
        }
    }
    information.heatingInformations = heatingInformations.copy;
    
    return information;
}

NSString *const CRRoastDataSourceDidFailSavingNotification = @"CRRoastDataSourceDidFailSavingNotification";
NSString *const CRRoastDataSourceDidFailInitializationNotification = @"CRRoastDataSourceDidFailInitializationNotification";

NSString *const CRRoastDataSourceDidFailSavingErrorKey = @"Error";