//
//  CRRoastDataSource.m
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import "CRRoastDataSource.h"

#import "CRRoast.h"
#import "CREnvironment.h"
#import "CRBean.h"
#import "CRHeating.h"

#import "CRRoastInformation.h"
#import "CREnvironmentInformation.h"
#import "CRBeanInformation.h"
#import "CRHeatingInformation.h"

@interface CRRoastDataSource() <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CRRoastDataSource

- (instancetype)init
{
    self = super.init;
    if(self) {
        self.fetchedResultsController.delegate = self;
    }
    
    return self;
}

#pragma mark - get
- (CRRoast *)roastInformationAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSArray *)beanAreas
{
    
    NSMutableArray *areas = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *roasts = [self.fetchedResultsController fetchedObjects];
    for(CRRoast *roast in roasts) {
        for(CRBean *bean in roast.beans) {
            if(![areas containsObject:bean.area]) {
                [areas addObject:bean.area];
            }
        }
    }
    return areas;
}

#pragma mark - add
- (CRRoast *)addRoastInformation:(CRRoastInformation *)information
{
    CRRoast *roast = [self roastWithRoastInformation:information];
    roast.environment = [self environmentWithEnvironmentInformation:information.environment];
    roast.beans = [self beansWithBeansInformations:information.beans];
    roast.heating = [self heatingsWithHeatingInformations:information.heatingInformations];
    [self save];
    
    return roast;
}

#pragma mark - add private
- (CRRoast *)roastWithRoastInformation:(CRRoastInformation *)information
{
    CRRoast *roast = [NSEntityDescription insertNewObjectForEntityForName:@"Roast" inManagedObjectContext:self.managedObjectContext];
    roast.result = information.result;
    roast.score = information.score;
    
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

- (NSSet *)heatingsWithHeatingInformations:(NSArray *)informations
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:informations.count];
    for(CRHeatingInformation *information in informations) {
        CRHeating *heating = [NSEntityDescription insertNewObjectForEntityForName:@"Heating" inManagedObjectContext:self.managedObjectContext];
        heating.time = information.time;
        heating.temperature = information.temperature;
        [set addObject:heating];
    }
    
    return set;
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
    NSError *error = nil;
    
    if(![self.managedObjectContext save:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CRRoastDataSourceDidFailSavingNotification object:self userInfo:@{CRRoastDataSourceDidFailSavingErrorKey : error}];
    }
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
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"environment.date" ascending:YES];
    request.sortDescriptors = @[descriptor];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) {
        abort();
    }
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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


@end

NSString *const CRRoastDataSourceDidFailSavingNotification = @"CRRoastDataSourceDidFailSavingNotification";

NSString *const CRRoastDataSourceDidFailSavingErrorKey = @"Error";