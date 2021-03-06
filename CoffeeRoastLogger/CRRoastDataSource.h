//
//  CRRoastDataSource.h
//  CoffeeRoastLogger
//
//  Created by Hiraku Ohno on 2014/01/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CRRoastDataSourceChangeType)
{
	CRRoastDataSourceChangeInsert = 1,
	CRRoastDataSourceChangeDelete = 2,
	CRRoastDataSourceChangeMove = 3,
	CRRoastDataSourceChangeUpdate = 4
};

@class CRRoastInformation;
@class CRRoast;
@protocol CRRoastDataSourceDelegate;
@protocol CRRoastDataSourceSettingDelegate;
@interface CRRoastDataSource : NSObject

@property(nonatomic, weak) id<CRRoastDataSourceDelegate> delegate;
@property(nonatomic, weak) id<CRRoastDataSourceSettingDelegate> settingDelegate;

- (void)refreshToUseCloud:(BOOL)useCloud;

- (CRRoast *)addRoastInformation:(CRRoastInformation *)information;
- (CRRoast *)updateRoastItem:(CRRoast *)roast withRoastInformation:(CRRoastInformation *)information;
- (void)removeRoastInformationAtIndex:(NSUInteger)index;

- (NSUInteger)countOfRoastInformation;
- (CRRoast *)roastInformationAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)indexOfRoastInformation:(CRRoast*)roast;

- (void)save;

@end

@protocol CRRoastDataSourceDelegate <NSObject>

- (void)dataSource:(CRRoastDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(CRRoastDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSourceWillChangeContent:(CRRoastDataSource *)dataSource;
- (void)dataSourceDidChangeContent:(CRRoastDataSource *)dataSource;

@end

@protocol CRRoastDataSourceSettingDelegate <NSObject>
- (void)dataSourceDidBecomeAvailable:(CRRoastDataSource *)dataSource;
- (void)dataSourceCannotUseCloud:(CRRoastDataSource *)dataSource;
@end

extern NSString *const CRRoastDataSourceDidFailSavingNotification;
extern NSString *const CRRoastDataSourceDidFailInitializationNotification;

extern NSString *const CRRoastDataSourceDidFailSavingErrorKey;
